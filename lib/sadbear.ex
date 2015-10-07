defmodule SadBear do
  def initialize do
    Bucket.start_link()
  end

  def make(topology) do
    {spout, bolts} = topology
    make_spout(spout)
    make_bolts(bolts)

    start_bolts(bolts)
    start_spout(spout)
    loop()
  end

  def loop() do
    loop()
  end

  def start_spout(spout) do
    {name, component, _, next} = spout
    pids = get_metadata(name)
    Spout.run(pids, component, get_metadata(next))
  end

  def start_bolts([]) do
  end

  def start_bolts(bolts) do
    [{name, component, _, next}|tail] = bolts
    IO.puts('Starting: #{name} -> #{next}')
    pids = get_metadata(name)
    pids_next = get_metadata(next)
    #IO.puts(inspect(pids))
    #IO.puts(inspect(pids_next))
    Bolt.run(pids, component, pids_next)
    start_bolts(tail)
  end

  def make_spout(spout) do
    {name, _, p, _} = spout
    make_spout(name, p)
  end

  def make_spout(name, p) when p > 0 do
    case Spout.initialize() do
      {:ok, pid} ->
        metadata = get_metadata(name)
        update_metadata(name, metadata ++ [pid])
        make_spout(name, p - 1)
      {:error, reason} ->
        raise 'Failed to initialize spout: #{reason}'
    end
  end

  def make_spout(_, 0) do
  end

  def make_bolts([]) do
  end

  def make_bolts(bolts) do
    [{name, _, p, _}|tail] = bolts
    make_bolts(name, p)
    make_bolts(tail)
  end

  def make_bolts(name, p) when p > 0 do
    case Bolt.initialize() do
      {:ok, pid} ->
        metadata = get_metadata(name)
        IO.puts('Initializing: #{name}, #{p}')
        update_metadata(name, metadata ++ [pid])
        make_bolts(name, p - 1)
      {:error, reason} ->
        raise 'Failed to initialize bolt: #{reason}'
    end
  end

  def make_bolts(_, 0) do
  end

  def get_metadata(name) do
    Bucket.get(name, [])
  end

  defp update_metadata(name, metadata) do
    Bucket.put(name, metadata)
  end
end

defmodule Bolt do
  def initialize() do
    Task.start_link(fn -> loop(%{}) end)
  end

  def run(pids, component, []) do
    pid = hd(pids)
    send pid, {:run, component, nil}
  end

  def run(pids, component, next_pids) do
    pid = hd(pids)
    pid_next = hd(next_pids)
    send pid, {:run, component, pid_next}
  end

  defp loop(map) do
    receive do
      {:run, component, pid_next} ->
        map = Map.put(map, 'self', {component, pid_next})
        component.initialize()
        loop(map)
      {:process, value} ->
        {component, pid_next} = Map.get(map, 'self')
        value = component.process(value)
        process(pid_next, value)
        loop(map)
    end
  end

  defp process(_, []) do
  end

  defp process(pid_next, value) when is_list(value) do
    [head|tail] = value
    process(pid_next, head)
    process(pid_next, tail)
  end

  defp process(pid_next, value) do
    if pid_next != nil do
      send pid_next, {:process, value}
    end
  end
end

defmodule Spout do
  def initialize() do
    Task.start_link(fn -> loop(nil) end)
  end

  def run(pids, component, next_pids) do
    pid = hd(pids)
    pid_next = hd(next_pids)
    send pid, {:initialize, component}
    send pid, {:run, pid_next, component}
  end

  defp loop(context) do
    receive do
      {:run, pid_next, component} ->
        next_tuple(pid_next, component, context)
      {:initialize, component} ->
        context = component.initialize()
        loop(context)
    end
  end

  defp next_tuple(pid_next, component, context) do
    {value, context} = component.next_tuple(context)
    if value do
      send pid_next, {:process, value}
    end
    next_tuple(pid_next, component, context)
  end
end
