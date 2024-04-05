defmodule Chat.Repo.Migrations.CreateChat do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add(:message, :string)
      add(:handle, :string)
      add(:uuid, :string)
    end
  end
end
