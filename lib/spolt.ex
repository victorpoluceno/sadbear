defmodule Spout do

  @doc """
  Starts a new Spolt.
  """
  def start_link() do
    Task.start_link(fn -> loop(nil) end)
  end

  def initialize(pid, component, next_pids) do
    send pid, {:initialize, component}
    send pid, {:run, next_pids, component}
  end

  defp loop(context) do
    receive do
      {:initialize, component} ->
        context = component.initialize()
        loop(context)
      {:run, next_pids, component} ->
        next_tuple(next_pids, component, context)
    end
  end

  defp next_tuple(next_pids, component, context) do
    {value, context} = component.next_tuple(context)
    if length(next_pids) != 0 do
      # TODO: this is where we need to implement logic
      # routing mecanics, like random, field, etc
      next_pid = hd(next_pids)
      if value do
        Bolt.process(next_pid, value)
      end
    end
    next_tuple(next_pids, component, context)
  end
end
