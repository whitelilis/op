#!/bin/bash
mem_g=$(free -g | head -2 |tail -1 | awk '{print $2}')
echo $(hostname) $mem_g
