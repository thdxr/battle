defmodule Battle.Match do
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
				IO.puts("    [HIT] #{attacker.name} hits #{defender.name} for #{attacker.damage} (#{defender.health} -> #{health})")
				%{defender | health: health}
		end
	{na, nd}
  end

end