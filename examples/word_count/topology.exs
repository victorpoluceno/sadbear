import Sadbear
import LineSpout
import SplitBolt
import CountBolt

CountBolt.initialize()
Sadbear.run(&LineSpout.next_tuple/0, [&SplitBolt.process/1, &CountBolt.process/1])