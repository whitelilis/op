#!/bin/bash
ping -c1 -w3 $1 | grep from | awk '{print $4 "  " $5}' | sed -e 's/[():]//g'
