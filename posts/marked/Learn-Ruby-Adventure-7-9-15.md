I spent the better part of the last two weeks finishing up a basic ruby centric app that was started about two weeks ago.  The interesting thing was that I didn't know how much I would truly learn from this.  I had just come off of doing a sizeable amount of work on my group project for SDLearn (I will elaborate in a future post) and had Rails on the brain.  When it came down to looking at all my classes and digesting their functionalities I knew I had my work cut out for me.  

My process for building out the terminal game began with me writing a bit of code and then attempting to write a spec to get it to pass.  I realized with this process there really was only so much I could test and that testing actual strings might not have been the most useful usage of time.  Therefore, I concentrated mainly on the Map and Engine classes.

At its core the terminal based app was designed to take input and with case statements to render the output.  This was the simple part, but the fun part came when I decided to abstract out some of my code mainly the levels classes.  This was important because it would make my logic file much skinnier and allow me to better concentrate on each individual lesson.  After being in Rails for awhile I realized I could do the following to include a separate range of files from a folder.

        lessons = File.join("lessons", "*.rb")
        Dir[File.expand_path(lessons)].each do |file|
        require file
        end

The next interesting part was the idea of setting a `@@LOSE_TOKEN` to signify the losing outcome.  At first I didn't know to use the class variable and I was even a little leery after reading [this](http://joey.aghion.com/instance-variables-class-variables-and-class-instance-variables-in-ruby/).  I understood that I would want to use a class variable in a class that didn't involve any descendants.  This was true for the map class so I was golden.  Another popular usage for class variables is to store [configurations](https://rubymonk.com/learning/books/4-ruby-primer-ascent/chapters/45-more-classes/lessons/113-class-variables/#328).  I made the requisite `lose?` method and I was on my to way losing.  The next interesting part went inside the file for playing.  Here I knew ultimately that there was two states when running through levels.  Play while levels are still to be played and stop when there aren't.  For this I used Ruby's fantastic loop method with a ternary statement as the following.

        loop do
          new_map.scene < Engine::LESSONS.length - 2 ? engine.play : abort("Thats all folks")
        end

The loop here would keep going until the `LESSONS` hash had been cycled through.  `abort()` also allowed me to exit the program when the exit condition had been met.

My ultimate take aways from this are that it is always good to refactor your code because in the long run you are doing yourself and your fellow coders a huge favor.  Also, I learned that Ruby's OOP makes it straightforward when it comes to planning your app or game out.  

You can clone my simple terminal game at 

        https://github.com/trodrigu/adventure_game
        
Thanks for reading!
