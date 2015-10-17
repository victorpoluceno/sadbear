defmodule Bolt do

  @callback initialize() :: any
  @callback process(value :: any) :: any

  @doc """
  Starts a new Bolt.
  """
  def start_link() do
    Task.start_link(fn -> loop(%{}) end)
  end

  @doc """
  Initialize the bolt for the `pid` with `component` and `next_pids`
  as a list of next bolt. Bolt.initialize function will be called.
  """
  def initialize(pid, component, next_pids \\ []) do
    # TODO need to implement support for routing mecanics
    send(pid, {:initialize, component, next_pids})
  end

  @doc """
  Process `value` on the bolt of `pid`.
  Bolt.process function will be called.
  """
  def process(pid, value) do
    send(pid, {:process, value})
  end

  defmacro __using__(_opts) do
    quote do
      @behaviour Bolt
    end
  end

  defp loop(map) do
    receive do
      {:initialize, component, next_pids} ->
        # Set the component and pids_next that this bolt will use
        map = Map.put(map, 'self', {component, next_pids})
        do_initialize(component)
        loop(map)
      {:process, value} ->
        {component, next_pids} = Map.get(map, 'self')
        do_process(component, next_pids, value)
        loop(map)
    end
  end

  defp do_initialize(component) do
    component.initialize()
  end

  defp do_process(component, next_pids, value) do
    value = component.process(value)

    # If bolt is not a leaf node, meaning it does
    # connect to other nodes
    if length(next_pids) != 0 do
      dispatch(next_pids, value)
    end
  end

  defp dispatch(_, []) do
  end

  defp dispatch(next_pids, [head|tail]) do
    dispatch(next_pids, head)
    dispatch(next_pids, tail)
  end

  defp dispatch(next_pids, value) do
    # TODO: this is where we need to implement logic
    # routing mecanics, like random, field, etc
    send(hd(next_pids), {:process, value})
  end
end
