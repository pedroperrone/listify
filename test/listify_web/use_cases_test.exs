defmodule ListifyWeb.UseCasesTest do
  use Listify.DataCase, async: true

  alias ListifyWeb.UseCases

  describe "allowed_filters/2" do
    test "should remove not allowed keys" do
      allowed_values = %{"allowed" => ["allowed_value", "allowed_value_two"]}
      filters = %{"not_allowed_key" => "some value", "allowed" => "allowed_value"}

      assert %{"allowed" => "allowed_value"} == UseCases.allowed_filters(filters, allowed_values)
    end

    test "should remove keys with not allowed values" do
      allowed_values = %{"allowed" => ["allowed_value", "allowed_value_two"]}
      filters = %{"allowed" => "not_allowed_value"}

      assert %{} == UseCases.allowed_filters(filters, allowed_values)
    end
  end

  describe "cast_sorting_order/2" do
    test "returns :desc when value is desc" do
      assert :desc == UseCases.cast_sorting_order("desc", :desc)
    end

    test "returns :asc when value is asc" do
      assert :asc == UseCases.cast_sorting_order("asc", :desc)
    end

    test "returns default when the value is neither asc or desc" do
      assert :desc == UseCases.cast_sorting_order("invalid", :desc)
      assert :asc == UseCases.cast_sorting_order("invalid", :asc)
    end
  end
end
