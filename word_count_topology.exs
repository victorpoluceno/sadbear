import Sadbear
import WordCountSpout
import WordCountBolt
import WordCountBolt2

Sadbear.run(&WordCountSpout.next_tuple/0, [&WordCountBolt.process/1, &WordCountBolt2.process/1])