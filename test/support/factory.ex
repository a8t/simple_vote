defmodule SimpleVote.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: SimpleVote.Repo

  def user_factory do
    password = "valid password"

    %SimpleVote.Accounts.User{
      email: sequence(:email, &"email-#{&1}@example.com"),
      hashed_password: Bcrypt.hash_pwd_salt(password)
    }
  end

  def room_factory do
    %SimpleVote.Rooms.Room{
      owner: build(:user),
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

  def vote_factory do
    %SimpleVote.Polls.Vote{
      user: build(:user),
      option: build(:option)
    }
  end
end
