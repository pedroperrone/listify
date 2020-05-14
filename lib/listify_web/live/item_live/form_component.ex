defmodule ListifyWeb.ItemLive.FormComponent do
  use ListifyWeb, :live_component

  alias Listify.Shopping
  alias Listify.Shopping.Item

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_clean_item()}
  end

  @impl true
  def handle_event("validate", %{"item" => item_params}, socket) do
    changeset =
      socket.assigns.item
      |> Shopping.change_item(item_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    case Shopping.create_item(item_params) do
      {:ok, _item} ->
        {:noreply,
         socket
         |> assign_clean_item()
         |> put_flash(:info, "Item created successfully")
         |> push_redirect(to: Routes.item_index_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp assign_clean_item(socket) do
    new_item = %Item{}
    changeset = Shopping.change_item(new_item)

    assign(socket, item: new_item, changeset: changeset)
  end
end
