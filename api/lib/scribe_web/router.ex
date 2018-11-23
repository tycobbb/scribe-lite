defmodule ScribeWeb.Router do
  use Scribe.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ScribeWeb do
    pipe_through :browser
    get "/*rest", PageController, :index
  end
end