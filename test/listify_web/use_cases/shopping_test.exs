defmodule ListifyWeb.ShoppingTest do
  use Listify.DataCase, async: true
  import Listify.Factory

  alias Ecto.{Changeset, UUID}
  alias Listify.Repo
  alias Listify.Shopping.Item
  alias ListifyWeb.Shopping

  describe "list_items/0" do
    test "return all items" do
      item = insert(:item)

      assert Shopping.list_items() == [item]
    end
  end

  describe "create_items/1" do
    test "creates an item when the parameters are valid" do
      attrs = params_for(:item)

      assert {:ok, item = %Item{}} = Shopping.create_item(attrs)
    end

    test "returns an invalid changeset when the parameters are invalid" do
      attrs = %{name: "", taken: false}

      assert {:error, changeset = %Changeset{}} = Shopping.create_item(attrs)
      refute changeset.valid?
    end
  end

  describe "delete_item/1" do
    test "deletes the item when it exists" do
      item = insert(:item)

      assert {:ok, %Item{}} = Shopping.delete_item(item.id)
      assert is_nil(Repo.get(Item, item.id))
    end

    test "returns an error when the item does not exist" do
      assert {:error, "The item does not exist"} == Shopping.delete_item(UUID.generate())
    end
  end

  describe "update_item/2" do
    test "updates an item when it exists and the params are valid" do
      item = insert(:item, taken: false)

      assert {:ok, updated_item = %Item{}} = Shopping.update_item(item.id, %{taken: true})
      assert updated_item.id == item.id
      assert updated_item.taken
    end

    test "returns an error when the item does not exist" do
      assert {:error, "The item does not exist"} == Shopping.update_item(UUID.generate(), %{})
    end

    test "returns an error when the attributes are not valid" do
      item = insert(:item)
      assert {:error, changeset = %Changeset{}} = Shopping.update_item(item.id, %{name: ""})

      refute changeset.valid?
      assert errors_on(changeset) == %{name: ["can't be blank"]}
    end
  end

  describe "change_item/2" do
    test "applies the changeset to an item with the given changes" do
      item = build(:item, taken: false)
      attrs = %{taken: true}
      changeset = Shopping.change_item(item, attrs)

      assert changeset.changes == attrs
      assert changeset.data == item
    end
  end
end
