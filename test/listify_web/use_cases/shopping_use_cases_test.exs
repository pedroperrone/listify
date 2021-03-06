defmodule ListifyWeb.ShoppingUseCasesTest do
  use Listify.DataCase, async: true
  import Listify.Factory

  alias Ecto.{Changeset, UUID}
  alias Listify.Repo
  alias Listify.Shopping.Item
  alias ListifyWeb.ShoppingUseCases

  describe "list_items/0" do
    test "return all items" do
      item = insert(:item)

      assert ShoppingUseCases.list_items() == [item]
    end
  end

  describe "list_filtered_and_sorted_items/1" do
    test "filters items by taken when the filter's value is true" do
      taken_item = insert(:item, taken: true)
      _not_taken_item = insert(:item, taken: false)
      params = %{"taken" => "true"}

      assert [taken_item] == ShoppingUseCases.list_filtered_and_sorted_items(params)
    end

    test "filters items by taken when the filter's value is false" do
      _taken_item = insert(:item, taken: true)
      not_taken_item = insert(:item, taken: false)
      params = %{"taken" => "false"}

      assert [not_taken_item] == ShoppingUseCases.list_filtered_and_sorted_items(params)
    end

    test "does not filter items when the params are empty" do
      taken_item = insert(:item, taken: true)
      not_taken_item = insert(:item, taken: false)
      params = %{}

      assert MapSet.new([not_taken_item, taken_item]) ==
               MapSet.new(ShoppingUseCases.list_filtered_and_sorted_items(params))
    end

    test "does not filter items when the filters are not allowed" do
      taken_item = insert(:item, taken: true, name: "Taken")
      not_taken_item = insert(:item, taken: false, name: "Not taken")
      params = %{"name" => "Taken"}

      assert MapSet.new([not_taken_item, taken_item]) ==
               MapSet.new(ShoppingUseCases.list_filtered_and_sorted_items(params))
    end

    test "sorts the items ascendantly when the sort param is asc" do
      oldest_item = insert(:item, inserted_at: Timex.shift(DateTime.utc_now(), minutes: -1))
      newest_item = insert(:item, inserted_at: Timex.shift(DateTime.utc_now(), minutes: 1))
      params = %{"sort" => "asc"}

      assert [oldest_item, newest_item] == ShoppingUseCases.list_filtered_and_sorted_items(params)
    end

    test "sorts the items descendantly when the sort param is desc" do
      oldest_item = insert(:item, inserted_at: Timex.shift(DateTime.utc_now(), minutes: -1))
      newest_item = insert(:item, inserted_at: Timex.shift(DateTime.utc_now(), minutes: 1))
      params = %{"sort" => "desc"}

      assert [newest_item, oldest_item] == ShoppingUseCases.list_filtered_and_sorted_items(params)
    end

    test "sorts the items descendantly when there is no sort param" do
      oldest_item = insert(:item, inserted_at: Timex.shift(DateTime.utc_now(), minutes: -1))
      newest_item = insert(:item, inserted_at: Timex.shift(DateTime.utc_now(), minutes: 1))
      params = %{}

      assert [newest_item, oldest_item] == ShoppingUseCases.list_filtered_and_sorted_items(params)
    end
  end

  describe "create_items/1" do
    test "creates an item when the parameters are valid" do
      attrs = params_for(:item)

      assert {:ok, item = %Item{}} = ShoppingUseCases.create_item(attrs)
    end

    test "broadcasts the new item to the items topic" do
      ShoppingUseCases.subscribe_to_items()
      attrs = params_for(:item)
      {:ok, item = %Item{}} = ShoppingUseCases.create_item(attrs)

      assert_received {:new_item, ^item}
    end

    test "returns an invalid changeset when the parameters are invalid" do
      attrs = %{name: "", taken: false}

      assert {:error, changeset = %Changeset{}} = ShoppingUseCases.create_item(attrs)
      refute changeset.valid?
    end

    test "does not broadcast in errors" do
      attrs = %{name: "", taken: false}
      ShoppingUseCases.create_item(attrs)

      refute_received _any_message
    end
  end

  describe "delete_item/1" do
    test "deletes the item when it exists" do
      item = insert(:item)

      assert {:ok, %Item{}} = ShoppingUseCases.delete_item(item.id)
      assert is_nil(Repo.get(Item, item.id))
    end

    test "broadcasts the deletion of the item" do
      ShoppingUseCases.subscribe_to_items()
      item = insert(:item)
      {:ok, item = %Item{}} = ShoppingUseCases.delete_item(item.id)

      assert_received {:deleted_item, ^item}
    end

    test "returns an error when the item does not exist" do
      assert {:error, "The item does not exist"} == ShoppingUseCases.delete_item(UUID.generate())
    end

    test "does not broadcast in errors" do
      ShoppingUseCases.delete_item(UUID.generate())

      refute_received _any_message
    end
  end

  describe "update_item/2" do
    test "updates an item when it exists and the params are valid" do
      item = insert(:item, taken: false)

      assert {:ok, updated_item = %Item{}} = ShoppingUseCases.update_item(item.id, %{taken: true})
      assert updated_item.id == item.id
      assert updated_item.taken
    end

    test "broadcasts the updated item" do
      ShoppingUseCases.subscribe_to_items()
      item = insert(:item)
      {:ok, item = %Item{}} = ShoppingUseCases.update_item(item.id, %{taken: true})

      assert_received {:updated_item, ^item}
    end

    test "returns an error when the item does not exist" do
      assert {:error, "The item does not exist"} ==
               ShoppingUseCases.update_item(UUID.generate(), %{})
    end

    test "returns an error when the attributes are not valid" do
      item = insert(:item)

      assert {:error, changeset = %Changeset{}} =
               ShoppingUseCases.update_item(item.id, %{name: ""})

      refute changeset.valid?
      assert errors_on(changeset) == %{name: ["can't be blank"]}
    end

    test "does not broadcast in errors" do
      item = insert(:item)
      ShoppingUseCases.update_item(item.id, %{name: ""})

      refute_received _any_message
    end
  end

  describe "change_item/2" do
    test "applies the changeset to an item with the given changes" do
      item = build(:item, taken: false)
      attrs = %{taken: true}
      changeset = ShoppingUseCases.change_item(item, attrs)

      assert changeset.changes == attrs
      assert changeset.data == item
    end
  end

  describe "subscribe_to_items/0" do
    test "subscribe the current process to the items topic" do
      ShoppingUseCases.subscribe_to_items()
      Phoenix.PubSub.broadcast!(Listify.PubSub, "items", "ping")

      assert_received "ping"
    end
  end
end
