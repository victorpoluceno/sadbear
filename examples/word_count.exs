import SadBear
import Bucket

defmodule CountBolt do
  @doc """
  On initialization start a Bucket agent.
  """
  def initialize() do
    Bucket.start_link()
  end

  @doc """
  Count words and print.
  """
  def process(value) do
    count = Bucket.get(value)
    if count == nil do
      count = 1
    else
      count = count + 1
    end

    Bucket.put(value, count)
    IO.puts("#{value} -> #{count}")
  end
end

defmodule LineSpout do
  @text "Lorem ipsum dolor sit amet, consectetur
adipiscing elit. Curabitur pharetra ante eget
nunc blandit vestibulum. Curabitur tempus mi
a risus lacinia egestas. Nulla faucibus
elit vitae dignissim euismod. Fusce ac
elementum leo, ut elementum dui. Ut
consequat est magna, eu posuere mi
pulvinar eget. Integer adipiscing, quam vitae
pretium facilisis, mi ligula viverra sapien,
nec elementum lacus metus ac mi.
Morbi sodales diam non velit accumsan
mollis. Donec eleifend quam in metus
faucibus auctor. Cras auctor sapien non
mauris vehicula, vel aliquam libero luctus.
Sed eu lobortis sapien. Maecenas eu
fringilla enim. Ut in velit nec
lectus tincidunt varius. Sed vel dictum
nunc. Morbi mollis nunc augue, eget
sagittis libero laoreet id. Suspendisse lobortis
nibh mauris, non bibendum magna iaculis
sed. Mauris interdum massa ut sagittis
vestibulum. In ipsum lacus, faucibus eu
hendrerit at, egestas non nisi. Duis
erat mauris, aliquam in hendrerit eget,
aliquam vel nibh. Proin molestie porta
imperdiet. Interdum et malesuada fames ac
ante ipsum primis in faucibus. Praesent
vitae cursus leo, a congue justo.
Ut interdum tellus non odio adipiscing
malesuada. Mauris in ante nec erat
lobortis eleifend. Morbi condimentum interdum elit,
quis iaculis ante pharetra id. In"

  def initialize() do
    String.split(@text, "\n")
  end

  def next_tuple([]) do
    {nil, []}
  end

  def next_tuple(nil) do
    {nil, []}
  end

  def next_tuple(context) do
    [head|tail] = context
    {head, tail}
  end
end

defmodule SplitBolt do
  @doc """
  """
  def initialize() do
  end

  @doc """
  Sprint a string into words and emit each word.
  """
  def process(value) do
    IO.puts(value)
    String.split(value)
  end
end

topology = {{'line', LineSpout, 1, 'split'},
  [{'split', SplitBolt, 2, 'count'}, {'count', CountBolt, 1, nil}]}
SadBear.initialize()
SadBear.make(topology)
