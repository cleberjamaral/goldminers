This project
-----------
This goldminers project is a testing [JaCaMo](http://jacamo.sourceforge.net/) system for sharing a central CArtAgO environment with remote agents, using CArtAgO infrastruture.

It is based on original [JaCaMo tutorial](http://jacamo.sourceforge.net/tutorial/gold-miners/). Here, the miners are not so smart as the ones in the original tutorial. The idea here was to simplify the codes avoid the use of concurrent libraries and to be more readable.

The jcm file [goldminers.jcm](https://github.com/cleberjamaral/goldminers/blob/master/gold_miners.jcm) is where the server run, the part that creates the environment and wait for entrant client(s). The miners on this jcm file can be uncommented to make them run on server directly.
The jcm file [joiningminer.jcm](https://github.com/cleberjamaral/goldminers/blob/master/joining_miner.jcm) is the project file of the client(s). It may run on the same machine or remotely. By the way, an agent based on [dumb_miner3.asl](https://github.com/cleberjamaral/goldminers/blob/master/src/agt/dumb_miner3.asl) is able to run on a [raspberry pi](https://www.raspberrypi.org/) and turn on led on the board when it is carrying gold.

Compiling and running
-----------

To compile and run the server using [gradle](https://github.com/jacamo-lang/jacamo):

    $ gradle server


For clients, first edit joining miner.jcm to lauch some miner and edit dumb_miner corresponding file, uptading "server_name" on command "joinRemoteWorkspace(mining,"server_name",WId)".
Then, to compile and run each client with them local joiningminer.jcm files:

    $ gradle client

Troubleshooting
-----------
For remote connection the joining miner uses CArtAgO infrastruture, which in based on java RMI connection. Server and client(s) machines must be visible on the network by names, so na [DNS server or /etc/hosts file configured by hand](https://stackoverflow.com/questions/47624559/cartago-java-rmi-connectexception-connection-refused-in-a-distributed-environmen/47624959#47624959) is necessary.
