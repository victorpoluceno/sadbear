defmodule Sadbear do
  def run(next_tuple, flow) do
    emit(next_tuple.(), flow)
    run(next_tuple, flow)
  end

  def emit(value, []) do
  end

  def emit(value, flow) do
  	return = hd(flow).(value)
  	emit(return, tl(flow))
  end
end 