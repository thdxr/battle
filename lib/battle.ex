defmodule Battle do
  alias Battle.Candidate
  alias Battle.Match

  def start(file) do
    file
    |> Candidate.from_csv
    |> Match.generate
    |> Stream.map(&Match.fight/1)
    |> Enum.group_by(&(&1))
    |> Enum.max_by(fn {_, values} -> Enum.count(values) end)
    |> elem(0)
  end
end
