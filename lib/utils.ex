defmodule Bucket do
  # TODO: find out if it's okay to use module as namespace

  @doc """
  Starts a new bucket.
  """
  def start_link do
    Agent.start_link(fn -> HashDict.new end, name: __MODULE__)
  end

  @doc """
  Gets a value by `key` using `default` if key does not exists.
  """
  def get(key, default \\ nil) do
    Agent.get(__MODULE__, &HashDict.get(&1, key, default))
  end

  @doc """
  Puts the `value` for the given `key`.
  """
  def put(key, value) do
    Agent.update(__MODULE__, &HashDict.put(&1, key, value))
  end
end
