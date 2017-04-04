#!/bin/bash
#Transmission CLI for downloading Ubuntu Linux torrents only.
screen transmission-cli -d 400 -u 4 -g /mnt/sda1/session/ -p 9594 -w /mnt/sda9/ $1
