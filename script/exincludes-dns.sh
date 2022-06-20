#!/bin/sh
rm=`cat ./sc*/allowlist.txt|grep '3 '|sed 's/3 //g'`
for i in $rm
do
  sed -i "s/||.*$i^/d" dns.txt
  echo "$i" |sed 's/^/||/g'|sed 's/$/\^/g'>> dns.txt
done
