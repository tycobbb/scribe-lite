defmodule ScribeWeb.PageController do
  use Scribe.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
