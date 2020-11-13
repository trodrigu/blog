+++
title = "Scraping camp sites with Haskell part 3"
date = "2020-10-12"
snippet ="The next part on the series includes figuring out if a given state park actually..."

+++

The next part on the series includes figuring out if a given state park actually has camping enabled at this time.  This should be an interesting return of data because COVID-19 has made it not consistent across all parks (this could change in the coming weeks as cases go up).

As it works currently we have a `getStateParks` function which returns an `IO [(Key StatePark, StatePark)]`.  Currently a given state park will always have `hasReservation` set to false.  Let's change that and make that Boolean live (as in query the web about it).

Looking through the pages we can see that a given page will have a specific link if state park has reservations enabled.  Now we need a function that checks for this link.  In the form of a scraper its as easy as

```
reservationStatusScraper :: Scraper Text [Text]
reservationStatusScraper =
  attrs "href" "a"
```

With the above we can then use `Prelude.elem` to check if the link exists on the page.

At this point in time I realized that I can also change my data model references from `String` to `Text` to help simplify constructing the `StatePark` model.  This helped to simplify my `slugify` method.

```
slugify :: Text -> Text
slugify s =
  let repl ' ' = '-'
      repl c = c
  in
    toLower $ (Data.Text.map repl (s))
```

Continuing on we can compose another function in `getStateParks` to do the data transformation of updating `hasReservation`.  `getReservationStatus` will be applied on every link from the `ScrapedStatePark` so that means we will have a type signature kind of like

```
getReservationStatus :: ScrapedStatePark -> IO (Key StatePark, StatePark)
```

In order to compose these functions we can use an `IO` Monad function for executing a sequence of `IO` operations called `sequence`.  Combining them all looks like the following.

```
getStateParks :: IO [(Key StatePark, StatePark)]
getStateParks = do
  scrapedFromURL <- scrapeURL stateParksURL stateParksScraper
  sequence (Prelude.map (\r -> getReservationStatus r) (fromJust scrapedFromURL))

getReservationStatus :: ScrapedStatePark -> IO (Key StatePark, StatePark)
getReservationStatus (ScrapedStatePark n l _hasReservation) = do
  linksOnPage <- scrapeURL (unpack l) reservationStatusScraper
  return $ (StateParkKey (slugify n) , StatePark (n) (slugify n) (l) (Prelude.elem ("http://www.reservecalifornia.com/" :: Text) (fromJust linksOnPage)))
```

Its kind of cool to think that we are working on the Monad level with `sequence` because we are moving the `[]` angle brackets inward one level. This is so you can actually process the inner data since it starts off as a series of separate `IO` operations.

```
[IO (Key StatePark, StatePark)] -> IO [(Key StatePark, StatePark)]
```

After gluing the functions together I now realize that its kind of slow running.  That is why in my next article I'm going to make the pull for status parallel instead of a sequence.

Progress is on <a href='https://github.com/trodrigu/camp-notify'>GitHub</a>.
