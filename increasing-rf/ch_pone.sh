#!/bin/bash

list1=(`ls -a ./work/pone/*.json|sort`)
list2=("1,2,3" "2,3,1" "3,1,2")

len1=${#list1[@]}
len2=${#list2[@]}

max_len=$((len1 > len2 ? len1 : len2))

for ((i=0; i<$max_len; i++))
do
  elem1=${list1[$i]}
  elem2=${list2[$i % len2]}
  echo "$elem1 $elem2"
  sed -i "s/1,2,3/$elem2/g" $elem1
done
