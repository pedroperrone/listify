defmodule ListifyWeb.ItemController do
  use ListifyWeb, :controller

  alias ListifyWeb.ShoppingUseCases

  def index(conn, params) do
    items = ShoppingUseCases.list_filtered_and_sorted_items(params)

    conn
    |> put_status(:ok)
    |> render("index.json", %{items: items})
  end
end
