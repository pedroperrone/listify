defmodule ListifyWeb.ItemController do
  use ListifyWeb, :controller

  alias ListifyWeb.ShoppingUseCases

  action_fallback(ListifyWeb.FallbackController)

  def index(conn, params) do
    items = ShoppingUseCases.list_filtered_and_sorted_items(params)

    conn
    |> put_status(:ok)
    |> render("index.json", %{items: items})
  end

  def create(conn, params) do
    with {:ok, item} <- ShoppingUseCases.create_item(params) do
      conn
      |> put_status(:created)
      |> render("show.json", %{item: item})
    end
  end

  def update(conn, params = %{"id" => item_id}) do
    with {:ok, item} <- ShoppingUseCases.update_item(item_id, params) do
      conn
      |> put_status(:ok)
      |> render("show.json", %{item: item})
    end
  end
end
