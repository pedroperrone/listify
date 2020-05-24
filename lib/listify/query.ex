defmodule Listify.Query do
  import Ecto.Query

  def order(queriable, attribute, order \\ :asc), do: order_by(queriable, [{^order, ^attribute}])

  def custom_filters(queriable, filters), do: Enum.reduce(filters, queriable, &custom_query/2)

  defp custom_query({key, value}, queriable) when is_bitstring(key),
    do: custom_query({String.to_existing_atom(key), value}, queriable)

  defp custom_query({key, values}, queriable) when is_list(values) do
    from(element in queriable, where: field(element, ^String.to_existing_atom(key)) in ^values)
  end

  defp custom_query({key, value}, queriable),
    do: from(element in queriable, where: field(element, ^key) == ^value)
end
