defmodule Scribe.Repo.Migrations.CreateLines do
  use Ecto.Migration

  def change do
    create table(:lines) do
      add :text, :string
      add :email, :string
      add :name, :string
    end
  end
end
