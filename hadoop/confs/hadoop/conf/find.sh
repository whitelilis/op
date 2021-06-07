#!/bin/bash
for blk in blk_1173803600 blk_1318309265 blk_1617759536
do
	find / -name "${blk}*"
done > /tmp/find_result  &
