---
layout: post
date: '2024-09-01T16:20:00-04:00'
title: "Behavior Sanitizers in Elixir"
tags:
    - since-2021
    - programming
    - elixir
kind: regular
---

*This post is adapted from my lightning talk
during ElixirConf 2024.*

I've done some work with "behavior sanitizers" in a
few different programming environments this past year.

# What are Sanitizers?

A useful definition of "sanitizers" 
(from ["SoK: Sanitizing for Security"][sok])
is that they instrument programs under development or research
to find vulnerabilities. 
A higher/slower performance budget is acceptable in these contexts,
while false-negatives (i.e. program execution survives an error)
are not acceptable.

[sok]: https://ieeexplore.ieee.org/document/8835294

I think sanitizers were originally made mainstream
by the Clang C and C++ compiler,
which provides a collection of them for detecting
data races, uninitialized memory use,
and undefined behavior 
([although compiler authors are working tirelessly][lookub] to 
render them useless).
Similarly, the [Jazzer][jazzer] fuzzing system for
Java includes sanitizers for higher-level weaknesses like
SQL injection, LDAP injection, OS command injection,
and server-side request forgery.

[lookub]: https://dl.acm.org/doi/10.1145/3591257
[jazzer]: https://github.com/CodeIntelligenceTesting/jazzer/

These sanitizers immediately kill the system under test
when triggered.
[Clang's AddressSanitizer][clang-addr] justifies it as such:

> If a bug is detected, the program will print an error message to stderr and exit with a non-zero exit code. AddressSanitizer exits on the first detected error. This is by design:
> 
> * This approach allows AddressSanitizer to produce faster and smaller generated code (both by ~5%).
> * Fixing bugs becomes unavoidable. AddressSanitizer does not produce false alarms. Once a memory corruption occurs, the program is in an inconsistent state, which could lead to confusing results and potentially misleading subsequent reports.

[clang-addr]: https://clang.llvm.org/docs/AddressSanitizer.html

This, plus the performance cost, 
really suggests that you shouldn't plan to
run sanitizers in production.
The "CIA Triad" of 
confidentiality, integrity, and availability
can still be failed if you turn every problem into a crash,
Clownstrike/Windows style.

# Erlang's Trace Module

Erlang/OTP has had a tracing system for a long time. In the OTP 27 version, 
there's a whole `trace` module
for sending reports about function calls from
a selection of processes to a tracer process.

From <https://www.erlang.org/doc/apps/kernel/trace.html> :
```erlang
%% Create a tracer process that will receive the trace events
Tracer = spawn(fun F() ->
                     receive M -> 
                         io:format("~p~n",[M]), F() end end).
                         %=> <0.91.0>
%% Create a session using the Tracer
Session = trace:session_create(my_session, Tracer, []).
%=> {#Ref<0.1543805153.1548353537.92331>,{my_session, 0}}
%% Setup call tracing on self()
trace:process(Session, self(), true, [call]).
%=> 1
%% Setup call tracing on lists:seq/2
trace:function(Session, {lists,seq,2}, [], []).
%=> 1

%% Call the traced function
lists:seq(1, 10).
% {trace,<0.89.0>,call,{lists,seq,[1,10]}} % The trace message
%=> [1,2,3,4,5,6,7,8,9,10] % The return value
%% Cleanup the trace session
%=> ok

trace:session_destroy(Session).
%=> true
```

This code instruments `lists:seq/2`[^mfa] calls.
You can change that though.
It's also all in Erlang, 
but you can write it in Elixir too!

[^mfa]: 
    `lists:seq/2` is basically the standard way
    to identify a function in Erlang.
    Erlang modules and functions have lower-case names,
    separated by a colon, and the `/2` means 
    you're talking about the two-argument version.
    In Elixir,
    you'd call that Erlang function with `:lists.seq(1, 10)` 
    because it turns out Erlang modules are 
    just named with atoms.
    Similarly, Elixir functions get identified like
    `DBConnection.prepare_execute/4`.
    It's called "MFA" for "module, function, arity[^arity]" 
    but I think of it as
    "module, function, argument count"
    'cause I'm basic.

[^arity]: "arity" means argument count

# Finding the Target

I decided that because most of my
Elixir code is web applications that
talk to PostgreSQL databases,
I should figure out how to trace
the part of the `postgrex` Postgres library
that actually takes the query 
and sends it down a socket.
After some looking around,
I learned that `postgrex` does a lot of
its stuff through the `db_connection` library,
which sends all the queries through
the
`DBConnection.prepare_execute/4` function.

Let's inspect that from Elixir:

```elixir
defmodule Inspector do
  def receive_loop() do
    receive do
      mesg -> IO.inspect(mesg)
    end

    receive_loop()
  end
end

tracer = spawn(&Inspector.receive_loop/0)
#=> #PID<0.1845.0>
session = :trace.session_create(:sesh, tracer, [])
#=> {#Reference<0.2597460725.3043885058.15094>, {:sesh, 4}}
:trace.process(session, :all, true, [:call])
#=> 153
:trace.function(session, {DBConnection, :prepare_execute, 4}, [], [])
#=> 1
```

Similar to the Erlang code above,
this sets up the tracing process,
makes a trace session for it,
and instruments the 
`DBConnection.prepare_execute/4` function
in `:all` the processes that are or will be running.

Here's what happens when you run a query:

```elixir
# the query
Postgrex.query!(conn, "SELECT * from pg_stat_user_tables", [])
#=> [query results…]

# to stdout from the tracer process:
{:trace, #PID<0.149.0>, :call,
 {DBConnection, :prepare_execute,
  [
    #PID<0.260.0>,
    %Postgrex.Query{
      ref: nil,
      name: "",
      statement: "SELECT * from pg_stat_user_tables",
      param_oids: nil,
      param_formats: nil,
      param_types: nil,
      columns: nil,
      result_oids: nil,
      result_formats: nil,
      result_types: nil,
      types: nil,
      cache: :reference
    },
    [],
    []
  ]}}
```

This is much more exciting!
The message says it's a `:trace` message,
which process it's from,
what they were doing (`:call`ing a function),
and what they called:
`DBConnection.prepare_execute/4` with the arguments
`#PID<0.260.0>`, `%Postgrex.Query{…}`, `[]`, and `[]`.
Looking at
[the docs for `DBConnection.prepare_execute/4`][pe4],
we see:
> ```elixir
> @spec prepare_execute(conn(), query(), params(), [connection_option()] | Keyword.t()) ::
>  {:ok, query(), result()} | {:error, Exception.t()}
> ```
> Prepare a query and execute it with a database connection and return both the prepared query and the result, `{:ok, query, result}` on success or `{:error, exception}` if there was an error.

So that first `#PID<0.260.0>` is the connection process[^conn],
the `%Postgrex.Query{…}` struct is the query,
the first empty array would normally be a list of parameters
getting bound to placeholders in the query
to prevent SQL injection,
and the last one is a list of options
for controlling queueing, timing out, etc.

[pe4]: https://hexdocs.pm/db_connection/DBConnection.html#prepare_execute/4
[^conn]: 
    Why not a connection object like in
    Ruby or Java?
    We're in BEAM world, 
    state lives in processes here.

# Sanitizing instead of Inspecting

Now that we know how to find the query in a trace message,
let's change gears 
to actually stopping something that looks like injection.
What Jazzer does for SQL injection is just assume
a malformed SQL statement is an attack,
which is probably fine,
but presumes the availability of a
SQL parser. 
I've worked on a
[SQL parser for Erlang][riak-ql]
at a previous job, 
but I figured that an easier approach would be
to just look for a magic string like
`__sanitizer__`.

[riak-ql]: https://github.com/basho/riak_ql/blob/develop/src/riak_ql_parser.yrl

For the "not just a LiveBook shown off on stage"
version, I implemented it as a
`GenServer` that holds the session and tracer,
and a `handle_info` callback that looks for the magic string.
The [full code's available][prototype], 
but here's the part that does the thing:

[prototype]: https://github.com/bkerley/elixir_sanitizer_prototype/blob/main/lib/elixir_sanitizer_prototype.ex

```elixir
  @impl GenServer
  def handle_info(
        {:trace, caller, :call,
         {DBConnection, :prepare_execute,
          _args = [
            conn,
            %Postgrex.Query{
              statement: stmt
            },
            _params,
            _opts
          ]}},
        state
      ) do
    maybe_alert(state, stmt, caller, conn)
  end

  def should_alert?(stmt) when is_binary(stmt) do
    cond do
      not String.valid?(stmt) ->
        # weird but ok
        false

      String.contains?(stmt, sanitizer_slug()) ->
        true

      true ->
        false
    end
  end

  def should_alert?(stmt) do
    stmt
    |> IO.iodata_to_binary()
    |> should_alert?()
  end

  defp maybe_alert(state, stmt, caller, conn) do
    if should_alert?(stmt) do
      Logger.emergency(
          found_injection: stmt,
          caller: caller,
          caller_live: Process.alive?(caller),
          conn: conn,
          conn_live: Process.alive?(conn)
        )

        Process.exit(conn, :kill)
        Process.exit(caller, :kill)
      {:noreply, %__MODULE__{state | fire_count: state.fire_count + 1}}
    else
      {:noreply, state}
    end
  end
```

The `maybe_alert/4` body there doesn't take any prisoners.
It kills the connection and calling process,
which should disconnect the database,
if not before a transaction gets on the wire,
but possibly before a commit.
It's still racy because it happens out-of-band,
and I wouldn't rely on this working in production at all.

It does have tests!
This was my first time hand-cranking a
callback-based behavior,
because I struggled for most of the train ride
on instrumenting the process kills.

# Future Work and Conclusions

I could see this being useful in the context
of a fuzzer,
although my understanding is that fuzzing
isn't a thing in BEAM world.
I think it might be worth researching this,
and I think I see a way to do it in the
same BEAM as a Phoenix LiveView process or something,
but I've got more projects and ideas than time.

Anyways,
I had fun and finally learned about
Erlang tracing after hearing about it in
Basho times.
If you're interested in this,
have a look at
<https://github.com/bkerley/elixir_sanitizer_prototype>

If you want to use this in production,
please don't.
It's a prototype,
it's never been run in production,
and I built it with the assumption that it'd
just be a prototype to demo and
either discard or spend time figuring
out how to integrate it with a fuzzer that
doesn't really exist yet.
