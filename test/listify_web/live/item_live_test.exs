defmodule ListifyWeb.ItemLiveTest do
  use ListifyWeb.ConnCase

  import Listify.Factory
  import Phoenix.LiveViewTest

  alias Listify.Shopping
  alias ListifyWeb.Shopping, as: ShoppingUseCase

  defp create_item(_) do
    item = insert(:item)
    %{item: item}
  end

  describe "Index" do
    setup [:create_item]

    test "lists all items", %{conn: conn, item: item} do
      {:ok, _index_live, html} = live(conn, Routes.item_index_path(conn, :index))

      assert html =~ "Listing Items"
      assert html =~ item.name
    end

    test "saves new item", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))
      invalid_attributes = %{name: ""}
      valid_attributes = %{name: "Some product"}

      assert index_live
             |> form("#item-form", item: invalid_attributes)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#item-form", item: valid_attributes)
        |> render_submit()
        |> follow_redirect(conn, Routes.item_index_path(conn, :index))

      assert html =~ "Item created successfully"
      assert html =~ valid_attributes[:name]
    end

    test "adds new items to the list when it is broadcasted", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))
      ShoppingUseCase.create_item(%{name: "New item"})

      assert render(index_live) =~ "New item"
    end

    test "deletes item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      assert index_live |> element("#item-#{item.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#item-#{item.id}")
    end

    test "removes items when deletion is broadcasted", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))
      ShoppingUseCase.delete_item(item.id)

      refute has_element?(index_live, "#item-#{item.id}")
    end

    test "sets phx_update to prepend if is not deleting", %{conn: conn, item: item} do
      not_deleted_item_one = insert(:item)
      not_deleted_item_two = insert(:item, name: "Not deleted and not updated")
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      assert index_live |> element("#item-#{item.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#item-#{item.id}")

      assert index_live
             |> element("#item_taken-#{not_deleted_item_one.id}")
             |> render_click() =~ not_deleted_item_two.name
    end

    test "failing to deletes item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))
      {:ok, _} = Shopping.delete_item(item)

      assert index_live
             |> element("#item-#{item.id} a", "Delete")
             |> render_click() =~ "The item does not exist"
    end
  end

  describe "Updates item" do
    setup [:create_item]

    test "toggles the taken value when checkbox is clicked", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      index_live
      |> element("#item_taken-#{item.id}")
      |> render_click()

      {:ok, updated_item} = Shopping.get_item(item.id)
      assert updated_item.taken != item.taken
    end

    test "updates the item when its update is broadcasted", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      ShoppingUseCase.update_item(item.id, %{name: "New name"})

      assert has_element?(index_live, "#item-#{item.id}")
      assert render(index_live) =~ "New name"
      refute render(index_live) =~ item.name
    end
  end
end
