# defmodule ListifyWeb.ItemLiveTest do
#   use ListifyWeb.ConnCase

#   import Phoenix.LiveViewTest

#   alias Listify.Shopping

#   @create_attrs %{name: "some name", taken: true}
#   @update_attrs %{name: "some updated name", taken: false}
#   @invalid_attrs %{name: nil, taken: nil}

#   defp fixture(:item) do
#     {:ok, item} = Shopping.create_item(@create_attrs)
#     item
#   end

#   defp create_item(_) do
#     item = fixture(:item)
#     %{item: item}
#   end

#   describe "Index" do
#     setup [:create_item]

#     test "lists all items", %{conn: conn, item: item} do
#       {:ok, _index_live, html} = live(conn, Routes.item_index_path(conn, :index))

#       assert html =~ "Listing Items"
#       assert html =~ item.name
#     end

#     test "saves new item", %{conn: conn} do
#       {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

#       assert index_live |> element("a", "New Item") |> render_click() =~
#         "New Item"

#       assert_patch(index_live, Routes.item_index_path(conn, :new))

#       assert index_live
#              |> form("#item-form", item: @invalid_attrs)
#              |> render_change() =~ "can&apos;t be blank"

#       {:ok, _, html} =
#         index_live
#         |> form("#item-form", item: @create_attrs)
#         |> render_submit()
#         |> follow_redirect(conn, Routes.item_index_path(conn, :index))

#       assert html =~ "Item created successfully"
#       assert html =~ "some name"
#     end

#     test "updates item in listing", %{conn: conn, item: item} do
#       {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

#       assert index_live |> element("#item-#{item.id} a", "Edit") |> render_click() =~
#         "Edit Item"

#       assert_patch(index_live, Routes.item_index_path(conn, :edit, item))

#       assert index_live
#              |> form("#item-form", item: @invalid_attrs)
#              |> render_change() =~ "can&apos;t be blank"

#       {:ok, _, html} =
#         index_live
#         |> form("#item-form", item: @update_attrs)
#         |> render_submit()
#         |> follow_redirect(conn, Routes.item_index_path(conn, :index))

#       assert html =~ "Item updated successfully"
#       assert html =~ "some updated name"
#     end

#     test "deletes item in listing", %{conn: conn, item: item} do
#       {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

#       assert index_live |> element("#item-#{item.id} a", "Delete") |> render_click()
#       refute has_element?(index_live, "#item-#{item.id}")
#     end
#   end

#   describe "Show" do
#     setup [:create_item]

#     test "displays item", %{conn: conn, item: item} do
#       {:ok, _show_live, html} = live(conn, Routes.item_show_path(conn, :show, item))

#       assert html =~ "Show Item"
#       assert html =~ item.name
#     end

#     test "updates item within modal", %{conn: conn, item: item} do
#       {:ok, show_live, _html} = live(conn, Routes.item_show_path(conn, :show, item))

#       assert show_live |> element("a", "Edit") |> render_click() =~
#         "Edit Item"

#       assert_patch(show_live, Routes.item_show_path(conn, :edit, item))

#       assert show_live
#              |> form("#item-form", item: @invalid_attrs)
#              |> render_change() =~ "can&apos;t be blank"

#       {:ok, _, html} =
#         show_live
#         |> form("#item-form", item: @update_attrs)
#         |> render_submit()
#         |> follow_redirect(conn, Routes.item_show_path(conn, :show, item))

#       assert html =~ "Item updated successfully"
#       assert html =~ "some updated name"
#     end
#   end
# end
