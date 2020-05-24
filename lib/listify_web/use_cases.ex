defmodule ListifyWeb.UseCases do
  @moduledoc """
  Provides functions useful for multiple use cases, such as parameters' filters.
  """

  @type sorting_order :: :asc | :desc

  @doc """
  Receives a map of filters and returns a new map only with the allowed keys and values.
  ## Examples
  iex> ListifyWeb.UseCases.allowed_filters(%{"a" => 1, "b" => 2, "c" => 2}, %{"a" => [0, 1], "c" => [3]})
  %{"a" => 1}
  """
  @spec allowed_filters(map(), map()) :: map()
  def allowed_filters(filters, allowed_values) do
    filters
    |> Enum.filter(fn {key, value} -> value in Map.get(allowed_values, key, []) end)
    |> Map.new()
  end

  @doc """
  Casts parameters for a valid sorting order (:asc or :desc).
  """
  @spec cast_sorting_order(binary(), sorting_order()) :: sorting_order()
  def cast_sorting_order("asc", _default), do: :asc
  def cast_sorting_order("desc", _default), do: :desc
  def cast_sorting_order(_, default), do: default
end
