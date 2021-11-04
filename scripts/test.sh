#!/bin/bash
url=https://$1/

for i in `seq 1 10`;
do
     curl --silent $url
done
