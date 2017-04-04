#!/bin/bash

#Find something excluding mounted drives
find / -path /mnt -prune -o -name $1
