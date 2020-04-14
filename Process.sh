#!/bin/sh
DIR=$(cd $(dirname $0); pwd)
cd $DIR

for ((j=1;j<=1;j++))
do
    if [ $j==1 ];
    then ./Bin/lua main.lua $DIR/Objs/model.obj $DIR/OutPut/output.obj
    else
         ./Bin/lua main.lua $DIR/OutPut/output.obj $DIR/OutPut/output.obj
    fi
done