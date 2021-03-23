#!/usr/bin/env sh

sh -c 'cd /local; ran -p 3333 -cors=1 -l' & 
sh /usr/share/nginx/run.sh
