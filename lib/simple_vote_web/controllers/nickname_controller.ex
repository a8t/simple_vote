defmodule SimpleVoteWeb.NicknameController do
  use SimpleVoteWeb, :controller

  def create(conn, %{"nickname_form" => nickname_params, "return_to" => return_to}) do
    %{"nickname" => nickname} = nickname_params

    conn
    |> put_session(:nickname, nickname)
    |> redirect(to: return_to)
  end
end
