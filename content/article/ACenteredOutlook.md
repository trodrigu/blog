+++
date = "2016-11-28T21:19:39-08:00"
title = "A Centered Outlook"
snippet = "Getting further acquainted with Elixir's single quoted counterpart the double quoted string has allowed me..."

+++

Getting further acquainted with Elixir's single quoted counterpart the double quoted string has allowed me
to become better in touch with much more of the `Enum`, `String` and `Float` modules.  They each pack a punch
of an assortment of monkeys that are ready to be unpacked from its barrel with the flash of a Dash Doc.

## Simple Exercise

Take in a list of strings (in Elixir a string by default is double quoted) like [ "cat", "zebra", "elephant" ]
and produce a lovely pyramid of balance out of them looking like

```
  cat
 zebra
elephant
```

After glancing through the chapter on 'Double-Quoted Strings Are Binaries' I noticed the useful `String.pad_leading` and the matching
`String.pad_trailing`.  I new these were the tickets.  Also, I wanted to use something like `Enum.map`, but at this time I couldn't 
figure how to coerce the `map` to do so in a nice way.  That's why I reached into Elixir's handy toolbox for easy iterative recursion.
Said recursion is easily setup with the pattern matching the exit condition as follows

```
defmodule Format do
  def center(list) do
  end


  defp _center(_, _, acc \\ [])

  defp _center([], _, acc), do: acc

  defp _center([ head | tail ], longest_word_length, acc) do
  end
end
```

## Sorting out sorting

Next, I needed to ensure the list was sorted to find the greatest length word.
I thought I could just use the `Enum.sort` as it is but it gave me results that didn't
agree with me.  Therefore, I passed it an anonymous function utilizing the 
`Kernel.byte_site` method to specify the sort.

```
  ...
  sorted_list = Enum.sort(list, &(Kernel.byte_size(&1) > Kernel.byte_size(&2)))
  ...
```

Another thing that I encountered was needing a way to coerce a `Float` into in `Integer`.
I had to resort to the following hack charade to accomplish producing the count argument
for the calls to `pad_leading` and `pad_trailing`.

```
  ...
  half_padding = Float.floor(total_padding / 2)
                   |> Float.to_string
                   |> String.first
                   |> String.to_integer
  ...
```

# Nice Accumulator

Other than that business as usual utilizing an accumulator for producing the list of padded strings.
This is the full thing.

```
defmodule Format do
  def center(list) do
    sorted_list = Enum.sort(list, &(Kernel.byte_size(&1) > Kernel.byte_size(&2)))
    [ head | _ ] = sorted_list
    longest_word_length = String.length(head)
    reversed_sorted_list = Enum.reverse(sorted_list)
    padded_list = _center(reversed_sorted_list, longest_word_length)
    joined_padded_list = Enum.join(Enum.reverse(padded_list), "\n")
    IO.puts(joined_padded_list)
  end

  defp _center(_, _, acc \\ [])

  defp _center([], _, acc), do: acc

  defp _center([ head | tail ], longest_word_length, acc) do
    word_length = String.length(head)
    total_padding = longest_word_length - word_length
    half_padding = Float.floor(total_padding / 2)
                   |> Float.to_string
                   |> String.first
                   |> String.to_integer
    left_padded_word = String.pad_leading(head, half_padding + word_length)
    full_padded_word = String.pad_trailing(left_padded_word, (2 * half_padding + word_length))
    acc = [ full_padded_word | acc ]
    _center(tail, longest_word_length, acc)
  end
end
```
