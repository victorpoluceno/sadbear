defmodule Bucket do
  @doc """
  Starts a new bucket.
  """
  def start_link do
    Agent.start_link(fn -> HashDict.new end, name: __MODULE__)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(key) do
    Agent.get(__MODULE__, &HashDict.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(key, value) do
    Agent.update(__MODULE__, &HashDict.put(&1, key, value))
  end
end

defmodule CountBolt do

  def initialize() do
    Bucket.start_link()
  end
  
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