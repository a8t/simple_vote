defmodule SimpleVote.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: SimpleVote.Repo

  def room_factory do
    %SimpleVote.Rooms.Room{
      name: "room name"
    }
  end

  def prompt_factory do
    %SimpleVote.Polls.Prompt{
      body: "prompt body",
      room: build(:room)
    }
  end

  def option_factory do
    %SimpleVote.Polls.Option{
      body: "option body",
      prompt: build(:prompt)
    }
  end
end
