defmodule ListifyWeb.ItemLiveTest do
  use ListifyWeb.ConnCase

  import Listify.Factory
  import Phoenix.LiveViewTest

  alias Listify.Shopping

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

    test "deletes item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      assert index_live |> element("#item-#{item.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#item-#{item.id}")
    end

    test "failing to deletes item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))
      {:ok, _} = Shopping.delete_item(item)

      assert index_live
             |> element("#item-#{item.id} a", "Delete")
             |> render_click() =~ "The item does not exist"
    end
  end
end
