(for f in $(cat v_dns); do ssh $f 'cat /tmp/ping_error_log 2>/dev/null' < /dev/zero & done 2> /dev/null | grep slave | sort) > /tmp/diff
tail /tmp/diff; date
