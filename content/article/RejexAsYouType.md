+++
title = "freegexer, regex with a small feedback loop"
date = "2018-09-14"
snippet ="I wanted to make regex better with a smaller feedback loop.  Coming up with just..."

+++

I wanted to make regex better with a smaller feedback loop.  Coming up with just the right regex can be a little tedious however there are some tools out there that make things a little easier.  A quick google search returns 10 options for testing regex patterns.  With that said I still sought to gain understanding by solving this problem with some of Elm's newer libs such as [elm-ui](https://github.com/mdgriffith/elm-ui), and of course natively with Elm [0.19](https://elm-lang.org/blog/small-assets-without-the-headache).

# Design

I'm always a proponent of simple design so I went with the simplest one I could think of.  I wanted to build something that allowed a user to enter the regex they are testing and of course the text that they are matching against.  Good UI gets out of your way.    

# Development

My journey began by first understanding the [elm/regex](https://package.elm-lang.org/packages/elm-lang/core/1.0.0/Regex), and [elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/) packages.  Elm regex provided exactly what I needed with a nice `find` function and returned a nice tidy `Match` type which I could use for rendering my highlights.  Elm UI was **shiny** and I also liked the fact that I could control exactly how the page was rendered with only Elm.  Elm UI makes use of the `el [] ()` which is basically the primary lego piece you will use to build.  The fact that the `el` returns a single (Element msg) enforces the fact that this lego piece will **not** have any children.  It is the end of line or the exit condition for nesting elements.  Composing elements comes down to the following pseudocode pipes.

```
el |> column |> layout
```
This simple API design made me happy with my choice so now the next challenge included figuring what types of elements I would need.

The input for entering the regex to test would be made up of a simple `Element.input` from the `elm-ui` lib.  The other input would need to allow multiple lines for the user to paste what they need.  Therefore, I went with the `Element.multiline` to take care of this.

The layout could be described as the following.

```
[input, multiline] |> column |> layout
```

At first I wanted to take an approach where I would pass an `Element msg` to the `multiline`, however, this was not possible.  That was OK (also known as *Oll Korrect*) because Elm Slack and mgriffith (the package creator) came to the rescue!  He recommended that I use the API for `behindContent` to render something.  Now, I had a good way to underlay something to signify a match.  The next step was to come up with a way for me to display which pieces of the text matched.

In order to solve the highlight problem I needed to simplify the problem at hand.  The problem **really** is just taking a list of letters and asking another list (a list of matches) whether or not the letter was part of the match list.  If there was a match indeed then I wanted to paint a yellow box behind the letter to signify that bingo we had a match.  So now the next problem was to figure out how to emulate the wrapping behavior of the `multiline` since I was rendering basically the same thing as the text being outputted from the `multiline`.  The saving `function` for this was the `String.Extra.softBreak` function from [string-extra](https://package.elm-lang.org/packages/elm-community/string-extra/latest/) which would iterate through a `String` and return a `List String` by splitting at the threshold passed into the `softBreak` function.  This would allow me to dial in a `column` `width` of 672 px, a `softBreak 66`, and last but not least the Font Family I would choose (since spacing changes for characters between different fonts) which was Fira Sans (a google font).

In order to make finding matches easier I broke up the idea of multiple lines to be a `List` of rows, which had a `List` of `Match`es.  The row was of course determined by what the `softBreak` specified, which contained the matches from the `find` method.  Now with a function such as my homegrown `divyUpMarks` I could render a `List` of `row`s and a `List` of `el`s to match the output of my `multiline` but mask the fonts by matching the `Font.color` to the `Background.color`s and appear as a **highlight**!  I would have a conditional on the colors and would flip a cell to white or yellow based on whether or not that letter had a match.

Now I had most of my answers so to finish the development I came up with the checker functions in a `Utility` module which would check whether or not a given character's index was included in the `List Match` for a given row.  I utilized the [elm-explorations/test](https://package.elm-lang.org/packages/elm-explorations/test/latest) lib to test my `deepMember` function (a recursive member checker) and to help fix a bug.  The bug involved incorrect recursion with a botched exit condition.  As soon as I wrote the tests I was able to smooth out this little hiccup (thanks unit testing :)).

# Result

After about a week of development and learning new APIs I was able to create an MVP which highlights matches. [This](https://github.com/trodrigu/freegexer) is the github repo and go [here](https://affectionate-curie-7b47d0.netlify.com/) for the compiled project.

# In Closing

I had a great time pulling in new dependencies and learning about super helpful libs like [elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/1.0.0/), [elm/regex](https://package.elm-lang.org/packages/elm/regex/1.0.0/), and [elm-community/string-extra](https://package.elm-lang.org/packages/elm-community/string-extra/latest/).  I also thought about adding some sort of autocomplete from [elm-autocomplete](https://package.elm-lang.org/packages/thebritican/elm-autocomplete/latest/Autocomplete), but at the moment I'm happy with my little learning experiment.  On another note, I read through elm/regex's github readme and I totally agreed that you should write a parser for your problem domain rather then use complicated regexes when possible.  It is for this reason I am pondering problems that the [parser](https://github.com/elm/parser) could solve.  However, sometimes you need a small regex to grab a month, year or something simple and this is what I wanted freegexer to help with.  Thanks for reading!

# Update

After trying to replicate the line break behaviour of the textarea I ended up changing my approach to be word centric.  For instance, if my example string looked something like `"hello world"` I would divide it up into a List of Chars and then iterate or `foldl` through them to a List of Strings that would look something like `["hello", " ", "world"]`.  Then I could just render my highlighting as a gradient for each word/piece in the array.