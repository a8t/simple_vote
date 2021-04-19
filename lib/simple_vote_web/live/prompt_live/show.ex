defmodule SimpleVoteWeb.PromptLive.Show do
  use SimpleVoteWeb, :live_view

  alias SimpleVote.Polls
  alias SimpleVote.Polls.{Option, Prompt}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    prompt = Polls.get_prompt!(id)
    options = Polls.list_prompt_options(id)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:prompt, prompt)
      |> assign(:options, options)

    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Prompt"
  defp page_title(:edit), do: "Edit Prompt"
end
