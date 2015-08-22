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

defmodule CountBolt do
  @doc """
  On initialization start a Bucket agent.
  """
  def initialize() do
    Bucket.start_link()
  end
  
  @doc """
  Count words and print.
  """
  def process(value) do
    count = Bucket.get(value)
    if count == nil do
      count = 1
    else
      count = count + 1 
    end

    Bucket.put(value, count)
  	IO.puts("#{value} -> #{count}")
  end
end