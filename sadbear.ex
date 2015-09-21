defmodule Bucket do
  @doc """
  Starts a new bucket.
  """
  def start_link do
    Agent.start_link(fn -> HashDict.new end, name: __MODULE__)
  end

  @doc """
  Gets a value by `key`.
  """
  def get(key) do
    Agent.get(__MODULE__, &HashDict.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key`.
  """
  def put(key, value) do
    Agent.update(__MODULE__, &HashDict.put(&1, key, value))
  end
end

defmodule Sadbear do
  def initialize() do
    Bucket.start_link()
  end

  def run(topology) do
    make(topology)

    {{spout, p}}, bolts} = topology



    pid = Spout.initialize()
    put('spout', pid)
  end

  def make(topology) do
    {spout, bolts} = topology
    pid = Spout.initialize()
    update_meta('spout', pid)


    meta = get_meta('bolts')
    meta = make_bolts(bolts, meta)
    update_meta('bolts', meta)
  end

  def make_bolts(bolts, meta) do
    [head|tail] = bolts
    pid = Bolt.initialize()
    make_bolts(tail, meta ++ [pid])
  end

  def make_bolts([], meta) do
    meta
  end

  def emit([], []) do
  end

  def emit(_, []) do
  end

  def emit([], _) do
  end

  def emit(value, flow) when is_list(value) do
    [head|tail] = value
    emit(head, flow)
    emit(tail, flow)
  end

  def emit(value, flow) do
    [head|tail] = flow
    return = head.(value)
    emit(return, tail)
  end
end

defmodule Spout do
  def initialize() do
  end
end

defmodule Bolt do
  def initialize() do
  end
end
