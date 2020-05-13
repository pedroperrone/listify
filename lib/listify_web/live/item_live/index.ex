defmodule ListifyWeb.ItemLive.Index do
  use ListifyWeb, :live_view

  alias Listify.Shopping
  alias Listify.Shopping.Item

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :items, fetch_items())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Item")
    |> assign(:item, Shopping.get_item!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Item")
    |> assign(:item, %Item{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Items")
    |> assign(:item, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Shopping.get_item!(id)
    {:ok, _} = Shopping.delete_item(item)

    {:noreply, assign(socket, :items, fetch_items())}
  end

  defp fetch_items do
    Shopping.list_items()
  end
end
