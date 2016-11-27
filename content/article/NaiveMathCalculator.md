+++
date = "2016-11-26T19:19:11-08:00"
title = "Naive Math Calculator"
snippet = "Elixir.  It is our responsibility as technologists to feel around and try new things every day."

+++
Elixir.  It is our responsibility as technologists to feel around and try new things every day.
I decided to take foot and invest the $25 dollars on the 'Programming Elixir' book by Paul Thomas.
I can definitely say that this is money well spent.  I have been delighted and blown away by the
different ways a programmer can achieve solutions utilizing Elixir's built in pattern matching,
easy tail recursion, built in guard clauses, list comprehensions, shorthands for anonymous function, easy defaults,
concurrent processes and so much more!

I decided that I want to talk a little about my naive solution for the last exercise of the strings
and binaries section.  The problem involves writing a method that can take a `List` of characters more commonly known as a single quoted string in Elixir and process/parse simple arithmetic in it.  Yep like a glorified calculator that would calculate the result of the input `'1 + 1'`.

The things that I talked about above that I am utilizing include the build guard clauses, easy defaults, and recursion.  I began by writing a simple top level method to be called `calculate` inside of my `Math` module.  This looked like:

```
defmodule Math do

  def calculate(list) do
  end
end
```

I knew I would need to parse a list so I set the argument to be called list.  The next thing I new I would need to do would be to split up this list.  I attempted to do the common `[0]` access method we all keep near and dear to our hearts in `JS` or `Ruby`, but I was not successful.
A quick look at the docks led me to the `Enum` method called `split_while`.  This would fit perfect when iterating recursively through all the characters of `'1 + 1'`.  Now I just had to empower Elixir's power of recursion to to get me through the list of characters such as:

```
defmodule Math do

  def calculate(list) do
    _split_up_list(list)
  end

  defp _split_up_list(_, acc \\ [])

  defp _split_up_list([], acc), do: acc

  defp _split_up_list([ head | tail ], acc) when head != ?\s do
  end

  defp _split_up_list([ head | tail ], acc) when head == ?\s do
  end
end
```

A couple of other things are introduced in the above including the usage of the default for the `acc` short for accumulator.  Honestly, I am not a huge fan of abbreviated variables, but for this book and the code I read I am attempting to follow suit.
Another thing is the `defp` keyword for declaring a private method.  Great for organizing a consistent API for the interface of you module.  The appearance of the `[ head | tail]` in the arguments is Elixir's powerful pattern matching capabilities pulling out the `head` or the first element of the list and then the `tail` or a list of the rest of the elements.  I am doing this to use the guard clauses for detecting whether or not there is an empty string.
The next parts I filled in with the proper methods to access elements in a list (`Kernel.elem`) and utilized the accumulator to build a list of elements to pass to a function to dynamically evaluate my math statement.  After finding the `Kernel.apply` method I was home free and my naive solution was finally completed:

```
defmodule Math do

  def calculate(list) do
    split_up_list = _split_up_list(list)
    eval_math(split_up_list)
  end

  defp eval_math(list) do
    operator = Enum.at(list, 1)
    args = [ Enum.at(list, 2), Enum.at(list, 0) ]
    apply(Kernel, operator, args)
  end
  
  defp _split_up_list(_, acc \\ [])

  defp _split_up_list([], acc), do: acc 

  defp _split_up_list([ head | tail ], acc) when head != ?\s do
    list = [ head | tail ]
    split_tuple = Enum.split_while(list, &(&1 != ?\s))
    first_part = elem(split_tuple, 0)
    primitive_first_part = if first_part == '+' || first_part == '-' || first_part == '*' || first_part == '/' do
                             List.to_atom(first_part)
                           else
                             List.to_integer(first_part)
                           end
    second_part = elem(split_tuple, 1)
    acc = [ primitive_first_part | acc ]
    _split_up_list(second_part, acc)
  end

  defp _split_up_list([ head | tail ], acc) when head == ?\s do
    list = [ head | tail ]
    split_tuple = Enum.split_while(list, &(&1 == ?\s))
    # throw away first part which is empty string
    second_part = elem(split_tuple, 1)
    _split_up_list(second_part, acc)
  end
end
```

Yea! Elixir is way awesome.
