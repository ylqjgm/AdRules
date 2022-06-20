#!/bin/bash
cd $(cd "$(dirname "$0")";pwd)
cd ./origin-files/
echo 开始处理DNS规则
yc=`cat wildcard-src-easylist.txt base-src-easylist.txt base-src-hosts.txt| grep -vE ']|@|!' |grep -v -E "^((#.*)|(\s*))$"  | grep -v -E "^[0-9\.:]+\s+(ip6\-)?(localhost|loopback)$"  | sed -e "s/||//g" -e "s/\^//g" -e "s/0.0.0.0 //g" -e "s/127.0.0.1 //g" | sed 's/[ ]//g'|sort|uniq `
wl=`cat ../allowlists.txt |sed "s/\#.*//g"`
dead=`cat base-dead-hosts.txt |sed "s/\#.*//g"`
wl0=`printf "%s\n" "$wl" |grep '^0 '`
wl1=`printf "%s\n" "$wl" |grep '^1 '`
printf "%s\n" "$yc" >pre-rules.txt
cat pre-rules.txt cat base-dead-hosts.txt cat base-dead-hosts.txt |sort |uniq -u > 1.txt
mv -f 1.txt pre-rules.txt

for i in $wl0
do
  sed -i 's/$i//g' pre-rules.txt &
done
wait
for i in $wl1
do
  sed -i 's/.*$i//g' pre-rules.txt &
done
wait
i=`cat pre-rules.txt|grep -v "#"|sed 's/.*#.*//g' | sed '/^$/d'`
echo "$i"| sed '/^$/d' >> ../../ad-domains.txt
echo "$i"| sed '/^$/d' >> ../../dns.txt
echo "$i"| sed '/^$/d' |sed 's/^/0.0.0.0 /g' >> ../../hosts.txt
wait
cd ../../
cat ./tmp/l.txt >> dns.txt

cat ./tmp/dns998* >> dns.txt
cat ./mod/rules/*-rules.txt |grep -E "^[(\@\@)|(\|\|)][^\/\^]+\^$" |sort|uniq >> dns.txt

cat ./script/*/white_domain_list.php |grep -Po "(?<=').+(?=')" | sed "s/^/||&/g" |sed "s/$/&^/g"| sed '/^$/d'   > allowtest.txt
hostlist-compiler -c ./script/dns-rules-config.json -o dns-output.txt &
wait
#rm -f allowtest.txt
mv -f dns-output.txt dns.txt
cat ./mod/rules/*-rules.txt |grep -E "^[(\@\@)][^\/\^]+\^$" |sort|uniq >> dns.txt
cd ./script/
cd ../
exit
