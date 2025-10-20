---
layout: post
title: WebPKI and You
tags: security https
---

There's been a push over the last twelve years to move
web traffic off unencrypted 
[HTTP](https://en.wikipedia.org/wiki/HTTP)
to encrypted HTTPS,
to protect the general public from 
[dragnet surveillance](https://en.wikipedia.org/wiki/MUSCULAR#/media/File:NSA_Muscular_Google_Cloud.jpg), 
[gaping assholes on public wifi][^airpwn],
[backhauls over unencrypted satellites](https://satcom.sysnet.ucsd.edu),
that kinda thing.
HTTPS relies on an a public key infrastructure to make sure
only authorized servers have keys for specific websites.

[^airpwn]: ironically this site has an exipired cert,
  so I've linked the non-HTTPS version;
  there are shock images in some of the links there so
  you may want to not browse pas the first page
  if "gaping asshole" feels like an odd phrasing
  and not a specific image:
  <http://gbppr.net/defcon/evilscheme/index.html>

The public key infrastructure of the web, 
commonly referred to as WebPKI,
has to work in some difficult scenarios.
Someone who's never touched a trackpad relies on their ability to
buy a new computer at the store,
put it on the wifi at DEF CON,
and connect to their bank's website to kick off 
a wire transfer to buy a house with it.[^wiretransfer]
The way this user's bank,
the First Example Bank of Money,
proves that they're the bank is complicated.

[^wiretransfer]: it was actually the airport on the way to DEF CON
  and a computer I've had for four years,
  but still felt sketch making a non-reversible transfer of
  a shitload of money

1. When provisioning their server, 
   the bank generates a private key and a public key
2. The bank sends their public key and some proof
   that they're the legitimate operator of `bank.example`
   to a Certificate Authority (CA)
3. The CA validates this proof and issues a 
   [certificate][ulf-cert] containing:
  * server addresses this certificate is valid for
  * the public key for the server, `bank.example`
  * how the validation happened
  * who the CA thinks requested the certificate
  * information about the CA's certificate process
  * the CA's certificate (or a chain of certs)
    leading back to a root certificate
  * a signature from the CA's private key
4. The bank loads this certificate into 
   the `bank.example` server next to the private key
5. When the user connects to `bank.example`,
   the server sends this certificate to the client
   as part of 
   [establishing a secure connection][ulf-tls13].
6. The user's browser
   validates the certificate matches
   both who they're connecting to
   (i.e. that the certificate lists `bank.example`
   as one of the subjects of it)
   and that the certificate is chained back to
   a root CA the browser recognizes

[ulf-cert]: https://tls13.xargs.org/certificate.html
[ulf-tls13]: https://tls13.xargs.org/

There're a bunch of participants in this process,
in different organizational domains because
security is complicated.

In the organizational, regluatory, *human* domain:

* the user is a **relying party**, 
  they rely on all this shit working
  so they can exist in society
* The First Example Bank of Money
  is a **subscriber** to certificate services
* they subscribe to certificates
  from a **certificate authority** or CA
* CAs are generally endorsed by a 
  **root** that signs one or more CA certificates
* the browser or operating system
  has certificates for some roots loaded into it by the organization
  distributing it; these are **root programs**
 
In the hell of x.509 certificates:

* the user is represented by their **client**,
  a web browser or mobile app or that kinda thing
* a subscriber is going to have a server that's the
  **subject** of a certificate
* their certificate's **issuer** is the CA
* confusingly, the CA is the subject of *their* cert,
  which has an issuer of a root CA
* browsers/OSes keep root CA certs in a **certificate store**

# A Brief History of HTTPS and WebPKI

When HTTPS started to be a thing in the mid-'90s, 
it was really just a thing for the very nascent
e-commerce industry and banks and such; 
and even then sites wouldn't do their general traffic
on the HTTPS site, instead kicking you to the
secure server once you'd finished filling your cart
with actual books written by human authors and 
no SIXLTR garbage that breaks after six months
on that hot new online bookstore.
Browsers started to put locks and such in the UI,
and they just kind of made up rules for who
could be in their root store
in ways to not have too many CAs
but not make too many governments mad.

<aside>

Certificate Authorities often find themselves wrapped
up in legal requirements,
or otherwise attached to government operations.
Being able to sign a certificate saying that
Mallory operates Alice's site on which
Bob and Carol are conversing seems valuable,
and Certificate Transparency
(more on CT later)
hasn't existed forever.

</aside>



---


* The Bad Old Days
  * The cert cartel required you to spend hundreds of dollars and do paperwork
  * the Snowden leaks hadn't happened
  * "privileged network positions" didn't really include "guy running [airpwn](https://github.com/grepwood/airpwn) near you at the coffee shop" yet either
  * Root programs basically felt pressured to include certs for all these certificate authorities
* The CA/Browser Forum and Related Developments
  * The Certificate Authorities and Browsers all came together for a huge party and 
    to draft Baseline Requirements for CAs
  * This brought a bunch of improvements for WebPKI and work for CAs; in no 
    particular order:
    * CAs have to publish a Certification Practice Statement (CPS) about
      how they operate
    * based on how the CA validates domain ownership, 
      they can issue different kinds of cert
      * Domain Validated (DV) means the CA just checked domain control,
        ideally with an automated process
      * Organization Validated (OV) means the CA also
        checked some information about the organization requesting the cert
      * Extended Validation (EV) means the CA did a lot more work
        and in theory browsers could show a green company name in the address bar
        but everyone decided this was stupid and nobody paid attention to it
        * this is the main thing that made me hate all CAs
        * browsers selling out to this cartel that wanted to 
          charge hundreds more dollars for the same shit they were already supposedly doing
          

    * CAs have to publish every cert they issue to public
      Certificate Transparency logs
      * This means that certs for CTF challenges that name the challenge
        are made available to players who will ask for the challenge
        before you've published it
    * CAs have to revoke bad certs on a schedule based on why
      * (foreshadowing) if it's a brown m&ms problem, five days
      * if it's some business dipshit mailing all their private keys to a mailing list,
        24 hours <https://arstechnica.com/information-technology/2018/03/23000-https-certificates-axed-after-ceo-e-mails-private-keys/>
      * if revocation takes longer, that generates a new incident

* brown m&ms aside
  * lots of shows and performances come with a "contract rider,"
    a list of the performers' requirements that rides along with the contract
    to put on the show
  * sometimes it's things like 
    "we want twenty-four Mango La Croixes in a fridge for after the show"
  * [Van Halen](https://www.youtube.com/watch?v=fuKDBPw8wQA)
    had a complex show with huge racks of lights and pyrotechnics and 
    flying around on wires and shit,
    so their rider had requirements about the floor strength and
    that kind of thing
  * if venues didn't do everything in accordance with the rider,
    people could die
  * as part of the rider, 
    they required a bowl of M&Ms with the brown ones removed
  * if there wasn't a bowl, or if there were brown ones in it,
    they knew to scrutinize everything else about the production
  * in lots of places since then, there's an idea of a
    "brown m&m" issue that provides a party responding to it
    a chance to demonstrate that they can handle
    a more critical issue
  * for example, if a car company
    can successfully recall an ugly piece
    of shit truck for a cosmetic body panel falling off from failed
    adhesive,
    they can probably also successfully run a recall campaign
    for the accelerator pedal getting stuck because of failed adhesive

* The fundamental issue with the CA business model
  * Let's Encrypt is a CA that gives away certs for free
    * the limitation is they're short lived
      * aside: why short-lived is better?
        * so much downtime from year-long certs expiring
          could be avoided by just automating it
        * if you get a five year cert for example.com,
          what happens when the domain changes ownership?
          does the CA have to track that?
          better if it just expires and you can't validate it to renew
        * if you get an email from your CA saying your cert is getting
          revoked (possibly through no fault of your own!)
          you can probably easily replace it, since you last did so
          pretty recently and not a year ago
        * a short-enough lifetime (a week?) 
          exempts the cert from revocation requirements altogether
        * the downside is there's less resilience i guess
          * i would simply not have my shit break
  * full-service CAs need to do something better than LE
    to get their clients to pay $500 or more.
    in rough order of actual utility:
    
    1. tech support: 
      LE is pretty easy if you follow the narrow paths they document well
      (Nginx or Apache HTTPD)
      or know to follow an even better path ([caddy](https://caddyserver.com)),
      but organizations that got super pwned by clownstrike might not
    2. longer-lived certs:
      these are basically bad but if you refuse to automate, I get the value
    3. advocating on your behalf if there's been a brown m&ms problem
      and you have 872 certs that need
      to be revoked but you don't want to because 
      there're so many internal systems that don't support any automation
      and
      you're just
      a smol bean multinational payment processing company
      that everyone reading this post has heard of or seen the logo for
    
  * basically a full-service CA isn't paid by browsers or relying parties,
    so they don't feel a particular need to make decisions that
    benefit relying parties;
    this is something the CA/BF and other venues try to address,
    successfully by making the CAs' business interests
    align with the public interest

* Let's Talk About The Incident
  * [March 6, 2024](https://bugzilla.mozilla.org/show_bug.cgi?id=1883843):
    Entrust, a Certificate Authority, 
    posted an issue about some certs missing a link to their Certification Practice Statement (CPS).
    Brown M&Ms as hell.
  * [March 13](https://bugzilla.mozilla.org/show_bug.cgi?id=1883843#c3):
    someone comments that
    [they didn't actually fix the problem](https://crt.sh/?id=12348828564),
    and that they should've fixed the problem and revoked by now.

    Entrust's representative says they won't fix the problem
    and don't need to revoke
    because [they don't want to](https://bugzilla.mozilla.org/show_bug.cgi?id=1883843#c4).

    > We have not stopped issuance and we are not planning to stop issuance or to revoke certificates issued, we do think that this miss alignment between baseline requirements and the EV guidelines was an unintended oversight of SC-62v2 as explained in the root cause analysis. Revoking these certificates would have unnecessary big impact to our customer and the WebPKI ecosystem overall.
  * March 18:
    A member of the [Google] Chrome Root Program
    comes back from some time off, [says that Entrust's response
    "fails to meet our expectations"](https://bugzilla.mozilla.org/show_bug.cgi?id=1883843#c19)
    (citing a laundry list of reasons and asking a laundry list of questions),
    and suddenly 
    Entrust is stopping issuance and making revocation plans.
  * March 20:
    After some struggling to identify the certs that need to be revoked,
    [Entrust starts revoking the certs](https://bugzilla.mozilla.org/show_bug.cgi?id=1886532#c1).
  * [April 19, 2024](https://bugzilla.mozilla.org/show_bug.cgi?id=1886532#c11):
    Entrust has revoked 10,013 of the 26,668 certs;
    fewer than half, a month after deciding to start.
  * [May 15, 2024](https://bugzilla.mozilla.org/show_bug.cgi?id=1886532#c17):
    Entrust confirms that 95% of *customers* have completed revocation,
    but still have 9,906 certs remaining; just over 62% have been revoked.
    Entrust reveals that they're providing "limited exceptions"
    to financial institutions, government agencies, information technology shops,
    and airlines.
  * [May 29](https://bugzilla.mozilla.org/show_bug.cgi?id=1886532#c34):
    While the most recent update from Entrust only shows 74.7% revocation,
    the Entrust representative has said that
    "our subscribers are generally describing critical infrastructure,"
    while their CPS prohibits issuing to
    "any application in which failure could lead to death, personal injury or severe physical or property damage."
    Wayne, an independent Relying Party (i.e. a member of the public),
    explains:

    > You cannot have it both ways. Either a subscriber is critical infrastructure and thus forbidden to even have a certificate issued by Entrust, or they are not and should have been revoked already. Please provide a per-subscriber breakdown of what exactly you mean by critical infrastructure and the subscriber's risk.

    To me, this is the moment where we need to revisit the
    role of WebPKI,
    and alternatives to it.

* WebPKI and Critical Infrastructure
  * WebPKI is intended to secure connections between 
    general purpose web browsers acting on behalf of a member of the general public
    and web servers operating on the public internet.
  * WebPKI is not intended for securing connections between
    a phone app for an Internet-enabled thermostat and the
    manufacturer's phone-facing API server,
    or between the Internet-enabled thermostat and the
    manufacturer's thermostat-facing API server.
    * It may incidentally work for this,
      but there may be constraints that break it.
    * If the phone app "pins" the API server's certificate,
      it'll break *when* the API server's certificate is replaced,
      even if the new certificate is valid.
    * If the thermostat only works with WebPKI certs using the
      SHA-256 ECDSA algorithms, 
      a future algorithm requirement will render 
      the connected aspects of the thermostat
      useless until it's patched with new firmware.
      If the thermostat is a few years old,
      libraries may not support the new algorithm
      while working well on the chip in the existing unit.
      Welcome to Brick Town.
  * It's not intended for securing the connection between
    a corporate-managed laptop and the corporate mail server.
    * The risk here is that corpo auditors may not like that
      their internal infrastructure is listed on the public
      Certificate Transparency logs,
      that the mail server makes HTTPS requests to the public internet,
      or that an admin has to intervene to replace a cert
      when the CA revokes it.
  * In these situations, I usually yolo-run Let's Encrypt,
    but I also understand the problems with that approach.
  * In past situations that needed certs for testing
    but not necessarily WebPKI certs,
    I just ran my own CA.
    [The code's still out there](https://github.com/basho-labs/riak-ruby-ca),
    but it's eleven years old, I'm no longer paid to maintain it,
    so it's mostly out there as an example and starting point in case
    I need one again.
  * Many CA companies offer their own non-WebPKI
    cert services,
    which may be more palatable for a payment processing company
    than some shit you run in a random dev k8s cluster.

* Let's Resume Talking about The Incident
  * 

# chunks i wrote already

* What is WebPKI?
  * Web public key infrastructure is what lets you buy a computer at the store and then use it to go to any normal HTTPS website and see a little padlock in the address bar without having to provision and install a certificate
  * Certificates are distributed by Certificate Authorities, abbreviated as "CA" and sometimes called an "issuer"
  * A certificate is a piece of data:
    * It says what addresses the certificate is valid for
      * The cert for `blog.brycekerley.net` can't be used to be `google.com`
    * It says what the cert can be used to do
      * The cert for `blog.brycekerley.net` can be used for web traffic, but not for making new certificates
    * It has information about how to check if the cert was issued correctly, and if it's still valid
    * It includes a public cryptographic key for a given server, or "subject"
    * It has an unforgeable signature from the issuing CA
  * Operating Systems (OSes) and browsers come with a collection of root certificates, a "cert store"
  * Each cert store is administred by a "root program"
  * Apple, Chrome, Microsoft, and Mozilla run root programs
  * You rely on this working correctly to use the web safely, making you a "relying party"

# old outline

* You can just not use web PKI
    * If you have a closed network where you control every party, you don’t actually have to use public certs that come with public cert requirements
    * Consider a bank that has thousands of ATMs
        * they could just run their own CA and not care about the CA/BF for the ATM stuff
    * Consider a company shipping a smart end table that connects to an API server
        * It’s just their endpoint software connecting, not general-purpose browsers, who cares about CA/BF requirements
    * You can implement your own CA in a few hundred lines of Makefile and the `openssl` CLI tool
* Trouble in webPKI land
    * Historically, certs lasted a year or more
    * Some software assumes that certs aren’t being replaced that often
    * I assume that the more bespoke enterprise the software the worse it is
        * Caddy & traefik automate it completely
        * The box at work that someone stood up a couple years ago and their replacement is gone now too isn’t automated well
        * I assume “big three” airlines have some shit that’s a nightmare to replace
* The web is the ultimate distributed system
    * Distributed systems computer you don’t know about breaks yours etc
    * Recovery from failures cannot be an exceptional case, it is the only case
        * Riak active anti entropy
* Certs need to be replaced sometimes
    * Key material disclosed (operational problem, software problem, hardware problem)
    * Issued to the wrong entity
    * x.509 v3 certificate policy field points to wrong entry in ITU/ISO/IEC Object Identifier global database
    * Crypto algorithm acceptability changes over time
* Revocation sucks and expiration sucks less
* Let’s Encrypt
    * Make HTTPS the standard by making certs free
    * Make certs free means there’ll be problems
    * Making them short-lived minimizes the blast radius of problems
    * Certbot (formerly the official client) wants to run twice a day and will renew certs at 60 of their 90 day lifetime
* Big commercial CA
    * Big customers you’ve heard of taking >70
* Conclusion
    * The general public relies on certs being safe and accurate even if they don’t know they exist
    * Cert subscribers need to make choices that prioritize the general public instead of their stubbornness to accept the realities of the web
        * This either means automating WebPKI certs or not using WebPKI certs
    * Cert authorities need to get their subscribers into this way of thinking
    * Browsers may need to get CAs into this way of thinking

