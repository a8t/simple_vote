defmodule SimpleVoteWeb.PromptComponent do
  use SimpleVoteWeb, :live_component
  alias SimpleVote.Polls

  @impl true
  def render(assigns) do
    ~L"""
    <section>
      <div class="bg-white shadow sm:rounded-lg">
        <div class="px-4 py-5 sm:px-6 relative">
          <%= live_patch to: Routes.room_show_path(@socket, :edit_prompt, @room, @prompt), id: "prompt-#{@prompt.id}-edit" do %>
            <h2 i class="text-lg leading-6 text-gray-900 flex items-center hover:text-blue-700">
              <span class="font-medium"><%= @prompt.body %> </span>

              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 ml-1 opacity-50" viewBox="0 0 20 20" fill="currentColor">
                <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z" />
              </svg>
            </h2>
          <% end %>

          <%= link  to: "#", phx_click: "delete_prompt", phx_value_prompt_id: @prompt.id, phx_value_room_id: @room.id, data: [confirm: "Are you sure?"], id: "prompt-#{@prompt.id}-delete", class: "button button-danger-ghost absolute top-3 right-3" do %>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
            </svg>
          <% end %>

        </div>
        <div class="border-t border-gray-200 px-4 py-5 sm:px-6">
          <span class="text-gray-500 text-xs flex items-center">
            <%= live_patch to: Routes.room_show_path(@socket, :new_option, @room, @prompt), replace: true, id: "new-option", class: "button #{if @prompt.options |> length == 0 , do: "button-outline", else: "button-ghost" } flex hover:text-blue-600" do %>
              Add option

              <div class="ml-2">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
              </div>
            <% end %>
          </span>

          <ul class="flex flex-col space-y-2 mt-2">
            <%= for option <- @prompt.options do %>
              <li class="flex items-center relative rounded-lg border border-gray-300 bg-white shadow-sm px-6 py-4 hover:border-gray-400 sm:flex sm:justify-between focus-within:ring-1 focus-within:ring-offset-2 focus-within:ring-indigo-500">
                <%= live_component @socket, SimpleVoteWeb.OptionComponent, room: @room, prompt: @prompt, option: option, id: option.id %>
              </li>
            <% end %>
          </ul>
        </div>
      </div>
    </section>

    """
  end
end
