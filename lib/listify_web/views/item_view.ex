defmodule ListifyWeb.ItemView do
  use ListifyWeb, :view

  def render("index.json", %{items: items}) do
    render_many(items, __MODULE__, "item.json")
  end

  def render("item.json", %{item: item}) do
    %{
      id: item.id,
      name: item.name,
      taken: item.taken
    }
  end
end
