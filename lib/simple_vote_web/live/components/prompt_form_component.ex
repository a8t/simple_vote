defmodule SimpleVoteWeb.PromptLive.PromptFormComponent do
  use SimpleVoteWeb, :live_component

  alias SimpleVote.Polls

  @impl true
  def render(assigns) do
    ~L"""
    <h2 class="text-lg leading-6 font-medium text-gray-900"><%= @title %></h2>

    <%= f = form_for @changeset, "#",
      id: "prompt-form",
      class: "mt-8",
      phx_target: @myself,
      phx_change: "validate",
      phx_submit: "save" %>

      <%= label f, :body %>
      <%= textarea f, :body, class: "shadow-sm focus:ring-indigo-500 focus:border-indigo-500 mt-1 block w-full sm:text-sm border-gray-300 rounded-md"  %>
      <%= error_tag f, :body %>
      <%= submit "Save", phx_disable_with: "Saving...", class: "mt-4 bg-indigo-600 border border-transparent rounded-md shadow-sm py-2 px-4 inline-flex justify-center text-sm font-medium text-white hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" %>
    </form>

    """
  end

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

  defp save_prompt(socket, :edit_prompt, prompt_params) do
    params_with_room = Map.merge(prompt_params, %{"room_id" => socket.assigns.room.id})

    case Polls.update_prompt(socket.assigns.prompt, params_with_room) do
      {:ok, _prompt} ->
        {:noreply,
         socket
         |> put_flash(:info, "Prompt updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_prompt(socket, :new_prompt, prompt_params) do
    case Polls.create_prompt(Map.merge(prompt_params, %{"room_id" => socket.assigns.room.id})) do
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
