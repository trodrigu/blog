+++
title = "Scraping camp sites with Haskell final"
date = "2020-12-02"
snippet ="Delving deeper in the problem of camp site planning we look to figure"

+++

Delving deeper in the problem of camp site planning we look to figure out just how many reservations are available.  To do this we have to discover the right set of endpoints.  Luckily this is easily done with the network tab and diligent filtering.

Analyzing the requests tab for XHR requests I'm able to pick out the API used to find the `placeId` (`/namecontains`).

The `placeId` is what is used to look up an array of `facilityId`s  which we POST to `/grid` to find the array of available camp sites (based on dates passed in).

First things first after looking at the API a little closer I realized that in the search API all have state park abbreviated to SP.  The easiest way to achieve this update is by the `Data.Text.replace` method which is `replace needle replacement haystack`.  With this fixed we are now able to use the name to query the search API.

To ensure we have parks that have a reservation and have the suffix 'SP' we can use `Prelude.filter`.  With this collection we can query the `/namecontains` API (like mentioned above) to return a `ReserveCaliforniaStatePark` object which I use in a function named `fromReserveCaliforniaStatePark` to add a `placeId` in the `StatePark`.

Using that collection of now updated `StatePark`s we can query the second API `/place` for facility info.  This endpoint is a `POST` and requires a json payload which I created a `PlaceRequest` for which includes the `placeId`.  This returns the important `PlaceResponse` as a tuple like `(PlaceResponse, StatePark)` because we need the state parks name slug as a foreign key to link state parks and facilities.  From the `[(PlaceResponse, StatePark)]` we can parse out the `facilitiesForDb`.

The units take another step which is to POST to a different `/grid` API.  This POST takes a `GridRequest` and returns `GridResponse`.  A `GridRequest` is created with a `toGridRequest` function which takes the magical tuple of `[(PlaceResponse, StatePark)]`.  With the `[GridResponse]` we can parse the units AND the availability.

The last part to be able to save off the units, facilities, and availability's via `repsert` we must pass the similar `(Key, Data)` structure.  I created tuplify functions for each data specifically to accomplish this.

All in all, this was a quick summary of my scraping experiment which is on <a href='https://github.com/trodrigu/camp-notify'>GitHub</a>.  There are other nested data structures such as the `FacilityGridResponse` and `UnitRes` which I didn't talk about because I thought they were kind of boring and allow traversing for units and availability.  I also had to use `concatMap` a lot due to the nested nature of these structures.  I also leveraged the [aeson](https://hackage.haskell.org/package/aeson-1.5.4.1/docs/Data-Aeson.html) lib a whole lot.  If you've made it this far then I want to thank you!  I will most likely keep blogging about similar subject matter (functional programming) and I look forward to publishing.  Thanks for reading! :)
