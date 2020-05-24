defmodule ListifyWeb.ShoppingUseCases do
  alias Ecto.Changeset
  alias Listify.Shopping
  alias Listify.Shopping.Item
  alias Phoenix.PubSub
  import ListifyWeb.UseCases

  @pub_sub_name Listify.PubSub
  @items_topic "items"
  @allowed_filters %{"taken" => ["true", "false"]}

  @spec list_items() :: [Item.t()]
  def list_items, do: Shopping.list_items()

  @spec list_filtered_and_sorted_items(map) :: [Item.t()]
  def list_filtered_and_sorted_items(params) do
    sorting_order =
      params
      |> Map.get("sort")
      |> cast_sorting_order(:desc)

    params
    |> allowed_filters(@allowed_filters)
    |> Shopping.list_filtered_and_sorted_items(sorting_order)
  end

  @spec create_item(map()) :: {:ok, Item.t()} | {:error, Changeset.t()}
  def create_item(attrs) do
    with {:ok, item = %Item{}} <- Shopping.create_item(attrs) do
      broadcast_to_items(item, :new_item)

      {:ok, item}
    end
  end

  @spec update_item(binary(), map()) :: {:error, binary() | Changeset.t()} | {:ok, Item.t()}
  def update_item(id, attrs) do
    with {:ok, item = %Item{}} <- Shopping.get_item(id),
         {:ok, item = %Item{}} <- Shopping.update_item(item, attrs) do
      broadcast_to_items(item, :updated_item)

      {:ok, item}
    end
  end

  @spec delete_item(binary) :: {:ok, Item.t()} | {:error, binary()}
  def delete_item(id) do
    with {:ok, item = %Item{}} <- Shopping.get_item(id),
         {:ok, item = %Item{}} <- Shopping.delete_item(item) do
      broadcast_to_items(item, :deleted_item)

      {:ok, item}
    end
  end

  @spec change_item(Item.t(), map()) :: Ecto.Changeset.t()
  def change_item(item = %Item{}, attrs \\ %{}), do: Shopping.change_item(item, attrs)

  @spec subscribe_to_items :: :ok | {:error, {:already_registered, pid}}
  def subscribe_to_items, do: PubSub.subscribe(@pub_sub_name, @items_topic)

  @spec broadcast_to_items(any(), atom()) :: :ok
  defp broadcast_to_items(message, event),
    do: PubSub.broadcast!(@pub_sub_name, @items_topic, {event, message})
end
