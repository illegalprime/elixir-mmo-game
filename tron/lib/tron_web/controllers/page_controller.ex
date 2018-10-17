defmodule TronWeb.PageController do
  use TronWeb, :controller
  alias Tron.Utils
  alias Tron.Player.Registry

  def index(conn, _params) do
    render conn, "index.html"
  end

  def play(conn, %{"nick" => username}) do
    cond do
      # verify username format
      not Utils.verify_username(username) ->
        render conn, "index.html", wrong_username: username
      # check the username hasn't been taken already
      Registry.nick_exists?(username) ->
        render conn, "index.html", taken_username: username
      # if all checks pass, render the play page
      true ->
        render conn, "play.html", username: username
    end
  end
end
