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

    test "adds new items to the list when it is broadcasted and there are no filters", %{
      conn: conn
    } do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))
      ShoppingUseCases.create_item(%{name: "New item"})

      assert render(index_live) =~ "New item"
    end

    test "adds new items to the list when it is broadcasted, the item is not taken and the filter " <>
           "is not taken",
         %{conn: conn} do
      {:ok, index_live, _html} =
        live(conn, Routes.item_index_path(conn, :index, %{"taken" => "false"}))

      ShoppingUseCases.create_item(%{name: "New item"})

      assert render(index_live) =~ "New item"
    end

    test "does not add new items to the list when it is broadcasted, the item is taken and the " <>
           "filter is not taken",
         %{conn: conn} do
      {:ok, index_live, _html} =
        live(conn, Routes.item_index_path(conn, :index, %{"taken" => "false"}))

      ShoppingUseCases.create_item(%{name: "New item", taken: true})

      refute render(index_live) =~ "New item"
    end

    test "adds new items to the list when it is broadcasted, the item is taken and the filter " <>
           "is taken",
         %{conn: conn} do
      {:ok, index_live, _html} =
        live(conn, Routes.item_index_path(conn, :index, %{"taken" => "true"}))

      ShoppingUseCases.create_item(%{name: "New item", taken: true})

      assert render(index_live) =~ "New item"
    end

    test "does not add new items to the list when it is broadcasted, the item is not taken and the " <>
           "filter is taken",
         %{conn: conn} do
      {:ok, index_live, _html} =
        live(conn, Routes.item_index_path(conn, :index, %{"taken" => "true"}))

      ShoppingUseCases.create_item(%{name: "New item", taken: false})

      refute render(index_live) =~ "New item"
    end

    test "patches the view and filter only taken items when the filter changes to taken", %{
      conn: conn,
      item: not_taken_item
    } do
      taken_item = insert(:item, taken: true, name: "Taken item")

      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      rendered_view =
        index_live
        |> element("#item-filters")
        |> render_change(%{filters: %{taken: true}})

      assert rendered_view =~ taken_item.name
      refute rendered_view =~ not_taken_item.name

      assert_patch(index_live, "/items?sort=desc&taken=true")
    end

    test "patches the view and filter only not taken items when the filter changes to not taken",
         %{
           conn: conn,
           item: not_taken_item
         } do
      taken_item = insert(:item, taken: true, name: "Taken item")

      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      rendered_view =
        index_live
        |> element("#item-filters")
        |> render_change(%{filters: %{taken: false}})

      refute rendered_view =~ taken_item.name
      assert rendered_view =~ not_taken_item.name

      assert_patch(index_live, "/items?sort=desc&taken=false")
    end

    test "patches the view and sort desc when the filter changes", %{
      conn: conn,
      item: not_taken_item
    } do
      taken_item =
        insert(:item,
          taken: true,
          name: "Taken item",
          inserted_at: Timex.shift(DateTime.utc_now(), minutes: 5)
        )

      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      index_live
      |> element("#item-filters")
      |> render_change(%{filters: %{sort: "desc"}})
      |> assert_html_includes_strings_in_order([taken_item.name, not_taken_item.name])

      assert_patch(index_live, "/items?sort=desc&taken=")
    end

    test "patches the view and sort asc when the filter changes", %{
      conn: conn,
      item: not_taken_item
    } do
      taken_item =
        insert(:item,
          taken: true,
          name: "Taken item",
          inserted_at: Timex.shift(DateTime.utc_now(), minutes: 5)
        )

      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      index_live
      |> element("#item-filters")
      |> render_change(%{filters: %{sort: "asc"}})
      |> assert_html_includes_strings_in_order([not_taken_item.name, taken_item.name])

      assert_patch(index_live, "/items?sort=asc&taken=")
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

    test "adds the item to the list when it filters taken items and an item is updated to taken",
         %{conn: conn} do
      not_taken_item = insert(:item, taken: false, name: "Not taken")

      {:ok, index_live, _html} =
        live(conn, Routes.item_index_path(conn, :index, %{"taken" => "true"}))

      refute has_element?(index_live, "item-#{not_taken_item.id}")

      {:ok, _} = ShoppingUseCases.update_item(not_taken_item.id, %{taken: true})
      assert render(index_live) =~ not_taken_item.name
    end

    test "removes the item from the list when it is updated to not taken and the filter is taken",
         %{conn: conn} do
      taken_item = insert(:item, taken: true, name: "Taken item")

      {:ok, index_live, _html} =
        live(conn, Routes.item_index_path(conn, :index, %{"taken" => "true"}))

      assert render(index_live) =~ taken_item.name

      {:ok, _} = ShoppingUseCases.update_item(taken_item.id, %{taken: false})
      refute render(index_live) =~ taken_item.name
    end

    test "adds the item to the list when it filters not taken items and an item is updated to not taken",
         %{conn: conn} do
      taken_item = insert(:item, taken: true, name: "Taken item")

      {:ok, index_live, _html} =
        live(conn, Routes.item_index_path(conn, :index, %{"taken" => "false"}))

      refute has_element?(index_live, "item-#{taken_item.id}")

      {:ok, _} = ShoppingUseCases.update_item(taken_item.id, %{taken: false})
      assert render(index_live) =~ taken_item.name
    end

    test "removes the item from the list when it is updated to taken and the filter is not taken",
         %{conn: conn} do
      not_taken_item = insert(:item, taken: false, name: "Not taken item")

      {:ok, index_live, _html} =
        live(conn, Routes.item_index_path(conn, :index, %{"taken" => "false"}))

      assert render(index_live) =~ not_taken_item.name

      {:ok, _} = ShoppingUseCases.update_item(not_taken_item.id, %{taken: true})
      refute render(index_live) =~ not_taken_item.name
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
