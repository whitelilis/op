echo >> /etc/security/limits.conf <<END
*     soft nofile      30000
*     hard nofile      30000
*     soft nproc       30000
*     hard nproc       30000

root     soft nofile      30000
root     hard nofile      30000
root     soft nproc       30000
root     hard nproc       30000
END


echo >> /etc/sysctl.d/30-baihai.conf <<END
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
END


echo >> /etc/rc.local <<END
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo 1 > /proc/sys/vm/overcommit_memory
END
