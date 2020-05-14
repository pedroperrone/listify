defmodule Listify.Shopping.ItemTest do
  use Listify.DataCase, async: true
  import Listify.Factory

  alias Listify.Shopping.Item

  describe "changeset/2" do
    test "return a valid changeset for valid parameters" do
      params = params_for(:item)
      changeset = Item.changeset(%Item{}, params)

      assert changeset.valid?
    end

    test "does not allow an empty name" do
      params = params_for(:item, name: "")
      changeset = Item.changeset(%Item{}, params)

      refute changeset.valid?
      assert errors_on(changeset) == %{name: ["can't be blank"]}
    end
  end
end
