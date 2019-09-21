#!/bin/bash
# author fangyh
num_gpus=`lspci | grep VGA | grep 'NVIDIA' | wc -l`
lines_date=7
pre_lines=$(( $lines_date + $num_gpus * 3 + 6))
lines=${pre_lines},"$"p


data=`nvidia-smi| sed -n "$lines" | head -n -1`

gpus=`echo "$data" | awk '{print $2}'`
pids=`echo "$data" | awk '{print $3}'`
mems=`echo "$data" | awk '{print $(NF-1)}'`

total_memory=`nvidia-smi| sed -n 8,9p |  awk '{print $11}' | tail -n 1`

names_arr=()
gpus_arr=()
mems_arr=()
pids_arr=()

for gpu in $gpus;
do
	gpus_arr+=($gpu)
done

for mem in $mems;
do
	mems_arr+=($mem)
done

for pid in $pids;
do
	res=`ps aux | awk '!/grep/' | grep $pid`
	name=`echo $res | awk '$2=$pid{print $1}'`
	names_arr+=($name)
	pids_arr+=($pid)
done

len=${#names_arr[@]}
pre_id="0"
printf "%0.s-" {1..68}
printf "\n"
printf "%12s %12s %12s %12s %12s\n"  names pid gpus_id memm totmem
printf "%0.s-" {1..68}
printf "\n"

for ((i=0;i<len;i++));
do
	printf "%12s %12s %12s %12s %12s\n" ${names_arr[i]} ${pids_arr[i]}   ${gpus_arr[i]}  ${mems_arr[i]} ${total_memory}
	if [ "${gpus_arr[i+1]}" != "$pre_id" ]  ; 
	then
		printf "%0.s-" {1..68}
		printf "\n"
		pre_id=${gpus_arr[i+1]}
	fi
done
