defmodule ChatWeb.ChatLive do
  use ChatWeb, :live_view
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Chat.PubSub, "messages")
    end

    socket =
      socket
      |> assign(:message, "")
      |> assign(:messages, [])
      |> assign(:handle, MnemonicSlugs.generate_slug(2))

    {:ok, socket}
  end

  @impl true
  def handle_event("send-message", %{"message" => message}, socket) do
    PubSub.broadcast_from!(
      Chat.PubSub,
      self(),
      "messages",
      {:new_message, message, socket.assigns.handle}
    )

    socket =
      socket
      |> assign(:messages, socket.assigns.messages ++ [{message, socket.assigns.handle}])

    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_message, message, handle}, socket) do
    socket =
      socket
      |> assign(:messages, socket.assigns.messages ++ [{message, handle}])

    {:noreply, socket}
  end
end
