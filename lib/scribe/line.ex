defmodule Scribe.Line do
  use Ecto.Schema

  schema "lines" do
    field :text, :string
    field :email, :string
    field :name, :string
  end

  def changeset(line, params \\ %{}) do
    line
      |> Ecto.Changeset.cast(params, [:text, :email, :name])
      |> Ecto.Changeset.validate_required([:text, :email])
  end
end
