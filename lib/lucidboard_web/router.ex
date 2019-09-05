defmodule LucidboardWeb.Router do
  use LucidboardWeb, :router
  alias LucidboardWeb.LayoutView

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(Phoenix.LiveView.Flash)
    plug(LucidboardWeb.LoadUserPlug)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:put_layout, {LayoutView, :normal})
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/auth", LucidboardWeb do
    pipe_through([:browser])

    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
  end

  scope "/", LucidboardWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/changelog", PageController, :changelog)

    get("/signin", UserController, :signin)
    post("/signin", AuthController, :dumb_signin)
    get("/signout", AuthController, :signout)

    get("/user-settings", UserController, :settings)
    post("/user-settings", UserController, :update_settings)

    live("/dashboard", DashboardLive, session: [:user_id])
    live("/create-board", CreateBoardLive, session: [:path_params, :user_id])

    live("/boards", DashboardLive, session: [:user_id])
    live("/boards/:id", BoardLive, session: [:path_params, :user_id])

    post("/boards/:id/dnd-into-junction", BoardController, :dnd_into_junction)
    post("/boards/:id/dnd-into-pile", BoardController, :dnd_into_pile)
  end
end
