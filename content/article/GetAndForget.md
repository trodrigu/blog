+++
title = "Get And Forget"
date = "2016-12-17T12:01:03-08:00"
snippet = "File processing is always an important part of any programming language..."

+++

File processing is always an important part of any programming language.
In Elixir its quite easy with the `IO` and the `File` modules.  The problem at hand was to read in a csv file and then utilize logic to cast all of the keys and values for further calculations (the total with the sales tax).  The csv kinda looked like:

```
id,ship_to,net_amount
123,:NC,50.00
```

The hints given for the methods include to use `IO.stream` along with a `File.read`.  Beginnings looked like:

```
defmodule Sales do

  def calculate_net_amounts_from_file(file_path) do
    {:ok, file } = File.open(file_path, [:read])
    entire_read_file_data = Enum.map IO.stream(file, :line), &make_order/1
    File.close(file)
  end
  
  def make_order(string) do
  end
end
```

Pretty straight forward right?   Cool.  So now I needed to make sure to transform and cast all the input data to make sure all of the calculations could be made correctly.  The next portion involved Elixir's pipeline operator to mold the read data into exactly what I needed looking kind of like:

```
    casted_keyword_list = keyword_list
                            |> cast_id_value
                            |> cast_ship_to_value
                            |> cast_net_amount_value
```

This effort allowed me to turn the `String` data into atom/integer/float types that I need to do the job.  Also utilizing Keyword lists (chosen because of its availability of update methods) helped me to pipe my data into calculating the final *total* amount.  Yea buddy.

```
defmodule Sales do

  def calculate_net_amounts_from_file(file_path) do
    {:ok, file } = File.open(file_path, [:read])
    entire_read_file_data = Enum.map IO.stream(file, :line), &make_order/1
    filtered_read_data = Enum.filter(entire_read_file_data, fn(current_value) -> Enum.count(current_value) > 0 end)
    IO.inspect (filtered_read_data)
    File.close(file)
  end
  
  def make_order("id,ship_to,net_amount\n"), do: []

  def make_order(string) do
    list = String.split(string, ~r{,})
    [id, ship_to, net_amount] = list
    keyword_list = [id: id, ship_to: ship_to, net_amount: net_amount]
    casted_keyword_list = keyword_list
                            |> cast_id_value
                            |> cast_ship_to_value
                            |> cast_net_amount_value

    calculated_net_amounts = add_totals(casted_keyword_list)
  end

  def cast_id_value(keyword_list) do
    {_original, transformed_order_line} = Keyword.get_and_update(keyword_list, :id, fn current_value ->
      { current_value, String.to_integer(current_value) }
    end)
    transformed_order_line
  end

  def cast_ship_to_value(keyword_list) do
    {_original, transformed_order_line} = Keyword.get_and_update(keyword_list, :ship_to, fn current_value ->
      { current_value,
        String.trim_leading(current_value, ":")
          |> String.to_atom
      }
    end)
  transformed_order_line
  end

  def cast_net_amount_value(keyword_list) do
    {_original, transformed_order_line} = Keyword.get_and_update(keyword_list, :net_amount, fn current_value ->
      { current_value,
        String.trim_trailing(current_value)
          |> String.to_float
      }
    end)
  transformed_order_line
  end

  def tax_rates do
    [ NC: 0.075, TX: 0.08 ]
  end

  def add_totals(order) do
    total_amount = order[:net_amount] + (order[:net_amount] * (tax_rates[order[:ship_to]] || 0 ))
    Keyword.put_new(order, :total_amount, total_amount)
  end
end
```

Most importantly what I want you to notice here is the usage of the `get_and_update` function.  At first when I started using it I thought it was kind of weird.  Reasons including that in order for it to work you must return a `Tuple` and not just any `Tuple`, but a `Tuple` that includes the first value being the _original_ value and the second part the entire data structure including the **brand** new do-hickey.  To me it seemed like a bit much to get what I needed (thats what I get from coming from `Ruby` land).  However, I realized that the beauty of this is that since we are having to include that _original_ dude we are having a helper in the fight against bugs.  Debugging will be an x-amount easier because we will know at this point _exactly_ where we _were_.  Super cool.  Dope.  Also you just pattern match the data you need out and you are *solid*.

```
defmodule Sales do

  def calculate_net_amounts_from_file(file_path) do
    {:ok, file } = File.open(file_path, [:read])
    entire_read_file_data = Enum.map IO.stream(file, :line), &make_order/1
    filtered_read_data = Enum.filter(entire_read_file_data, fn(current_value) -> Enum.count(current_value) > 0 end)
    IO.inspect (filtered_read_data)
    File.close(file)
  end
  
  def make_order("id,ship_to,net_amount\n"), do: []

  def make_order(string) do
    list = String.split(string, ~r{,})
    [id, ship_to, net_amount] = list
    keyword_list = [id: id, ship_to: ship_to, net_amount: net_amount]
    casted_keyword_list = keyword_list
                            |> cast_id_value
                            |> cast_ship_to_value
                            |> cast_net_amount_value

    calculated_net_amounts = add_totals(casted_keyword_list)
  end

  def cast_id_value(keyword_list) do
    {_original, transformed_order_line} = Keyword.get_and_update(keyword_list, :id, fn current_value ->
      { current_value, String.to_integer(current_value) }
    end)
    transformed_order_line
  end

  def cast_ship_to_value(keyword_list) do
    {_original, transformed_order_line} = Keyword.get_and_update(keyword_list, :ship_to, fn current_value ->
      { current_value,
        String.trim_leading(current_value, ":")
          |> String.to_atom
      }
    end)
  transformed_order_line
  end

  def cast_net_amount_value(keyword_list) do
    {_original, transformed_order_line} = Keyword.get_and_update(keyword_list, :net_amount, fn current_value ->
      { current_value,
        String.trim_trailing(current_value)
          |> String.to_float
      }
    end)
  transformed_order_line
  end

  def tax_rates do
    [ NC: 0.075, TX: 0.08 ]
  end

  def add_totals(order) do
    total_amount = order[:net_amount] + (order[:net_amount] * (tax_rates[order[:ship_to]] || 0 ))
    Keyword.put_new(order, :total_amount, total_amount)
  end
end
```

Now we have calculated totals and we can charge and make that cash.
