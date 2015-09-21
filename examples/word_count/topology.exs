import Sadbear
import LineSpout
import SplitBolt
import CountBolt



SplitBolt.initialize()
CountBolt.initialize()


topology = {{'line', LineSpout, 1}, [{'split', SplitBolt, 2}, {'count', CountBolt, 2}]}
Sadbear.run(topology)


#Sadbear.run(&LineSpout.next_tuple/0, [&SplitBolt.process/1, &CountBolt.process/1])
