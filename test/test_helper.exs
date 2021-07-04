# needs to be before ExUnit.start(): https://github.com/thoughtbot/ex_machina
{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.configure(exclude: :skip)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(SimpleVote.Repo, :manual)
