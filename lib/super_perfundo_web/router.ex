defmodule SuperPerfundoWeb.Router do
  use SuperPerfundoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", SuperPerfundoWeb do
    pipe_through :browser

    get "/", BlogController, :index
    get "/about", BlogController, :about

    get "/:id", BlogController, :show
    get "/drafts/:id", BlogController, :show_draft
    post "/subscribe", BlogController, :subscribe
  end
end
