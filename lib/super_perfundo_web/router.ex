defmodule SuperPerfundoWeb.Router do
  use SuperPerfundoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SuperPerfundoWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  if Application.compile_env!(:super_perfundo, :env) == :dev do
    forward "/emails", Bamboo.SentEmailViewerPlug
  end

  scope "/", SuperPerfundoWeb do
    pipe_through :browser

    get "/", BlogController, :index
    get "/about", BlogController, :about
    get "/articles/:id", BlogController, :show
    get "/drafts/:id", BlogController, :show_draft

    post "/subscribe", SubscriptionController, :create
    get "/unsubscribe/:email", SubscriptionController, :edit
    delete "/unsubscribe/:email", SubscriptionController, :destroy

    live "/quarto", QuartoLive
  end
end
