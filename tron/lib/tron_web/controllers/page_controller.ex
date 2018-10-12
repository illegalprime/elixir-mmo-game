defmodule TronWeb.PageController do
  use TronWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
