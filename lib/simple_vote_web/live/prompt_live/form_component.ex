defmodule SimpleVoteWeb.PromptLive.FormComponent do
  use SimpleVoteWeb, :live_component

  alias SimpleVote.Polls

  @impl true
  def update(%{prompt: prompt} = assigns, socket) do
    changeset = Polls.change_prompt(prompt)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"prompt" => prompt_params}, socket) do
    changeset =
      socket.assigns.prompt
      |> Polls.change_prompt(prompt_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"prompt" => prompt_params}, socket) do
    save_prompt(socket, socket.assigns.action, prompt_params)
  end

  defp save_prompt(socket, :edit, prompt_params) do
    case Polls.update_prompt(socket.assigns.prompt, prompt_params) do
      {:ok, _prompt} ->
        {:noreply,
         socket
         |> put_flash(:info, "Prompt updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_prompt(socket, :new, prompt_params) do
    case Polls.create_prompt(prompt_params) do
      {:ok, _prompt} ->
        {:noreply,
         socket
         |> put_flash(:info, "Prompt created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
