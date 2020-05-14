defmodule Listify.Shopping.Item do
  use Listify, :schema

  @required_fields [:name]
  @fields [:taken | @required_fields]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "items" do
    field :name, :string
    field :taken, :boolean, default: false

    timestamps()
  end

  @spec changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def changeset(item, attrs) do
    item
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
  end
end
