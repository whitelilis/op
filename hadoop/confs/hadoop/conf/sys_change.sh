#!/bin/bash
/sbin/sysctl -w net.nf_conntrack_max=655360
/sbin/sysctl -w net.ipv4.netfilter.ip_conntrack_max=655360
/sbin/sysctl -w net.ipv4.tcp_tw_reuse=1
/sbin/sysctl -w net.ipv4.tcp_tw_recycle=1
/sbin/sysctl -w net.ipv4.tcp_fin_timeout=10
