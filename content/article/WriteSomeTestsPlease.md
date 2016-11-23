+++
date = "2016-09-08T20:13:29-06:00"
title = "Write Some Tests Please"
snippet = "My second technical interview ever.  Pulled up the demo deployed via heroku and of course... it didn't work as intended."

+++
My second technical interview ever.  It was a showcase of my recently built Wild Life Tracker App and I was excited to present it.  Pulled up the demo deployed via Heroku and of course... it didn't work as intended.  It was one of the more embarrassing points of my life but I knew this would a great learning experience.  After finally settling down with the fact that there was in fact a bug in my App my amazing interviewer decided to work with me to figure it out.

The problem we faced was that when we made a request to search for animals with a certain radius to a city it returned what seemed normal values until we realized when I created a new Species and attached a specific sighting location I wasn't able to find that species with the new location.  We first started by looking at the sighting model to make sure that the [Geocoder](http://www.rubygeocoder.com/) gem was being utilized properly.  


        class Sighting < ActiveRecord::Base
          validates :location, presence: true
          belongs_to :species, dependent: :destroy
          geocoded_by :location
          after_validation :geocode, if: -> (obj){ obj.location.present? and obj.location_changed? }
        end

There were no issues and we moved on to the next best thing which was of course the controller the species sightings were being utilized, the species controller.  The controller index action included a large conditional designed to parse the incoming params from the index page.  The problem portion of my `if statement` is as follows.


          ...
          elsif params[:location] && params[:radius]
            @locations = Sighting.near("#{params[:location]}", params[:radius])
            species_ids = []
            @locations.each do |x|
              species_ids << x.id
            end
            @species = Species.where(id: species_ids)
            params[:location].delete('1')
          ...

After a well placed `binding.pry` my interviewer and I started figuring out that it had nothing to do with the `params` object.  Now the time came to run the tests and with RSpec it is fantastically easy to only run a specific test!  My command line syntax:

          bundle exec rspec spec/controllers/species_controller_spec.rb:30

I ran the test and woah?!  It passed.  I knew something had gone awry because the test passing had the context valid params radius and city name returning a certain city.  This of course couldn't be true because my newly created species with a new sighting was not able to be returned.  This led me to believe that it was an issue with the `species_ids` array I was building.  In order to simulate creating a brand new sighting in my test my interviewer and I both agreed to change the `id` in my Factory Girl created record in the test to completely different numbers (in this case 100 and 200). I ran the test again and now the test failed like it should and reflecting the behavior I was experiencing.  This led us to believe that in fact the issue was the with the way I was building the species_ids array.  I was filling it with the id's of the sightings and not the species!  This was a very easy fix and utilizing ruby's fantastic map combined with the pretzel colon syntax we were on our way to a passing test.

        elsif params[:location] && params[:radius]
          @locations = Sighting.near("#{params[:location]}", params[:radius])
          species_ids = @locations.map(&:species_id)
          @species = Species.where(id: species_ids)
          params[:location].delete('1')

Here we now are grabbing the correct `species_ids`!  Now we run the test and wow now it passes.  All in all even though I had an embarrassing bug in my App with the help of a gracious interviewer and some tests we were able to narrow down the problem and re-write the test to better emulate the App's behavior leading us to properly squish the bug.  Next time when you are cranking out an app write some tests please.
