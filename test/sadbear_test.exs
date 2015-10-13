defmodule SadBearTest do
  use ExUnit.Case

  test "the truth" do
    assert 1 + 1 == 2
  end
end

defmodule SadBearTest.Bucket do
  use ExUnit.Case, async: true

  test "stores values by key" do
    {:ok, _} = Bucket.start_link
    assert Bucket.get("milk") == nil
    assert Bucket.get("milk", 0) == 0

    Bucket.put("milk", 3)
    assert Bucket.get("milk") == 3
  end
end

defmodule TestBolt do
  def initialize() do
    send(:test, {:called_back})
  end

  def process(value) do
    send(:test, {:called_back, value})
    value
  end
end

defmodule TestBoltNext do
  def initialize() do
  end

  def process(value) do
    result = value <> "world"
    send(:test, {:called_back_from_next, result})
  end
end

defmodule SadBearTest.Bolt do
  use ExUnit.Case, async: true

  test "test start_link, initialize and process" do
    Process.register self, :test

    {:ok, pid} = Bolt.start_link()
    Bolt.initialize(pid, TestBolt, [])
    assert_receive {:called_back}

    Bolt.process(pid, "hello")
    assert_receive {:called_back, "hello"}
  end

  test "test process to next" do
    Process.register self, :test

    {:ok, pid} = Bolt.start_link()
    {:ok, pid_next} = Bolt.start_link()

    Bolt.initialize(pid, TestBolt, [pid_next])
    Bolt.initialize(pid_next, TestBoltNext, [])

    Bolt.process(pid, "hello")
    assert_receive {:called_back_from_next, "helloworld"}
  end
end

defmodule TestSpout do
  def initialize() do
    send(:test_spout, {:called_back})
  end

  def next_tuple(_context) do
    {nil, nil}
  end
end

defmodule SadBearTest.Spout do
  use ExUnit.Case, async: true

  test "test start_link and initialize" do
    Process.register self, :test_spout

    {:ok, pid} = Spout.start_link()
    Spout.initialize(pid, TestSpout, [])
    assert_receive({:called_back})
  end
end
