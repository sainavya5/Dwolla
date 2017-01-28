#!/bin/bash

declare -A hashmap

if [ $# -ne 2 ];then
	echo "Usage $0 <Input file name> <Source url>"
	exit 0
fi

filename=$1
aws_url=$2
outputfile=output.json

while read -r line;do
	if [ "$(echo $line | grep -i reject)" != "" ];then
		src_ip=`echo $line | cut -d " " -f 4`
		count=${hashmap[$src_ip]}
		hashmap[$src_ip]=$((count+1))
	fi
done < "$filename"

printf "[" > $outputfile
for i in "${!hashmap[@]}"
do
	src_ip=`echo $i`
	reject_count=`echo ${hashmap[$i]}`
	printf "\n {\n  \"SOURCE_IP\":%s,\n  \"Reject Count\":%s\n }," "$src_ip" "$reject_count" >> $outputfile
done
printf "\n]\n" >> $outputfile

aws_url=`echo $aws_url | cut -c 6-`
bucket=`echo $aws_url |  awk -F "/" '{print$1}'`
key=`echo $aws_url |  awk -F "/" '{print$2}'`
aws s3api put-object --bucket $bucket --key $key --body $outputfile
