defmodule ListifyWeb.ItemLive.Index do
  use ListifyWeb, :live_view

  alias Listify.Shopping
  alias Listify.Shopping.Item

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(items: fetch_items(), phx_update: "prepend")
      |> assign(temporary_assigns: [items: [], phx_update: "prepend"])

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    with {:ok, item = %Item{}} <- Shopping.get_item(id),
         {:ok, item = %Item{}} <- Shopping.delete_item(item) do
      {:noreply,
       socket
       |> assign(items: fetch_items(), phx_update: "replace")
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
       |> assign(items: [item], phx_update: "prepend")
       |> put_flash(:notice, "#{item.name} deleted")}
    else
      {:error, reason} -> {:noreply, put_flash(socket, :error, reason)}
    end
  end

  defp fetch_items do
    Shopping.list_items()
  end
end
