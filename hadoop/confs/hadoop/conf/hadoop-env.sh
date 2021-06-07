export HADOOP_LOG_DIR=/data/hadooplogs
export JAVA_HOME=/usr/java/latest

#export JVM_OPTS="-XX:SurvivorRatio=6 -XX:MaxTenuringThreshold=4 -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+CMSClassUnloadingEnabled -XX:-CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=80 -XX:SoftRefLRUPolicyMSPerMB=0 "

export JVM_OPTS="-server -XX:SurvivorRatio=8 -XX:MaxTenuringThreshold=10 -verbose:gc -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M  -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintGCDetails  -XX:+PrintTenuringDistribution -XX:+PrintGCApplicationConcurrentTime -XX:+PrintGCApplicationStoppedTime -XX:+UseConcMarkSweepGC -XX:+UseCMSInitiatingOccupancyOnly -XX:+UseParNewGC -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:+CMSClassUnloadingEnabled -XX:-CMSParallelRemarkEnabled -XX:CMSInitiatingOccupancyFraction=80 -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+UseFastAccessorMethods -XX:ParallelGCThreads=4"

#export JVM_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:SurvivorRatio=8 -XX:MaxTenuringThreshold=10   -verbose:gc -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M  -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintGCDetails  -XX:+PrintTenuringDistribution -XX:+PrintGCApplicationConcurrentTime -XX:+PrintGCApplicationStoppedTime "

export YARN_OPTS="$JJVM_OPTS -Xloggc:/data/hadooplogs/rm_gc.log"
#export HADOOP_OPTS="$JVM_OPTS"
export HADOOP_CLIENT_OPTS=" -Xloggc:/dev/null "

export HADOOP_NAMENODE_OPTS="-Xmx95g -Xms95g -Xmn20g $JVM_OPTS -Xloggc:/data/hadooplogs/nn_gc.log"
export HADOOP_SECONDARYNAMENODE_OPTS="-Xmx85g -Xms85g -Xmn30g $JVM_OPTS -Xloggc:/data/hadooplogs/snn_gc.log"
export HADOOP_DATANODE_OPTS="-Xmx5g -Dcom.sun.management.jmxremote $HADOOP_DATANODE_OPTS -Xloggc:/data/hadooplogs/dn_gc.log"
export HADOOP_BALANCER_OPTS="-Dcom.sun.management.jmxremote $HADOOP_BALANCER_OPTS"
export HADOOP_JOBTRACKER_OPTS="-Xmx10g -Xmn5g $JVM_OPTS"
export HADOOP_JOB_HISTORYSERVER_OPTS="-Xmx15g -XX:+UseG1GC "

export HADOOP_HEAPSIZE=10000

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
