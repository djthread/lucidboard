defmodule LucidboardWeb.Router do
  use LucidboardWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LucidboardWeb do
    pipe_through :browser

    get "/", PageController, :index

    scope "/board/:id" do
      get "/", BoardController, :index
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", LucidboardWeb do
  #   pipe_through :api
  # end
end
