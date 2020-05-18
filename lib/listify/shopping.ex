defmodule Listify.Shopping do
  alias Listify.{Query, Repo}
  alias Listify.Shopping.Item

  @spec list_items() :: [Item.t()]
  def list_items, do: Repo.all(Item)

  def list_filtered_and_sorted_items(filters, order) do
    Item
    |> Query.custom_filters(filters)
    |> Query.order(:inserted_at, order)
    |> Repo.all()
  end

  @spec get_item(binary()) :: {:ok, Item.t()} | {:error, binary()}
  def get_item(id) do
    Item
    |> Repo.get(id)
    |> case do
      nil -> {:error, "The item does not exist"}
      item -> {:ok, item}
    end
  end

  @spec create_item(map()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def create_item(attrs) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_item(Item.t(), map()) :: {:ok, Item.t()} | {:error, Ecto.Changeset.t()}
  def update_item(item = %Item{}, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_item(Item.t()) :: {:ok, Item.t()}
  def delete_item(item = %Item{}), do: Repo.delete(item)

  @spec change_item(Item.t(), map()) :: Ecto.Changeset.t()
  def change_item(item = %Item{}, attrs \\ %{}), do: Item.changeset(item, attrs)
end
