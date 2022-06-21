#!/bin/bash

if [ "$1" = "ext4" -o "$1" = "BeeGFS" ]
then
  CONTENEDOR="cont21"
  SCRIPT_BENCHMARKS="benchmarks.sh"
  EJECUTABLE_BENCHMARK="aio-stress"

  sh $SCRIPT_BENCHMARKS 0 $EJECUTABLE_BENCHMARK $1
  singularity exec $CONTENEDOR sh $SCRIPT_BENCHMARKS 1 $EJECUTABLE_BENCHMARK $1
else 
  echo "Error de formato: sh $0 ext4|BeeGFS"
fi
