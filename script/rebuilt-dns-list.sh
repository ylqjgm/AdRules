#!/bin/bash
cd ./origin-files
yc=`cat dns* hosts*| grep -vE ']|@|!' |grep -v -E "^((#.*)|(\s*))$"  | grep -v -E "^[0-9\.:]+\s+(ip6\-)?(localhost|loopback)$"  | sed -e "s/||//g" -e "s/\^//g" -e "s/0.0.0.0 //g" -e "s/127.0.0.1 //g" | sed 's/[ ]//g'|sort|uniq `
wl=`cat allow-lists.txt |sed "s/\#.*//g"`
dead=`cat base-dead-hosts.txt |sed "s/\#.*//g"`
wl0=`printf "%s\n" "$wl" |grep '^0 '`
wl1=`printf "%s\n" "$wl" |grep '^1 '`
printf "%s\n" "$yc" >pre-rules.txt
for i in $wl0
do
  sed -i 's/$i//g' pre-rules.txt &
done
wait 
for i in $dead
do
  sed -i 's/$i//g' pre-rules.txt &
done
wait
for i in $wl1
do
  sed -i 's/.*$i//g' pre-rules.txt &
done
wait
i=`cat pre-rules.txt`
printf "%s\n" "$i" >> ad-domains.txt
printf "%s\n" "||$i^" >> dns.txt
printf "%s\n" "0.0.0.0 $i" >> hosts.txt
wait
exit