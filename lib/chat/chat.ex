defmodule Chat.Chat do
  use Ecto.Schema
  import Ecto.Query

  schema "chats" do
    field(:message, :string)
    field(:handle, :string)
    field(:uuid, :string)
  end

  def changeset(chat, params \\ %{}) do
    chat
    |> Ecto.Changeset.cast(params, [:message, :handle, :uuid])
    |> Ecto.Changeset.validate_required([:message, :handle, :uuid])
  end

  def fetch_last_100() do
    query =
      from(m in Chat.Chat,
        select: %{message: m.message, handle: m.handle, id: m.uuid},
        limit: 100
      )

    Chat.Repo.all(query)
  end

  def insert_message({message, handle, uuid}) do
    params = %Chat.Chat{}

    changeset = changeset(params, %{message: message, handle: handle, uuid: uuid})
    Chat.Repo.insert(changeset)
  end
end
