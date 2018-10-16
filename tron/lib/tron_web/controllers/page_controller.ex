defmodule TronWeb.PageController do
  use TronWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def play(conn, %{"nick" => username}) do
    render conn, "play.html", username: username
  end
end
