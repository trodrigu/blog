+++
title = "Scraping camp sites with Haskell part 2"
date = "2020-10-10"
snippet ="As the destiny of this software is to be ran multiple times and update..."

+++

As the destiny of this software is to be ran multiple times and update the same data if changed I sought to make the experience of re-hydrating the db a little better.  Since I am using `Database.Persist` I noticed that I am using `insertMany_` instead of the `repsertMany`.  `respertMany` is an interesting function which will replace any data of the same key and then if no key exists it will insert a new record.  The first step to using `repsertMany` is to pick a key to which we will be repsert'ing on.  Since the columns for `StatePark` aren't quite as unique as a I wanted I decided to create a new slug from the name.  The type signature for the slugify function is super simple.

```
slugify :: String -> String
```

The implementation of the function uses the idea that the String Monad can be `map`'d over in the following way.

```
slugify :: String -> String
slugify s =
  let repl ' ' = '-'
      repl c = c
  in
    unpack $ toLower $ pack (Prelude.map repl (s))
```

I'm still trying to figure out if there is a better way than pack/unpack'ing.  After we have this method it becomes easy to add a new column `nameSlug` which we can use to 'key' off of.

```
-- Database Persistence
share
  [mkPersist sqlSettings, mkMigrate "migrateAll"]
  [persistLowerCase|
StatePark
  name String
  nameSlug String
  link String
  hasReservation Bool
  deriving Show
|]
```

My `getStateParks` function now just needs another argument when creating a `StatePark`

```
getStateParks :: IO [StatePark]
getStateParks = do
  scrapedFromURL <- scrapeURL stateParksURL stateParksScraper
  return $
    Prelude.map scrapedMapConverter (fromJust scrapedFromURL)
  where
    scrapedMapConverter (ScrapedStatePark n l True) = StatePark (unpack n) (slugify $ unpack n) (unpack l) False <==== added new arg for nameSlug using slugify
```

Now we need to see what our updated function `repsertMany` needs for arguments which we can see in its type signature.

```
repsertMany :: (MonadIO m, PersistRecordBackend record backend) => [(Key record, record)] -> ReaderT backend m ()
```

First off what is a `Key record`?  This is the primary key and we can indicate what we want as a primary in our schema code.

```
-- Database Persistence
share
  [mkPersist sqlSettings, mkMigrate "migrateAll"]
  [persistLowerCase|
StatePark
  name String
  nameSlug String
  Primary nameSlug
  link String
  hasReservation Bool
  deriving Show
|]
```

This is the equivalent of executing

```
CREATE TABLE "state_park"( PRIMARY KEY ("name_slug"),"name" VARCHAR NOT NULL,"name_slug" VARCHAR NOT NULL,"link" VARCHAR NOT NULL,"has_reservation" BOOLEAN NOT NULL)
```

The next step is to create something resembling

```
[(Key record, record)]
```

This needs something like

```
[record] -> [(Key record, record)]
```
which is basically

```
(Key StatePark, StatePark)
```

The way we create one is through concatenating the name of the model `StatePark` with the `Key` keyword.  In order to construct the more correct `StateParkKey String` we can use the following syntax.

```
(StateParkKey (slugify $ unpack n) , StatePark (unpack n) (slugify $ unpack n) (unpack l) True)
```

With all the above updates we are now able to consistently update and hydrate the database from our subsequent scrapes!


Progress is on <a href='https://github.com/trodrigu/camp-notify'>github</a>.
