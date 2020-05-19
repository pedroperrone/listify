defmodule ListifyWeb.ItemLiveTest do
  use ListifyWeb.ConnCase, async: true

  import Listify.Factory
  import Phoenix.LiveViewTest

  alias Listify.Shopping
  alias ListifyWeb.ShoppingUseCases

  defp create_item(_) do
    item = insert(:item, inserted_at: Timex.shift(DateTime.utc_now(), minutes: -1))
    %{item: item}
  end

  describe "Index" do
    setup [:create_item]

    test "lists all items sorted by most recent first by default", %{conn: conn, item: item} do
      taken_item =
        insert(:item,
          taken: true,
          inserted_at: Timex.shift(DateTime.utc_now(), minutes: 1),
          name: "Taken item"
        )

      {:ok, _index_live, html} = live(conn, Routes.item_index_path(conn, :index))

      assert html =~ "Listing Items"
      assert_html_includes_strings_in_order(html, [taken_item.name, item.name])
    end

    test "lists all items sorted by least recent if param is sent", %{conn: conn, item: item} do
      taken_item =
        insert(:item,
          taken: true,
          inserted_at: Timex.shift(DateTime.utc_now(), minutes: 1),
          name: "Taken item"
        )

      {:ok, _index_live, html} =
        live(conn, Routes.item_index_path(conn, :index, %{"sort" => "asc"}))

      assert html =~ "Listing Items"
      assert_html_includes_strings_in_order(html, [item.name, taken_item.name])
    end

    test "lists only taken items if the filter param is sent", %{conn: conn, item: item} do
      taken_item =
        insert(:item,
          taken: true,
          inserted_at: Timex.shift(DateTime.utc_now(), minutes: 1),
          name: "Taken item"
        )

      {:ok, _index_live, html} =
        live(conn, Routes.item_index_path(conn, :index, %{"taken" => "true"}))

      assert html =~ taken_item.name
      refute html =~ item.name
    end

    test "lists only not taken items if the filter param is sent", %{conn: conn, item: item} do
      taken_item =
        insert(:item,
          taken: true,
          inserted_at: Timex.shift(DateTime.utc_now(), minutes: 1),
          name: "Taken item"
        )

      {:ok, _index_live, html} =
        live(conn, Routes.item_index_path(conn, :index, %{"taken" => "false"}))

      assert html =~ item.name
      refute html =~ taken_item.name
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
      ShoppingUseCases.create_item(%{name: "New item"})

      assert render(index_live) =~ "New item"
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

      ShoppingUseCases.update_item(item.id, %{name: "New name"})

      assert has_element?(index_live, "#item-#{item.id}")
      assert render(index_live) =~ "New name"
      refute render(index_live) =~ item.name
    end
  end

  describe "Deletes item" do
    setup [:create_item]

    test "deletes item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      assert index_live |> element("#item-#{item.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#item-#{item.id}")
    end

    test "removes items when deletion is broadcasted", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))
      ShoppingUseCases.delete_item(item.id)

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

  def assert_html_includes_strings_in_order(html, strings) do
    regex =
      strings
      |> Enum.join(".*")
      |> Regex.compile!()

    assert html =~ regex
  end
end
