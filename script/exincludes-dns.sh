#!/bin/sh
cname=(
 "tanx.com"
)
for i in $cname
do
  sed -i "s/||$i^/||$i^\$dnstype=~CNAME/" dns.txt
done
