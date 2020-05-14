defmodule Listify.Factory do
  use ExMachina.Ecto, repo: Listify.Repo

  alias Listify.Shopping.Item

  def item_factory do
    %Item{
      name: "Jane Smith",
      taken: false
    }
  end
end
