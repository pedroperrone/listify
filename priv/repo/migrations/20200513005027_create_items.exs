defmodule Listify.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :taken, :boolean, default: false, null: false

      timestamps()
    end
  end
end
