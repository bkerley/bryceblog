---
layout: post
date: '2010-11-18T13:25:37+00:00'
title: Migrating Github Projects to HTTPS
tags:
- github
- https
- git
redirect_from:
- "/post/1609476959"
- "/post/1609476959/migrating-github-projects-to-https"
kind: regular
---
{% raw %}<p>Github now has an HTTPS repository URL for every project, and you should definitely use it. You don&rsquo;t have to manage SSH keys, just store your password in plain text<sup>1</sup> in your home directory.</p>{% endraw %}

{% raw %}<p>Once per machine, put this in your ~/.netrc file:</p>{% endraw %}

```
machine github.com
login bkerley
password yourpassword
```

{% raw %}<p>For each repo, do this:</p>{% endraw %}

```
> git remote rm origin

> git remote add origin https://github.com/bkerley/yourproject.git

> git remote set-branches origin

> git pull origin master
From https://github.com/bkerley/yourproject
 * branch            master     -> FETCH_HEAD
Already up-to-date.

>
```

{% raw %}<p>And that&rsquo;s basically it.</p>{% endraw %}

{% raw %}<h1>Footnotes</h1>{% endraw %}

{% raw %}<p>1: Github crew, can we get a way to use our API token or some other revokable token as a password for HTTPS repo operations? I appreciate that anything involving &ldquo;revokable tokens&rdquo; is really hard to make a decent UI for, but it just feels bad keeping that in my .netrc file.</p>{% endraw %}
