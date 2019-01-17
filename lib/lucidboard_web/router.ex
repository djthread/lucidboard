defmodule LucidboardWeb.Router do
  use LucidboardWeb, :router
  alias LucidboardWeb.LayoutView

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(LucidboardWeb.LoadUserPlug)
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:put_layout, {LayoutView, :normal})
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", LucidboardWeb do
    pipe_through(:browser)

    get("/", PageController, :index)

    get("/signin", UserController, :signin)
    get("/signout", UserController, :signout)
    get("/user-settings", UserController, :settings)
    post("/user-settings", UserController, :update_settings)

    get("/dashboard", DashboardController, :index)
    get("/boards", DashboardController, :index)

    get("/create-board", BoardController, :create_form)
    post("/create-board", BoardController, :create)

    scope "/boards/:id" do
      get("/", BoardController, :index)
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", LucidboardWeb do
  #   pipe_through :api
  # end
end
