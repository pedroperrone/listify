defmodule ListifyWeb.FallbackController do
  use ListifyWeb, :controller

  alias Ecto.Changeset
  alias ListifyWeb.ErrorView

  def call(conn, {:error, message = "Resource not found"}) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorView)
    |> render("404.json", %{message: message})
  end

  def call(conn, {:error, changeset = %Changeset{valid?: false}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorView)
    |> render("422.json", %{errors: errors_on(changeset)})
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
