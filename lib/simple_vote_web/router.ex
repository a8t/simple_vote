defmodule SimpleVoteWeb.Router do
  use SimpleVoteWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SimpleVoteWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SimpleVoteWeb do
    pipe_through :browser

    live "/", PageLive, :index

    live "/rooms", RoomLive.Index, :index
    live "/rooms/new", RoomLive.Index, :new
    live "/rooms/:slug/edit", RoomLive.Index, :edit

    live "/rooms/:slug", RoomLive.Show, :show
    live "/rooms/:slug/show/edit", RoomLive.Show, :edit

    live "/rooms/:slug/prompts/new", RoomLive.Show, :new_prompt
    live "/rooms/:slug/prompts/:prompt_id/edit", RoomLive.Show, :edit_prompt

    live "/rooms/:slug/prompts/:prompt_id/options/new", RoomLive.Show, :new_option
    live "/rooms/:slug/prompts/:prompt_id/options/:option_id/edit", RoomLive.Show, :edit_option
  end

  # Other scopes may use custom stacks.
  # scope "/api", SimpleVoteWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: SimpleVoteWeb.Telemetry
    end
  end
end
