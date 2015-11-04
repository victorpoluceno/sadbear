defmodule Bucket do
  @doc """
  Starts a new bucket registered as `name`.
  """
  def start_link(name) do
    Agent.start_link(fn -> HashDict.new end, name: name)
  end

  @doc """
  Gets a value on `agent` by `key` using `default` if key does not exists.
  """
  def get(name, key, default \\ nil) do
    Agent.get(name, &HashDict.get(&1, key, default))
  end

  @doc """
  Puts on on `agent` the `value` for the given `key`.
  """
  def put(name, key, value) do
    Agent.update(name, &HashDict.put(&1, key, value))
  end
end
