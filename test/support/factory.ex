defmodule SimpleVote.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: SimpleVote.Repo

  def prompt_factory do
    %SimpleVote.Polls.Prompt{
      body: "prompt body"
    }
  end

  def option_factory do
    %SimpleVote.Polls.Option{
      body: "option body",
      prompt: build(:prompt)
    }
  end
end
