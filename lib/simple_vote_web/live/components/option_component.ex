defmodule SimpleVoteWeb.OptionComponent do
  use SimpleVoteWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <p class="text-sm font-medium text-gray-900">
      <%= @option.body %>
    </p>

    <%= live_patch to: Routes.room_show_path(@socket, :edit_option, @room, @prompt, @option), replace: true, id: "option-#{@option.id}-edit", class: "button button-ghost ml-auto mr-2" do %>
      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
        <path d="M17.414 2.586a2 2 0 00-2.828 0L7 10.172V13h2.828l7.586-7.586a2 2 0 000-2.828z" />
        <path fill-rule="evenodd" d="M2 6a2 2 0 012-2h4a1 1 0 010 2H4v10h10v-4a1 1 0 112 0v4a2 2 0 01-2 2H4a2 2 0 01-2-2V6z" clip-rule="evenodd" />
      </svg>
    <% end %>

    <%= link  to: "#", phx_click: "delete_option", phx_value_option_id: @option.id, phx_value_room_id: @room.id, data: [confirm: "Are you sure?"], id: "option-#{@option.id}-delete", class: "button button-danger-ghost" do %>
      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
      </svg>
    <% end %>
    """
  end
end
