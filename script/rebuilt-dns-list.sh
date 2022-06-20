#!/bin/bash
cd $(cd "$(dirname "$0")";pwd)
cd ./origin-files/
echo 开始处理DNS规则
yc=`cat wildcard-src-easylist.txt base-src-easylist.txt base-src-hosts.txt| grep -vE ']|@|!' |grep -v -E "^((#.*)|(\s*))$"  | grep -v -E "^[0-9\.:]+\s+(ip6\-)?(localhost|loopback)$"  | sed -e "s/||//g" -e "s/\^//g" -e "s/0.0.0.0 //g" -e "s/127.0.0.1 //g" | sed 's/[ ]//g'|sort|uniq `
wl=`cat ../mod-lists.txt |grep -v "^#" |sed "s/\#.*//g"`
dead=`cat base-dead-hosts.txt |sed "s/\#.*//g"`
wl0=`echo "$wl" |grep '^0 '|sed 's/0 //g'`
wl1=`echo "$wl" |grep '^1 '|sed 's/1 //g'`
wl2=`echo "$wl" |grep '^2 '|sed 's/2 //g'`
rm=`echo "$wl" |grep '^3 '|sed 's/3 //g'`
echo "$yc" >pre-rules.txt
cat pre-rules.txt cat base-dead-hosts.txt cat base-dead-hosts.txt |sort |uniq -u > 1.txt
mv -f 1.txt pre-rules.txt

for i in ${!wl0[@]} ${!wl1[@]} ${!wl2[@]}
do
  sed -i '/$wl0/d' pre-rules.txt &
  sed -i '/$wl2/d' pre-rules.txt &
  sed -i '/.*$wl1/d' pre-rules.txt &
done
wait
i=`cat pre-rules.txt|grep -v "#"|grep -v "\/"|grep -v "^\."|sed 's/.*#.*//g' | sed '/^$/d'`
echo "$i"| sed '/^$/d' > ../../ad-domains.txt
echo "$i"| sed '/^$/d' > ../../dns.txt
echo "$i"| sed '/^$/d' |sed 's/^/0.0.0.0 /g' > ../../hosts.txt
#echo "$i"| grep -v '\*' |sed 's/^/host-suffix,/g'|sed 's/$/,reject/g' > ../../qx.conf
wait
cd ../../
cat ./tmp/dns998* >> dns.txt
cat ./mod/rules/*-rules.txt |grep -E "^[(\@\@)][^\/\^]+\^$" |sort|uniq >> dns.txt

echo "wl2"|sed "s/^/\@\@\|\|/g" |sed "s/$/\^/g" >> dns.txt
#cat ./script/*/white_domain_list.php |grep -Po "(?<=').+(?=')" | sed "s/^/||&/g" |sed "s/$/&^/g"| sed '/^$/d'   > allowtest.txt
hostlist-compiler -c ./script/dns-rules-config.json -o dns-output.txt &
wait
rm -f allowtest.txt
mv -f dns-output.txt dns.txt
#通配符规则
for i in $rm
do
  sed -i "/||.*$i^/d" dns.txt
  echo "$i" |sed 's/^/||/g'|sed 's/$/\^/g'>> dns.txt
done
wait
#cd ./script/
#cd ../
cat dns.txt|grep -Po "(?<=\|\|).+(?=\^)"| grep -v '\*' |sed 's/^/host-suffix,/g'|sed 's/$/,reject/g' > ./qx.conf
exit
