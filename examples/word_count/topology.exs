import SadBear
import LineSpout
import SplitBolt
import CountBolt

topology = {{'line', LineSpout, 1, 'split'},
  [{'split', SplitBolt, 2, 'count'}, {'count', CountBolt, 1, nil}]}
SadBear.initialize()
SadBear.make(topology)
