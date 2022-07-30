#!/bin/bash

current=""
next=""

while ! timeout 1 bash -c "echo > /dev/tcp/result/80"; do
    sleep 1
done

# add initial result
curl -sS -X POST --data "result=a" http://result > /dev/null

current=`phantomjs render.js "http://result:4000/" | grep -i result | cut -d ">" -f 4 | cut -d " " -f1`
next=`echo "$(($current + 1))"`

  echo -e "\n\n-----------------"
  echo -e "Current results Count: $current"
  echo -e "-----------------\n"

echo -e " I: Submitting one more result...\n"

curl -sS -X POST --data "result=b" http://result > /dev/null
sleep 3

new=`phantomjs render.js "http://result:4000/" | grep -i result | cut -d ">" -f 4 | cut -d " " -f1`


  echo -e "\n\n-----------------"
  echo -e "New results Count: $new"
  echo -e "-----------------\n"

echo -e "I: Checking if results tally......\n"

if [ "$next" -eq "$new" ]; then
  echo -e "\\e[42m------------"
  echo -e "\\e[92mTests passed"
  echo -e "\\e[42m------------"
  exit 0
else
  echo -e "\\e[41m------------"
  echo -e "\\e[91mTests failed"
  echo -e "\\e[41m------------"
  exit 1
fi
