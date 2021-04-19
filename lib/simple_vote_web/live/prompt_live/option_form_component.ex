defmodule SimpleVoteWeb.PromptLive.OptionFormComponent do
  use SimpleVoteWeb, :live_component

  alias SimpleVote.Polls

  @impl true
  def update(%{option: option} = assigns, socket) do
    changeset = Polls.change_option(option)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"option" => option_params}, socket) do
    changeset =
      socket.assigns.option
      |> Polls.change_option(option_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"option" => option_params}, socket) do
    save_option(socket, socket.assigns.action, option_params)
  end

  defp save_option(socket, :new_option, option_params) do
    case Polls.create_option_for_prompt(socket.assigns.prompt, option_params) do
      {:ok, _option} ->
        {:noreply,
         socket
         |> put_flash(:info, "Option created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset.errors)
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
