defmodule Listify.ShoppingTest do
  use Listify.DataCase, async: true
  import Listify.Factory

  alias Ecto.{Changeset, UUID}
  alias Listify.Shopping
  alias Listify.Shopping.Item

  describe "list_items/0" do
    test "returns all items" do
      item = insert(:item)

      assert [item] == Shopping.list_items()
    end
  end

  describe "list_filtered_and_sorted_items/2" do
    test "should apply the filters correctly" do
      taken_item_one = insert(:item, taken: true, inserted_at: DateTime.utc_now())

      taken_item_two =
        insert(:item, taken: true, inserted_at: Timex.shift(DateTime.utc_now(), minutes: 1))

      taken_item_three =
        insert(:item, taken: true, inserted_at: Timex.shift(DateTime.utc_now(), minutes: 2))

      _not_taken_item = insert(:item, taken: false)

      fetched_items = Shopping.list_filtered_and_sorted_items(%{"taken" => true}, :desc)

      assert fetched_items == [taken_item_three, taken_item_two, taken_item_one]
    end

    test "should sort ascendantly when the param is :asc" do
      taken_item_one = insert(:item, taken: true, inserted_at: DateTime.utc_now())

      taken_item_two =
        insert(:item, taken: true, inserted_at: Timex.shift(DateTime.utc_now(), minutes: 1))

      taken_item_three =
        insert(:item, taken: true, inserted_at: Timex.shift(DateTime.utc_now(), minutes: 2))

      fetched_items = Shopping.list_filtered_and_sorted_items(%{"taken" => true}, :asc)

      assert fetched_items == [taken_item_one, taken_item_two, taken_item_three]
    end
  end

  describe "get_item/1" do
    test "returns the item when it exists" do
      item = insert(:item)

      assert {:ok, fetched_item} = Shopping.get_item(item.id)
      assert fetched_item.id == item.id
    end

    test "returns an error when the item does not exist" do
      assert {:error, "The item does not exist"} == Shopping.get_item(UUID.generate())
    end
  end

  describe "create_item/1" do
    test "creates a new item when the parameters are valid" do
      params = params_for(:item)

      assert {:ok, %Item{}} = Shopping.create_item(params)
    end

    test "returns an invalid changeset when the parameters are invalid" do
      params = params_for(:item, name: nil)

      assert {:error, changeset = %Changeset{}} = Shopping.create_item(params)
      refute changeset.valid?
      assert errors_on(changeset) == %{name: ["can't be blank"]}
    end
  end

  describe "update_item/2" do
    test "updates an item when the parameters are valid" do
      item = insert(:item, taken: false)
      params = %{taken: true}

      assert {:ok, updated_item = %Item{}} = Shopping.update_item(item, params)
      assert item.id == updated_item.id
      assert updated_item.taken
    end

    test "returns an invalid changeset when the parameters are invalid" do
      item = insert(:item)
      params = %{name: nil}

      assert {:error, changeset = %Changeset{}} = Shopping.update_item(item, params)
      refute changeset.valid?
      assert errors_on(changeset) == %{name: ["can't be blank"]}
    end
  end

  describe "delete_item/1" do
    test "return the deleted entity" do
      item = insert(:item)

      assert {:ok, deleted_item = %Item{}} = Shopping.delete_item(item)
      assert deleted_item.id == item.id
    end
  end

  describe "change_item/1" do
    test "return a changeset applying the attributes" do
      item = insert(:item, taken: false)
      changeset = %Changeset{} = Shopping.change_item(item, %{taken: true})

      assert changeset.data == item
      assert changeset.changes == %{taken: true}
    end
  end
end
