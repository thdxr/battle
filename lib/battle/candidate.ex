defmodule Battle.Candidate do
  def new(name, health, damage, attacks, dodge, critical, initiative) do
	%{
		name: name,
		health: health,
		damage: damage,
		attacks: attacks,
		dodge: dodge,
		critical: critical,
		initiative: initiative,
	}
  end

  # Load from array of strings
  def from_array(args) do
	[name | rest] = args
	apply(__MODULE__, :new, [
		name |
		rest
		|> Enum.map(&String.to_integer/1)
	])
  end

  # Load from CSV
  def from_csv(path) do
	path
	|> File.stream!([], :line)
	|> Stream.drop(1)
	|> Stream.map(&String.trim/1)
	|> Stream.map(&String.split(&1, ","))
	|> Enum.map(&from_array/1)
  end
end