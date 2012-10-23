#!/bin/bash

dir=${1:-"t1"}
runs=${2:-1}
echo "Running with: "$dir" "$runs
cd $dir
rm *~
rm -rf rez*
#echo $runs
noFiles=$(grep -l '}' * | wc -l)
if [ $noFiles != 1 ]
then
  echo MORE THAN 1 FILE MATCHING PATTERN
  exit
fi
file=$(grep -l '}' *)
echo $file

noMatches=$(grep -c '}' $file)
if [ $noMatches != 1 ]
then
  echo MORE THAN 1 PATTERN IN $file
  exit
fi

mv $file "source"

pat=$(grep -Eoh '[{][0-9.]+-[0-9.]+-[0-9.]+}' "source")
p1=$(echo $pat | grep -Eo '^[{][0-9.]+')
n1=${p1:1}
p2=${pat:${#p1}+1}
n2=$(echo $p2 | grep -Eo '^[0-9.]+')
p3=${pat:${#p1}+${#n2}+2}
n3=$(echo $p3 | grep -Eo '^[0-9.]+')

vals=$(seq $n1 $n3 $n2)

count=0
for v in $vals
do
  rezDir="rez$v"
  #rm -rf $rezDir
  mkdir $rezDir

  count=$(($count+1))
  sed s/$pat/$v/ "source" > $file
  for i in $(seq 1 $runs)
  do
    echo $dir, $count, $v, $i
    fl=$rezDir"/"$i".out"
    ../KaSim_3 -i 1_TCA.ka -i 2_NapC.ka -i 5.ka -t 2.5E6 -p 1000 -o model.temp
    cat model.temp | cut -c 2- > $fl
    rm model.temp
  done
  rm $file
done

mv "source" $file

#java -jar ../MeanPlotViewer-v0.0.1.jar
