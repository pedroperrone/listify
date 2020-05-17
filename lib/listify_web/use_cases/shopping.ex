defmodule ListifyWeb.Shopping do
  alias Ecto.Changeset
  alias Listify.Shopping
  alias Listify.Shopping.Item

  @spec list_items() :: [Item.t()]
  def list_items, do: Shopping.list_items()

  @spec create_item(map()) :: {:ok, Item.t()} | {:error, Changeset.t()}
  def create_item(attrs), do: Shopping.create_item(attrs)

  @spec update_item(binary(), map()) :: {:error, binary() | Changeset.t()} | {:ok, Item.t()}
  def update_item(id, attrs) do
    with {:ok, item = %Item{}} <- Shopping.get_item(id) do
      Shopping.update_item(item, attrs)
    end
  end

  @spec delete_item(binary) :: {:ok, Item.t()} | {:error, binary()}
  def delete_item(id) do
    with {:ok, item = %Item{}} <- Shopping.get_item(id) do
      Shopping.delete_item(item)
    end
  end

  @spec change_item(Item.t(), map()) :: Ecto.Changeset.t()
  def change_item(item = %Item{}, attrs \\ %{}), do: Shopping.change_item(item, attrs)
end
