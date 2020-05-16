defmodule ListifyWeb.ItemLive.Index do
  use ListifyWeb, :live_view

  alias Listify.Shopping
  alias Listify.Shopping.Item

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :items, fetch_items())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action)}
  end

  defp apply_action(socket, :new) do
    socket
    |> assign(:page_title, "New Item")
    |> assign(:item, %Item{})
  end

  defp apply_action(socket, :index) do
    socket
    |> assign(:page_title, "Listing Items")
    |> assign(:item, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    with {:ok, item = %Item{}} <- Shopping.get_item(id),
         {:ok, item = %Item{}} <- Shopping.delete_item(item) do
      {:noreply,
       socket
       |> assign(:items, fetch_items())
       |> put_flash(:notice, "#{item.name} deleted")}
    else
      {:error, reason} -> {:noreply, put_flash(socket, :error, reason)}
    end
  end

  def handle_event("toggle_taken", %{"id" => id}, socket) do
    with {:ok, item = %Item{}} <- Shopping.get_item(id),
         {:ok, item = %Item{}} <- Shopping.update_item(item, %{taken: !item.taken}) do
      {:noreply,
       socket
       |> assign(:items, fetch_items())
       |> put_flash(:notice, "#{item.name} deleted")}
    else
      {:error, reason} -> {:noreply, put_flash(socket, :error, reason)}
    end
  end

  defp fetch_items do
    Shopping.list_items()
  end
end
