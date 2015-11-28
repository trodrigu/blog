Ruby is one interesting beast.  Seriously.  Everything is an object and after realizing this it is easy to see how Ruby is so dynamic.  Utilizing my favorite REPL `pry` I am able to change directory or `cd` into objects and see whats going on.  After my first ventures in reading the book [Metaprogramming Ruby 2](https://pragprog.com/book/ppmetr2/metaprogramming-ruby-2) I am writing this to answer some interesting questions posed in the book.  The first that is what is the class of Object.  At first glance it may seem as though there is no class but that is not actually true.  Object's class is in fact Class!  Out of curiosity I ran the `class` method on different top level objects including `Array`, `Hash`, and `Fixnum` and they all returned `Class`.  This makes sense because every class name is a constant pain... I mean it is a Ruby constant.  Evidence can be found by the camel-casing.  When a new class name is created what is happening is a new object of type `Class` is initiated.  This means that these so called Ruby constant's are all related to their daddy `Class`.

## Module Hierarchy

Now the next question.  What is the `superclass` of `Module`?  The answer is Object!  This seems a bit weird because many would see a Module solely as a name space or a way to mix in new methods in a class.  The truth of the matter is it does fall in a hierarchy.

        Module.ancestors

        => [Module, Object, PP::ObjectMixin, Kernel, BasicObject]

As you can see the Object is at index 1 and falls just above Module.

## Class Of Class?

Somewhat related to the first question, but what is the `class` of `Class`?  What is interesting is that of course it returns `Class`.  The method call to the receiver that is `Class` is in fact just another Ruby constant that references itself!

## Checking out 

After `cd`ing into the `PP` module after shear curiosity I realized that this was a descendant of the `PrettyPrint` class.  Looking at the first method `PP.pp` I see the basic implementation of pretty print.  The second argument however baffled me.  What in the hot sauce is `out=$>`?  Being the curious cat I am I `cd`'d into it and lo and behold it is apart of the `IO` class.  Not only is it apart of the `IO`(Input Output) class but it is a standard output object. Reading the source for the method details that the out when omitted in the args will output as normal like `<code>$></code>` or `<code>STDOUT</code>`.  With the power of tools like `Pry` and the understanding of the Ruby hierarchy with helpful methods like `ancestors`, `class`, `superclass`, `instance_methods(false)`, `grep` and `find-method <method-name> <class-name>` I am excited to continue my Ruby journey of knowledge.
