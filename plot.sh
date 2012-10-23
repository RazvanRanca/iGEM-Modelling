#!/bin/bash

fl='"model_4_0.out"' 
comm=""

echo $0, $1, $2

./KaSim_2 -i model_4_0.ka -t 1.0E-3 -p 100 -o model_4_0.temp
cat model_4_0.temp | cut -c 2- > model_4_0.out
rm model_4_0.temp

for i in 4 5 6 7
do
  comm="$comm, $fl u 1:$i w lp"
done

comm=${comm:1}

gnuplot -persist <<TillHere

set key autotitle columnhead
plot $comm
TillHere


# plot "model_5_0.temp" u 1:4 w lp, "model_5_0.temp" u 1:5 w lp, "model_5_0.temp" u 1:6 w lp, "model_5_0.temp" u 1:7 w lp
# plot "model_4_0.temp" u 1:4 w lp, "model_4_0.temp" u 1:5 w lp, "model_4_0.temp" u 1:6 w lp, "model_4_0.temp" u 1:7 w lp
# KaSim -i model_4_0.ka -t 1.0E-3 -p 100 -o model_4_0.temp
# KaSim -i model_5_0.ka -t 1.0E-3 -p 100 -o model_5_0.temp