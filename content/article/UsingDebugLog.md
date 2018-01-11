+++
title = "Using Elm's Debug Log"
date = "2018-01-02"
snippet ="In Elm land it takes a bit of tinkering to understand how to conduct debugging..."

+++


When starting a small elm project it can be pretty easy to reason about the pieces needed
to get the app to compile.  One could get pretty far without ever using the `Debug.log`.  However, sometimes with all the compile time errors it comes time to reach into the tool bag for one of Santa's little helpers.  When first getting started I googled around and saw that there was not that many ways to see data inside the elm app.  Therefore, I wanted to at least get really familiar with the built in mechanism.  I wrote an extremely simple app which echoes out "Y'all" when a button is clicked.  The link is at the following.

```
https://ellie-app.com/QTBvrgt8a1/0
```

The syntax when using it in say an update function requires you to set the Debug function equal to an ignore variable `_`.  Being inside a let/in area means that you must return a value for everything called inside of it and then set it to a variable.  We don't really care about the value the call to `log` returns so the `_` works.  We also need to be sure to pass a string along with the thing we want to check.  This is why we pass in a nice message.  Sometimes when I'm in the weeds I will add an extra special message like "`log from within HandleFetchCampaigns`" to really dial in my logging.  I even added a short cut in Spacemacs for adding this logging using yas-snippet.  I type `C-c C-c C-d` and then *boom* I have a log call set up for my usage.  It looks like the following.

```
# -*- mode: snippet -*-
# name: debug
# key: debug
# binding: C-c C-c C-d
# --
let
    _ = Debug.log "$1" $1
in
```

After I have finished my debugging fun, then I am sure to remove all of them to make sure there are no remnants.  Happy debugging my fellow elmers!
