wget http://mainrm.master.adh:8088/cluster/nodes
wget http://mainrm.master.adh:8088/cluster/nodes/unhealthy
grep .slave.adh:8042 nodes unhealthy | cut -d'>' -f2 | cut -d'<' -f1 |cut -d':' -f1|sort > active_nodemanager
rm -rf nodes unhealthy
