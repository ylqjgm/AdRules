#!/bin/bash

source /etc/profile

cd $(cd "$(dirname "$0")";pwd)

php make-dns-addr.php
echo
echo "! Title: AdRules for AdGuard" > ../easylist.txt
echo "! Version: $(date "+%Y%m%d%H%M%S%N")" >> ../easylist.txt
echo "! Homepage: https://github.com/Cats-Team/AdRules" >> ../easylist.txt
echo "! Total lines: 00000" >> ../easylist.txt
grep -vE '^!' ../dns.txt >> ../easylist.txt
php ./tools/adguard-extend.php ../easylist.txt &
wait
php ./tools/easylist-extend.php ../dns.txt &
cd ../
cat ./tmp/l.txt >> dns.txt
cat ./script/*/white_domain_list.php |grep -Po "(?<=').+(?=')" |sed "s/^/||&/g" |sed "s/$/&^/g"| sed '/^$/d'   > allowtest.txt
hostlist-compiler -c ./script/dns-rules-config.json -o dns-output.txt &
wait
mv -f dns-output.txt dns.txt
cd ./script/

cat ../tmp/dns998* >>../dns.txt
cat .././mod/rules/*-rules.txt |grep -E "^[(\@\@)|(\|\|)][^\/\^]+\^$" |sort|uniq >> ../dns.txt
#sed -i "s/\|\|tanx.com\^/\|\|tanx.com\^\$dnstype\=\~CNAME/" ../dns.txt
cd ../
bash ./sc*/exin*dns.sh
