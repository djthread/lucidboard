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

    # This should eventually be something else, but for now..
    get "/", DashboardController, :index

    get "/boards", DashboardController, :index

    scope "/board/:id" do
      get "/", BoardController, :index
    end
  end

  scope "/auth", LucidboardWeb do
    pipe_through :browser

    get "/:provider", AuthController, :index
    get "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end
  # Other scopes may use custom stacks.
  # scope "/api", LucidboardWeb do
  #   pipe_through :api
  # end
end
