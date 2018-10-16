defmodule TronWeb.PageController do
  use TronWeb, :controller
  alias Tron.Utils

  def index(conn, _params) do
    render conn, "index.html"
  end

  def play(conn, %{"nick" => username}) do
    if Utils.verify_username(username) do
      render conn, "play.html", username: username
    else
      render conn, "index.html", wrong_username: username
    end
  end
end
