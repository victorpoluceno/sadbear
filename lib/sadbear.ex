defmodule SadBear do

  @doc """
  Initialize SadBear.
  """
  def initialize do
    {:ok, _} = Bucket.start_link(:sadbear)
  end

  def make(topology) do
    {spout, bolts} = topology
    make_spout(spout)
    make_bolts(bolts)

    start_bolts(bolts)
    start_spout(spout)
  end

  defp run() do
    run()
  end

  defp make_spout(spout) do
    {name, _, p, _} = spout
    make_spout(name, p)
  end

  defp make_spout(name, p) when p > 0 do
    case Spout.start_link() do
      {:ok, pid} ->
        metadata = get_metadata(name)
        update_metadata(name, metadata ++ [pid])
        make_spout(name, p - 1)
      {:error, reason} ->
        raise 'Failed to initialize spout: #{reason}'
    end
  end

  defp make_spout(_, 0) do
  end

  defp make_bolts([]) do
  end

  defp make_bolts(bolts) do
    [{name, _, p, _}|tail] = bolts
    make_bolts(name, p)
    make_bolts(tail)
  end

  defp make_bolts(name, p) when p > 0 do
    case Bolt.start_link() do
      {:ok, pid} ->
        metadata = get_metadata(name)
        IO.puts('Initializing: #{name}, #{p}')
        update_metadata(name, metadata ++ [pid])
        make_bolts(name, p - 1)
      {:error, reason} ->
        raise 'Failed to initialize bolt: #{reason}'
    end
  end

  defp make_bolts(_, 0) do
  end

  def start_spout(spout) do
    {name, component, _, next} = spout
    pids = get_metadata(name)
    start_spout(pids, component, get_metadata(next))
  end

  defp start_spout([], _, _) do
  end

  defp start_spout(pids, component, pids_next) do
    [pid|tail] = pids
    Spout.initialize(pid, component, pids_next)
    Spout.run(pid, component, pids_next)
    start_spout(tail, component, pids_next)
  end

  defp start_bolts([]) do
  end

  defp start_bolts(bolts) do
    [{name, component, _, next}|tail] = bolts
    IO.puts('Starting: #{name} -> #{next}')
    pids = get_metadata(name)
    pids_next = get_metadata(next)
    start_bolts(pids, component, pids_next)
    start_bolts(tail)
  end

  def start_bolts([], _, _) do
  end

  def start_bolts(pids, component, pids_next) do
    [pid|tail] = pids
    Bolt.initialize(pid, component, pids_next)
    start_bolts(tail, component, pids_next)
  end

  def get_metadata(name) do
    Bucket.get(:sadbear, name, [])
  end

  defp update_metadata(name, metadata) do
    Bucket.put(:sadbear, name, metadata)
  end
end
