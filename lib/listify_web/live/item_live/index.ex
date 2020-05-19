defmodule ListifyWeb.ItemLive.Index do
  use ListifyWeb, :live_view

  alias Listify.Shopping.Item
  alias ListifyWeb.ShoppingUseCases

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket), do: ShoppingUseCases.subscribe_to_items()

    socket =
      socket
      |> assign(items: fetch_items(params), phx_update: "prepend", params: params)
      |> assign(temporary_assigns: [items: [], phx_update: "prepend"])

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    with {:ok, item = %Item{}} <- ShoppingUseCases.delete_item(id) do
      {:noreply,
       socket
       |> assign(items: ShoppingUseCases.list_items(), phx_update: "replace")
       |> put_flash(:notice, "#{item.name} deleted")}
    else
      {:error, reason} -> {:noreply, put_flash(socket, :error, reason)}
    end
  end

  @impl true
  def handle_event("toggle_taken", params = %{"id" => id}, socket) do
    taken = Map.get(params, "value", false)

    with {:ok, item = %Item{}} <- ShoppingUseCases.update_item(id, %{taken: taken}) do
      {:noreply, assign(socket, items: [item], phx_update: "prepend")}
    else
      {:error, reason} -> {:noreply, put_flash(socket, :error, reason)}
    end
  end

  @impl true
  def handle_info({:deleted_item, _}, socket) do
    {:noreply, assign(socket, items: fetch_items(socket.assigns.params), phx_update: "replace")}
  end

  @impl true
  def handle_info({_, new_item}, socket) do
    {:noreply, assign(socket, items: [new_item], phx_update: "prepend")}
  end

  defp fetch_items(params), do: ShoppingUseCases.list_filtered_and_sorted_items(params)
end
