defmodule Candidate do
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

defmodule Match do
  # Generate all pairings recursively (n * (n-1)) / 2
  def generate([]), do: []
  def generate([head | tail]) do
    Enum.map(tail, fn opponent -> {head, opponent} end) ++ generate(tail)
  end

  # Start fight between two candidates
  def fight({left, right}) do
    IO.puts("\n[MATCH START] #{left.name} vs #{right.name}")
    round(left, right)
  end

  # Reset attacks for a new round
  def round(left, right) do
    IO.puts("\n  New Round")
    left = Map.put(left, :remaining, left.attacks)
    right = Map.put(right, :remaining, right.attacks)
    {attacker, defender} = initiative(left, right)
    run(attacker, defender)
  end

  # Simulate fight step by step until someone's health is below 0 or attacks have been depleted
  def run(attacker, defender) do
    {na, nd} = hit(attacker, defender)
    cond do
      nd.health <= 0 ->
          IO.puts("\n  Winner #{na.name}")
          na.name
      nd.remaining > 0 -> run(nd, na)
      na.remaining > 0 -> run(na, nd)
      true -> round(na, nd)
    end
  end

  # Figure out who should fight first
  def initiative(left, right) do
    (weights(left, right) ++ weights(right, left))
    |> Enum.random
  end

  # Generate entries according to initiative weight
  def weights(left, right) do
    [{left, right}]
    |> Stream.cycle
    |> Enum.take(left.initiative)
  end

  # Simulate a hit with probabilities for critical and dodge
  def hit(attacker, defender) do
    na = %{attacker | remaining: attacker.remaining - 1}
    damage =
      cond do
        Enum.random(0..99) < attacker.critical -> attacker.damage * 2
        true -> attacker.damage
      end
    nd =
      cond do
        Enum.random(0..99) < defender.dodge ->
          IO.puts("    [MISS] #{attacker.name} misses #{defender.name} (#{defender.health})")
          defender
        true ->
          health = defender.health - damage
          IO.puts("    [HIT] #{attacker.name} hits #{defender.name} for #{damage} (#{defender.health} -> #{health})")
          %{defender | health: health}
      end
      {na, nd}
  end
end


{winner, count} =
  "applicants.csv"
  |> Candidate.from_csv
  |> Match.generate
  |> Stream.map(&Match.fight/1)
  |> Enum.group_by(&(&1))
  |> Stream.map(fn {key, values} -> {key, Enum.count(values)} end)
  |> Enum.max_by(&elem(&1, 1))
IO.puts("Final Winner: #{winner} (#{count} wins)")