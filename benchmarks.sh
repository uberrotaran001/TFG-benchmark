#!/bin/bash

mkdir -p output

USE_O_DIRECT=0
USE_O_SYNC=0
SHARED_MEMORY_BUFFER=0
MMAP_FILE_IO=0
NO_FSYNC_WR_RD=1
PRINT_SUBMIT_LATENCIES=0
PRINT_COMPLETION_LATENCIES=0
UNLINK_FILES=0
VERIFICATION_WRITTEN=0
TURN_OFF_STONEWALLING=1

extra=""

if [ $USE_O_DIRECT -ne "0" ]
then
  $extra=" -O"
fi

if [ $USE_O_SYNC -ne "0" ]
then
  $extra="$extra -S"
fi

if [ $SHARED_MEMORY_BUFFER -ne "0" ]
then
  $extra="$extra -m shm"
fi

if [ $MMAP_FILE_IO -ne "0" ]
then
  $extra="$extra -m shmfs"
fi

if [ $NO_FSYNC_WR_RD -ne "1" ]
then
  $extra="$extra -n"
fi

if [ $PRINT_SUBMIT_LATENCIES -ne "0" ]
then
  $extra="$extra -l"
fi

if [ $PRINT_COMPLETION_LATENCIES -ne "0" ]
then
  $extra="$extra -L"
fi

if [ $UNLINK_FILES -ne "0" ]
then
  $extra="$extra -u"
fi

if [ $VERIFICATION_WRITTEN -ne "0" ]
then
  $extra="$extra -v"
fi

if [ $TURN_OFF_STONEWALLING -ne "1" ]
then
  $extra="$extra -x"
fi

for size_align_buffer in 4
do
  for num_context_per_file in 1
  do
    for offset_context in 2
    do
      for size_testfile in 10 100 1024
      do
        for size_io in 64
        do
          for number_aio_pending in 64
          do
            for number_ios_file_switch in 8
            do
              for total_ios in "-1"
              do
                for operations in "0123"
                do
                  extra_oper=$extra
                  i=1
                  while [ $i -le ${#operations} ]
                  do
                    j=$(expr substr "$operations" "$i" 1)
                    i=$(($i+1))
                    extra_oper="$extra_oper -o $j"
                  done
                  for threads in 1 3 5
                  do
                    for files in "file1" "file1 file2 file3 file4 file5" "file1 file2 file3 file4 file5 file6 file7 file8 file9 file10"
                    do
                      num_files=0
                      for sum in $files
                      do
                        num_files=$(($num_files+1))
                      done
                      num=$(($num_files*$number_ios_file_switch*$num_context_per_file))
                      for max_iocbs in $num
                      do
                        if [ $1 -eq "0" ]
                        then
                          output_file="results_$3_fuera,$size_align_buffer,$num,$num_context_per_file,$offset_context,$size_testfile,$size_io,$number_aio_pending,$number_ios_file_switch,$total_ios,$threads.txt"
                          echo "Ejecutando en $3 fuera ./$2 -a $size_align_buffer -b $num -c $num_context_per_file -C $offset_context -s $size_testfile -r $size_io -d $number_aio_pending -i $number_ios_file_switch -I $total_ios -t $threads$extra_oper $files\n"
                          echo "Ejecutando en $3 fuera ./$2 -a $size_align_buffer -b $num -c $num_context_per_file -C $offset_context -s $size_testfile -r $size_io -d $number_aio_pending -i $number_ios_file_switch -I $total_ios -t $threads$extra_oper $files\n" > ./output/$output_file
                        else
                          if [ $1 -eq "1" ]
                          then
                            output_file="results_$3_contenedor,$size_align_buffer,$num,$num_context_per_file,$offset_context,$size_testfile,$size_io,$number_aio_pending,$number_ios_file_switch,$total_ios,$threads.txt"
                            echo "Ejecutando en $3 el contenedor singularity exec ./$2 -a $size_align_buffer -b $num -c $num_context_per_file -C $offset_context -s $size_testfile -r $size_io -d $number_aio_pending -i $number_ios_file_switch -I $total_ios -t $threads$extra_oper $files\n"
                            echo "Ejecutando en $3 el contenedor singularity exec ./$2 -a $size_align_buffer -b $num -c $num_context_per_file -C $offset_context -s $size_testfile -r $size_io -d $number_aio_pending -i $number_ios_file_switch -I $total_ios -t $threads$extra_oper $files\n" > ./output/$output_file
                          else
                            echo "\nERROR: Los formatos disponibles son\nsh benchmark.sh 0|1 EJECUTABLE_BENCHMARK ext4|BeeGFS\n0: Benchmark ejecutado sin Singularity\n1: Benchmark ejecutado con Singularity\n"
                            exit 1
                          fi
                        fi
                        ./$2 -a $size_align_buffer -b $num -c $num_context_per_file -C $offset_context -s $size_testfile -r $size_io -d $number_aio_pending -i $number_ios_file_switch -I $total_ios -t $threads$extra_oper $files 2>> ./output/$output_file
                        echo "\nFinalizado."
                        echo "\nFinalizado." >> ./output/$output_file
                      done
                    done
                  done
                done
              done
            done
          done
        done
      done
    done
  done
done

