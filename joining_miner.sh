#!/bin/sh
cd /home/pi/Projetos/goldminers
#java -Dpi4j.linking=dynamic -classpath /homer/pi/jacamo-0.7/libs/ant-launcher-1.10.1.jar org.apache.tools.ant.launch.Launcher -e -f bin/joining_miner.xml run
java -classpath /home/pi/jacamo-0.7/libs/ant-launcher-1.10.1.jar org.apache.tools.ant.launch.Launcher -e -f bin/joining_miner.xml run
