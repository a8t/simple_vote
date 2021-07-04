defmodule SimpleVoteWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `SimpleVoteWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal SimpleVoteWeb.PromptLive.FormComponent,
        id: @prompt.id || :new,
        action: @live_action,
        prompt: @prompt,
        return_to: Routes.prompt_index_path(:index) %>
  """
  def live_modal(component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(SimpleVoteWeb.ModalComponent, modal_opts)
  end

  def assign_user(%{"user_token" => user_token} = session, socket) do
    socket
    |> Phoenix.LiveView.assign_new(:current_user, fn ->
      SimpleVote.Accounts.get_user_by_session_token(user_token)
    end)
    |> Phoenix.LiveView.assign_new(:nickname, fn ->
      Map.get(session, "nickname", "none")
    end)
  end

  def assign_user(%{"nickname" => nickname}, socket) do
    socket
    |> Phoenix.LiveView.assign_new(:nickname, fn ->
      nickname
    end)
  end

  def assign_user(_session, socket) do
    socket
  end

  def get_current_user(socket) do
    case Map.get(socket.assigns, :current_user) do
      nil -> {:error, :not_authenticated}
      user -> {:ok, user}
    end
  end
end
