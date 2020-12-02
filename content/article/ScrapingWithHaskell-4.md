+++
title = "Scraping camp sites with Haskell part 4"
date = "2020-12-01"
snippet ="In Haskell since Types nicely lead you to format your code by letting you push dependencies upstream..."

+++

In Haskell Types make it easier for you to push dependencies upstream by leaning on the type more.  We can lean on the `sequence` function a little more which turns a `[IO()] -> IO [()]`.  The `parallel-io` library has a specific function which capitalizes on this relationship called `parallel`.  It's at this moment I realize that using obelisk might be a bit overkill for this example so I decided to pair down the project to be a simple Main.hs file built by the nix package manager.  I used the backend.cabal file as a reference to build my new camp-notify.cabal file.  [This](https://maybevoid.com/posts/2019-01-27-getting-started-haskell-nix.html) was super helpful in making the transition to a more paired down instance with nix.  I basically  just run `nix-build release.nix` to rebuild my project and then run the executable like `./result/bin/camp-notify`.  That way when I'm running the executable I can easily pass the `+RTS -N4` flags to run multi-threaded.

As a benchmark I reached for the `time` command line cli and passed my executable like so `time ./result/bin/camp-notify`.  This yielded a typical time of

```
./result/bin/camp-notify  1.44s user 0.09s system 15% cpu 9.704 total
```

After converting to `parallel` and passing the correct flags we get a time of (`+RTS` to indicate the start of ghc option related flags and `-N` to indicate how many cores)

```
./result/bin/camp-notify +RTS -N4  2.43s user 0.91s system 86% cpu 3.873 total
```

This is 2.5 times faster!  This is a dramatic improvement just by parallelizing the IOs.  In the next one we will seek higher understanding by detailing the dates and reservations available per camp site.



Progress is on <a href='https://github.com/trodrigu/camp-notify'>GitHub</a>.
