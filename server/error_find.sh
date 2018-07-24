#!/usr/bin/env bash
# 打印后五行加上前面3行

first_error="stack traceback"
other_error=( "protobuf.lua:307" "invalid msgname" "invalid params" "badresult" )

divide="|"
for k in "${other_error[@]}"
do
	#echo ${k}
    first_error=${first_error}${divide}${k}
done
#echo $first_error

grep -n -A 5 -B 5 -R -E --include="error.log" "$first_error" ./
grep -n -A 5 -B 5 -R -E --include="systemlog" "$first_error" ./
#grep -n -A 5 -B 5 -n -R --include="*.log" "stack traceback" ./

grep -n -A 5 -B 5 -R -E --include="systemlog" "Connection refused" ./
grep -n -A 5 -B 5 -R -E --include="systemlog" "Error: socketd" ./


