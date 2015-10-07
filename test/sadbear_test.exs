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
