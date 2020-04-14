#!/bin/sh
DIR=$(cd $(dirname $0); pwd)
cd $DIR
./Bin/lua main.lua $DIR/Objs/model.obj $DIR/OutPut/output.obj
