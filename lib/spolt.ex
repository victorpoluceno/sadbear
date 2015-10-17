# TODO: is clear now that we can use GenServer here

defmodule Spout do

  @callback initialize() :: any
  @callback next_tuple(context :: any) :: nil | Tuple.t

  @doc """
  Starts a new Spolt.
  """
  def start_link() do
    Task.start_link(fn -> loop(nil) end)
  end

  def initialize(pid, component, next_pids) do
    send(pid, {:initialize, component})
  end

  def run(pid, component, next_pids) do
    send(pid, {:run, next_pids, component})
  end

  defmacro __using__(_opts) do
    quote do
      @behaviour Spout
    end
  end

  defp loop(context) do
    receive do
      {:initialize, component} ->
        IO.puts('Initializing spout...')
        context = component.initialize()
        loop(context)
      {:run, next_pids, component} ->
        next_tuple(next_pids, component, context)
    end
  end

  defp next_tuple(next_pids, component, context) do
    result = component.next_tuple(context)
    if result do
      {value, context} = result
      if length(next_pids) != 0 do
        # TODO: this is where we need to implement logic
        # routing mecanics, like random, field, etc
        next_pid = hd(next_pids)
        Bolt.process(next_pid, value)
      end
      next_tuple(next_pids, component, context)
    else
      next_tuple(next_pids, component, nil)
    end
  end
end
