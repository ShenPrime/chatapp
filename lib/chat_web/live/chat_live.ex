defmodule ChatWeb.ChatLive do
  use ChatWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:message, "")
      |> assign(:messages, [])

    {:ok, socket}
  end

  @impl true
  def handle_event("send-message", %{"message" => message}, socket) do
    socket =
      socket
      |> assign(:message, message)
      |> assign(:messages, [message | socket.assigns.messages])
    {:noreply, socket}
  end
end
