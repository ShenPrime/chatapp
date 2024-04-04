defmodule ChatWeb.ChatLive do
  use ChatWeb, :live_view
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Chat.PubSub, "messages")
      PubSub.subscribe(Chat.PubSub, "new_user")
    end

    handle = MnemonicSlugs.generate_slug(2)

    PubSub.broadcast_from!(Chat.PubSub, self(), "new_user", {:new_user, handle})

    socket =
      socket
      |> assign(:message, "")
      |> stream(:messages, [])
      |> assign(:handle, handle)

    {:ok, socket}
  end

  @impl true
  def handle_event("send-message", %{"message" => message}, socket) do
    id = Ecto.UUID.generate()

    PubSub.broadcast_from!(
      Chat.PubSub,
      self(),
      "messages",
      {:new_message, message, socket.assigns.handle}
    )

    socket =
      socket
      |> stream_insert(:messages, %{id: id, message: message, handle: socket.assigns.handle})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_message, message, handle}, socket) do
    id = Ecto.UUID.generate()

    socket =
      socket
      |> stream_insert(:messages, %{id: id, message: message, handle: handle})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_user, handle}, socket) do
    socket = put_flash(socket, :info, "User #{handle} has joined the chat")
    send(self(), :clear_flash)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    Process.sleep(2000)
    socket = clear_flash(socket)
    {:noreply, socket}
  end
end
