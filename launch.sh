#!/usr/bin/env bash

run_trial () {
    for (( i = 0; i < $1; i++)); do
        ./roots
    done
}

compile_and_run () {
    echo "Running example with flags: $1"
    rm -f roots zeroin.o brentq.o
    make FC=gfortran-13 CC=gcc-13 FFLAGS="$1" CFLAGS="$1"
    run_trial $2 | tee $3
}

gfortran-13 -v
gcc-13 -v

N=10
compile_and_run "-O0" $N "results_O0.txt"
compile_and_run "-O1" $N "results_O1.txt"
compile_and_run "-O2" $N "results_O2.txt"
compile_and_run "-O3" $N "results_O3.txt"
