defmodule SimpleVote.Rooms.SlugGenerator do
  @doc """
  Generates a unique, URL-friendly name such as "bold-frog-8249".
  """
  @spec generate :: binary
  def generate do
    [
      Enum.random(positive_adjectives()),
      Enum.random(animals()),
      :rand.uniform(9999)
    ]
    |> Enum.join("-")
  end

  defp positive_adjectives do
    ~w(
      affectionate agreeable amiable brave bright charming
      creative determined diligent diplomatic dynamic energetic
      friendly funny generous giving gregarious hardworking
      helpful imaginative kind likable loyal marvelous
      patient polite remarkable sincere rousing spectacular
      splendid stellar stunning stupendous super upbeat
      upstanding unwavering virtuous vigilant wondrous
    )
  end

  defp animals do
    ~w(
      ant anteater antelope ape bat beaver buffalo bull butterfly
      chicken chimpanzee cow deer dog dolphin dragon eagle earthworm
      fish fox frog gazelle gibbon giraffe goat hamster hawk hedgehog
      horse koala lion lizard loon lynx mink monkey moose mouse otter
      panda penguin poodle puppy rabbit raccoon seagull seal sheep
      tarsier tiger tortoise turkey turtle whale zebra
    )
  end
end
