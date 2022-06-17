#!/bin/sh
cname=(
 "tanx.com"
)
rm=(
 "windows.net"
)
for i in $cname
do
  sed -i "s/||$i^/||$i^\$dnstype=~CNAME/" dns.txt
done

for i in $rm
do
  sed -i "s/||$i^/||$i^\$dnstype=~CNAME/" dns.txt
done
