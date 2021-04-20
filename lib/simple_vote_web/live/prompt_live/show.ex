defmodule SimpleVoteWeb.PromptLive.Show do
  use SimpleVoteWeb, :live_view

  alias SimpleVote.Polls
  alias SimpleVote.Polls.{Option, Prompt}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket)
      when socket.assigns.live_action in [:new_option, :edit_option] do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
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

  defp apply_action(socket, :edit_option, %{"id" => id, "option_id" => option_id}) do
    prompt = Polls.get_prompt!(id)
    option = Polls.get_option!(option_id)
    options = Polls.list_prompt_options(id)

    socket
    |> assign(:page_title, "Edit Option")
    |> assign(:option, option)
    |> assign(:prompt, prompt)
    |> assign(:options, options)
  end

  defp apply_action(socket, :new_option, %{"id" => id}) do
    prompt = Polls.get_prompt!(id)
    options = Polls.list_prompt_options(id)

    socket
    |> assign(:page_title, "New Option")
    |> assign(:option, %Option{})
    |> assign(:prompt, prompt)
    |> assign(:options, options)
  end

  defp page_title(:show), do: "Show Prompt"
  defp page_title(:edit), do: "Edit Prompt"
  defp page_title(:edit_option), do: "Edit Option"
end
