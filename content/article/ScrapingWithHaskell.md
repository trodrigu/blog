+++
title = "Scraping camp sites with Haskell part 1"
date = "2020-10-05"
snippet ="In order to test my current knowledge of beginner Haskell I sought to build..."

+++

In order to test my current knowledge of beginner Haskell I sought to build something that would actually align with something I've been doing more and more of lately (well less since its approaching winter).  A basic scraper that persists to a db seemed to fit the bill.  Libraries I would use include the following.

- obelisk which features front end and back end dev out of the box
- scalpel lib for grabbing HTML
- `Network.HTTP` for HTTP requests
- persistent for persistence
- hspec for testing

At this point I'm still in the exploratory mode as I'm not really sure how much I can get out of the state parks sites.  `stateParksURL = "https://www.parks.ca.gov/?page_id=21805"` is the URL that I'm able to scrape for the top state parks in California.  This seems like a good starting point.

I can also start to think through what I should store in my model for the database.  I decide to go with the following at first.

```
-- Database Persistence
share
  [mkPersist sqlSettings, mkMigrate "migrateAll"]
  [persistLowerCase|
StatePark
  name String
  link String
  hasReservation Bool
  deriving Show
|]
```

That way I can know top level if a given state park has a reservation.  I may change this as personally I'm not a fan of depending too much on a Boolean flag.  As I'm changing the model and updating code I forgot to mention is that I leave `ob run` open in a terminal to help me solve the compiler errors faster.  The kind of less than great thing though is every time I make a model change I have to stop `ob run` and `dropdb test` and then `createdb test` to recreate the database.  The thing I do really love about prototyping in Haskell is that it's easy to sub out certain things with other things because a given function will always return the value it says it will.

At this point I'm able to get just the StatePark names pretty easily as the Scalpel library makes it pretty easy to do so.  The syntax allows for very composable scrapers.  You can sort of write our your types before hand to get a feel for how the code might look.

```
stateParkScraper :: Scraper String [ScrapedStatePark]
stateParkScraper' :: Scraper String ScrapedStatePark
```

Here you can sort of grok the structure which starts off with an array of `ScrapedStatePark`s and a single  `ScrapedStatePark`.

```
-- Scrapers
stateParksScraper :: Scraper String [ScrapedStatePark]
stateParksScraper = chroot ("div" @: ["id" @= "center_content"]) (chroots ("li") (stateParkScraper))

stateParkScraper :: Scraper String ScrapedStatePark
stateParkScraper = do
  name <- text $ "a"
  link <- attr "href" $ "a"
  return $ ScrapedStatePark (pack name) (pack link) True
```

As you can see it was a clean break for mapping the list of state park names and links.  The next part is diving one more level in parsing the data underneath.  Haskell allows enjoying the merits of composition a little easier sometimes :)

Progress is on <a href='https://github.com/trodrigu/camp-notify'>github</a>.
