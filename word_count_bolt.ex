defmodule WordCountBolt do
  def process(value) do
    String.split(value)
  end
end