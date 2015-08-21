defmodule Sadbear do
  def run(next_tuple, flow) do
    emit(next_tuple.(), flow)
    run(next_tuple, flow)
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