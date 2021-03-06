defmodule SimpleVote.Polls do
  @moduledoc """
  The Polls context.
  """

  import Ecto.Query, warn: false
  alias SimpleVote.Repo

  alias SimpleVote.Polls.Prompt

  @doc """
  Returns the list of prompts.

  ## Examples

      iex> list_prompts()
      [%Prompt{}, ...]

  """
  def list_prompts do
    query = from p in Prompt, order_by: p.inserted_at

    query
    |> preload([:options, room: [:owner]])
    |> Repo.all()
  end

  @doc """
  Returns the list of prompts for a given room

  ## Examples

      iex> list_room_prompts(123)
      [%Prompt{}, ...]

  """
  def list_room_prompts(room_id) do
    query =
      from p in Prompt,
        where: p.room_id == ^room_id,
        order_by: p.inserted_at

    query
    |> preload([:options, room: [:owner]])
    |> Repo.all()
  end

  @doc """
  Gets a single prompt.

  Raises `Ecto.NoResultsError` if the Prompt does not exist.

  ## Examples

      iex> get_prompt!(123)
      %Prompt{}

      iex> get_prompt!(456)
      ** (Ecto.NoResultsError)

  """
  def get_prompt!(id) do
    Prompt
    |> preload([:options, room: :owner])
    |> Repo.get!(id)
  end

  @doc """
  Creates a prompt.

  ## Examples

      iex> create_prompt(%{field: value})
      {:ok, %Prompt{}}

      iex> create_prompt(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_prompt(attrs \\ %{}) do
    %Prompt{}
    |> Prompt.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:prompt_created)
  end

  @doc """
  Updates a prompt.

  ## Examples

      iex> update_prompt(prompt, %{field: new_value})
      {:ok, %Prompt{}}

      iex> update_prompt(prompt, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_prompt(%Prompt{} = prompt, attrs) do
    prompt
    |> Prompt.changeset(attrs)
    |> Repo.update()
    |> broadcast(:prompt_updated)
  end

  @doc """
  Deletes a prompt.

  ## Examples

      iex> delete_prompt(prompt)
      {:ok, %Prompt{}}

      iex> delete_prompt(prompt)
      {:error, %Ecto.Changeset{}}

  """
  def delete_prompt(%Prompt{} = prompt) do
    Repo.delete(prompt)
    |> broadcast(:prompt_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking prompt changes.

  ## Examples

      iex> change_prompt(prompt)
      %Ecto.Changeset{data: %Prompt{}}

  """
  def change_prompt(%Prompt{} = prompt, attrs \\ %{}) do
    Prompt.changeset(prompt, attrs)
  end

  alias SimpleVote.Polls.Option

  @doc """
  Returns the list of options for a given prompt.

  ## Examples

      iex> list_prompt_options(1)
      [%Option{}, ...]

  """
  def list_prompt_options(prompt_id) do
    query =
      from o in Option,
        where: o.prompt_id == ^prompt_id

    Repo.all(query)
  end

  @doc """
  Gets a single option.

  Raises `Ecto.NoResultsError` if the Option does not exist.

  ## Examples

      iex> get_option!(123)
      %Option{}

      iex> get_option!(456)
      ** (Ecto.NoResultsError)

  """
  def get_option!(id), do: Repo.get!(Option, id)

  @doc """
  Creates an option associated with a given prompt.

  ## Examples

      iex> create_option(%{field: value})
      {:ok, %Option{}}

      iex> create_option(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_option_for_prompt(prompt, attrs \\ %{}) do
    %Option{prompt: prompt}
    |> Option.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:option_created)
  end

  @doc """
  Updates a option.

  ## Examples

      iex> update_option(option, %{field: new_value})
      {:ok, %Option{}}

      iex> update_option(option, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_option(%Option{} = option, attrs) do
    option
    |> Option.changeset(attrs)
    |> Repo.update()
    |> broadcast(:option_updated)
  end

  @doc """
  Deletes a option.

  ## Examples

      iex> delete_option(option)
      {:ok, %Option{}}

      iex> delete_option(option)
      {:error, %Ecto.Changeset{}}

  """
  def delete_option(%Option{} = option) do
    Repo.delete(option)
    |> broadcast(:option_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking option changes.

  ## Examples

      iex> change_option(option)
      %Ecto.Changeset{data: %Option{}}

  """
  def change_option(%Option{} = option, attrs \\ %{}) do
    Option.changeset(option, attrs)
  end

  alias SimpleVote.Polls.Vote

  @doc """
  Returns the list of votes.

  ## Examples

      iex> list_votes()
      [%Vote{}, ...]

  """
  def list_votes do
    Vote |> preload([:option, :user]) |> Repo.all()
  end

  @doc """
  Gets a single vote.

  Raises `Ecto.NoResultsError` if the Vote does not exist.

  ## Examples

      iex> get_vote!(123)
      %Vote{}

      iex> get_vote!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vote!(id), do: Vote |> preload([:option, :user]) |> Repo.get!(id)

  @doc """
  Gets the state of the room associated with an option's prompt.

  Raises `Ecto.NoResultsError` if the Vote does not exist.

  ## Examples

      iex> get_vote!(123)
      %Vote{}

      iex> get_vote!(456)
      ** (Ecto.NoResultsError)

  """
  def get_option_room_state(option_id) do
    query = from o in Option, where: o.id == ^option_id

    option =
      query
      |> preload(prompt: [:room])
      |> Repo.one()

    {:ok, option.prompt.room.state}
  end

  @doc """
  Creates a vote.

  ## Examples

      iex> create_vote(%{field: value})
      {:ok, %Vote{}}

      iex> create_vote(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def cast_vote(user_id, option_id) do
    case get_option_room_state(option_id) do
      {:ok, :open} ->
        %Vote{}
        |> Vote.changeset(%{user_id: user_id, option_id: option_id})
        |> Repo.insert()

      _ ->
        {:error, :room_not_open}
    end
  end

  @doc """
  Updates a vote.

  ## Examples

      iex> update_vote(vote, %{field: new_value})
      {:ok, %Vote{}}

      iex> update_vote(vote, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vote(%Vote{} = vote, attrs) do
    vote
    |> Vote.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a vote.

  ## Examples

      iex> delete_vote(vote)
      {:ok, %Vote{}}

      iex> delete_vote(vote)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vote(%Vote{} = vote) do
    Repo.delete(vote)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vote changes.

  ## Examples

      iex> change_vote(vote)
      %Ecto.Changeset{data: %Vote{}}

  """
  def change_vote(%Vote{} = vote, attrs \\ %{}) do
    Vote.changeset(vote, attrs)
  end

  @pubsub SimpleVote.PubSub

  @doc """
  Subscribes the current process to the provided pubsub topic.

  ## Examples

      iex> subscribe(room)
      :ok

  """
  def subscribe(room_id) do
    Phoenix.PubSub.subscribe(@pubsub, make_topic(room_id))
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, %Prompt{room_id: room_id} = prompt}, event) do
    Phoenix.PubSub.broadcast(@pubsub, make_topic(room_id), {event, prompt})
    {:ok, prompt}
  end

  defp broadcast({:ok, %Option{prompt: %{room_id: room_id}} = option}, event) do
    Phoenix.PubSub.broadcast(@pubsub, make_topic(room_id), {event, option})
    {:ok, option}
  end

  @doc """
  Returns a topic for PubSub.

  ## Examples

      iex> make_topic(room_id)
      "room:polls:493"

  """
  def make_topic(room_id) do
    "room:polls:" <> to_string(room_id)
  end
end
