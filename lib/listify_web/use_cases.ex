defmodule ListifyWeb.UseCases do
  @moduledoc """
  Provides functions useful for multiple use cases, such as parameters' filters.
  """

  @doc """
  Received a map of filters and returns a new map only with the allowed keys and values.
  ## Examples
  iex> ListifyWeb.UseCases.allowed_filters(%{"a" => 1, "b" => 2, "c" => 2}, %{"a" => [0, 1], "c" => [3]})
  %{"a" => 1}
  """
  @spec allowed_filters(map(), map()) :: map()
  def allowed_filters(filters, allowed_values) do
    allowed_keys = Map.keys(allowed_values)

    filters
    |> Enum.filter(fn {key, _value} -> key in allowed_keys end)
    |> Enum.filter(fn {key, value} -> value in Map.get(allowed_values, key) end)
    |> Map.new()
  end
end
