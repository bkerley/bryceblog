---
layout: post
title: "Da Search Zone: Updating an Old Elixir Phoenix App"
tags:
    - programming
    - updates
    - dasharez0ne
kind: regular
css_id: elixir-update
---

<style type="text/css">
#elixir-update code {
  font-size: 0.9rem;
}
</style>

**Content note:** This post includes gendered slurs and features
demonic and hellish imagery.

Back in late 2016 I wanted a good way to search posts from
[da share z0ne][dsz], a lovely account posting feel-good and brutally
funny stuff juxtaposed on top of heavy metal iconography of flaming
skulls and grim reapers.

> ACT ODD GET CLAWED BITCH <https://t.co/fuiVY1r3GU>
>
> ![an armored figure breathing fire and carrying a sword, with text superimposed: "YOU WANT TO FIGHT MY CAT? you gotta get through ME and my OTHER CATS first bitch Rip BOODLEHEIMER I DON'T ACTUALLY HAVE ANY OTHER CATS RIGHT NOW BOOM!!! da share z0ne"](/assets/post_images/dasharezone_cat_fight.jpg)
>
> [da share z0ne][dsz]
>
> [4:13 AM · Jun 11, 2016](https://twitter.com/dasharez0ne/status/741543905456427008)

[dsz]: https://twitter.com/dasharez0ne

My friends and I found a lot of these posts really sticky, sharply defining
an intriguing and hilarious character, and as such needed to share links to
these posts frequently. However, how do you search a picture of text?

# da search z0ne

I'd made an Elixir Phoenix[^1] app earlier in 2016, and decided to try and
make another one instead of defaulting to Rails like I usually do.
Originally, it used the then-current Phoenix 1.2.1 and Elixir 1.2
([initial commit][c-init]). Set up a Postgres database with full-text search,
schedule an update every hour, and an admin interface where I transcribe
random images by hand.
I deployed it on Heroku using
the [Phoenix "Deploying on Heroku" guide][deploy-guide] and that was that.

[^1]: "Elixir Phoenix" refers to the
      [Phoenix framework](https://www.phoenixframework.org) in the
      [Elixir language](https://elixir-lang.org). It's clunky to say but
      disambiguates from the many other "Phoenix" packages in computing.

[c-init]: https://github.com/bkerley/tmfsz/commit/2f6628bde095ee4c9902832859daac4fb72814c6#diff-dfa6f4ed74c90e5d4fda283d547d366586e690387289bcfd473e3fa5f9ace308
[deploy-guide]: https://hexdocs.pm/phoenix/heroku.html#content

And then time moved on.
First, I got frustrated at the rule I'd set for myself about transcribing
quotes and retweets, and quit updating it.

Then the [`cedar-14` stack hit end-of-life (EOL)][c14-eol], but the app kept
on truckin'.

# Updating the App

At some point, however, it quit starting, and when I looked at it,
the `heroku logs` just showed that there were too many log messages.

[c14-eol]: https://help.heroku.com/SMQ1J712/cedar-14-end-of-life-faq

```
heroku[logplex]: Error L11 (Tail buffer overflow) -> This tail session dropped 1 messages since [...] UTC.
```

(I've removed timestamps from the logs to make them easier to read).

The first thing I did was to restart the server dynos[^2] with
`heroku dyno:restart`. Didn't fix anything, so I did a `heroku dyno:stop`,
gave the "logplex" logging system some time to flush its buffer,
and then hit the website again.

```
app[web.1]: ** (ArgumentError) argument error
app[web.1]: (postgrex) lib/postgrex/utils.ex:38: anonymous fn/1 in Postgrex.Utils.parse_version/1
app[web.1]: (elixir) lib/enum.ex:1184: Enum."-map/2-lists^map/1-0-"/2
app[web.1]: (elixir) lib/enum.ex:1184: Enum."-map/2-lists^map/1-0-"/2
app[web.1]: (postgrex) lib/postgrex/utils.ex:38: Postgrex.Utils.parse_version/1
app[web.1]: (postgrex) lib/postgrex/protocol.ex:497: Postgrex.Protocol.bootstrap_send/4
app[web.1]: (postgrex) lib/postgrex/protocol.ex:353: Postgrex.Protocol.handshake/2
app[web.1]: (db_connection) lib/db_connection/connection.ex:134: DBConnection.Connection.connect/2
app[web.1]: (connection) lib/connection.ex:622: Connection.enter_connect/5
app[web.1]: 19:21:11.648 [error] GenServer #PID<0.3813.35> terminating
```


[^2]: Containers, but in [Heroku jargon](https://devcenter.heroku.com/articles/glossary-of-heroku-terminology#dyno)

I enabled "maintenance mode", which just throws up a nicer error screen. Then
I captured and pulled a Postgres backup, and noticed that Heroku'd been
dutifully capturing one daily
(only retaining eight, not the over sixteen hundred it'd ever grabbed).
After that, I made sure I had an up-to-date local copy of the app, and started
the work of modernizing it.

First step was installing modern Elixir; lately I've mostly been using Docker
for that, so I cribbed from
[geometerio's example][example-df]
when writing a [new `Dockerfile` from scratch][new-df]. I'm not using the new
one in production, so I mostly just care about package installation.

[example-df]: https://github.com/geometerio/elixir-phoenix-dockerfile-examples/blob/d11c8a3d8cfee131de4ac79bf2a2f1048c5fe4d5/sample_phoenix_app_with_postgres_db/Dockerfile
[new-df]: https://github.com/bkerley/tmfsz/blob/eee7e1c4e66dd0129153e06535d3540362fab032/Dockerfile

With that up and running, I updated the dependencies, `mix deps.update --all`,
and tried to redeploy it.[^3]
This got me to a new error from the Erlang & Elixir Buildpack:

[^3]: If production's down you can test in production, right? I think that's
      how it works…

```
-----> Checking Erlang and Elixir versions
       Will use the following versions:
       * Stack heroku-20
       * Erlang 18.3
       * Elixir v1.3.2
       Sorry, Erlang 18.3 isn't supported yet. […]
 !     Push rejected, failed to compile Elixir app.
 !     Push failed
 ```

The buildpack grabs its version from
[`elixir_buildpack.config`][new-buildpack-config], so I updated that.

[new-buildpack-config]: https://github.com/bkerley/tmfsz/commit/41632a81bdddc3facd6b13fec728cd2fe9738128

Next were a bunch of errors about `PG2`, which first sent me on a wild goose
chase trying to update the `postgrex` Postgres library. It looked up to date,
so I started searching, and found a good
[Elixir Forum thread about the PG2 error][pg2-elixir-forum], in which
José Valim (the creator of Elixir) notes that you can update the
`phoenix_pubsub` library. I tried that for a while, but I didn't really want to
update `phoenix`[^update], which pins a `phoenix_pubsub` version.
Further downthread, someone else mentions that you can remove it from
`config.exs` if you're not using it, [which worked.][commit-no-pubsub]


[pg2-elixir-forum]: https://elixirforum.com/t/cannot-start-app-after-update-with-erlang-24/39708
[^update]: I probably should, since I don't know what security landmines are in
           the Phoenix I have…

[commit-no-pubsub]: https://github.com/bkerley/tmfsz/commit/9396cb23b0c03bc21bedd901ab4ce8e0213ab981

Finally, there was an error on application start about it needing `plug_cowboy`,
so [I installed that,][commit-howdy].

[commit-howdy]: https://github.com/bkerley/tmfsz/commit/eee7e1c4e66dd0129153e06535d3540362fab032

With that change, [da search z0ne][searchz0ne] is up and running again!

[searchz0ne]: https://dasearch.zone

# Things to Fix, Things to Update

There're a few things I'd still like to do with da search z0ne:

* Transcribe ~1760 tweets
* Automatically remove retweets and other tweets without images from the
  transcription pool
* Do something smarter with tweets that (the da share z0ne) admin deletes;
  [this is really frustrating][deleted-tweets] but it's neat to see
  da search z0ne used as an archive tool
* Update to modern Phoenix

[deleted-tweets]: https://twitter.com/xkeepah/status/1065758061841723392

On that last thing, there's something that'd be nice to have from the
Phoenix framework: easier-to-find upgrade guides. I found a
[Phoenix 1.4 to 1.5 guide](https://gist.github.com/chrismccord/e53e79ef8b34adf5d8122a47db44d22f)
by Chris McCord (Phoenix creator) on his Gist[^gist] site, but, as far as
I can tell, that was mostly
a chance search engine find. A guides site similar to the official and
excellent
[Ruby on Rails Guides][rails-guides] site would be a nice place to keep
both old-version release notes and an up-to-date guide on getting to the
newest version, but to me the [Phoenix documentation][phx-docs] site just
kind of feels like an awkward API site combined with an awkward prose site.

[^gist]: GitHub's light/flat/single-serving quick code hosting tool
[rails-guides]: https://guides.rubyonrails.org
[phx-docs]: https://hexdocs.pm/phoenix/overview.html
