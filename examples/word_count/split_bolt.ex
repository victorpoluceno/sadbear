defmodule SplitBolt do
  @doc """
  """
  def initialize() do
  end

  @doc """
  Sprint a string into words and emit each word.
  """
  def process(value) do
    String.split(value)
  end
end
