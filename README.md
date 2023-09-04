# Zerobench

Benchmark of `zeroin` for discussion at: https://fortran-lang.discourse.group/t/using-reserved-words-as-variables/6398/55

## Run

```
chmod +x launch.sh plot.py
./launch.sh && ./plot.py
```

## Files

- `root.f90` - Fortran wrapper modules and benchmark driver
- `timers.c` - Timers
- `launch.sh` - Bash script used to launch driver
- `plot.py` - Python 3 script for plotting
- `Makefile` - Makefile for compiling targets

The root solvers available are:
- `zeroin.f` from Forsythe, Malcolm, and Moler (1987)
- `dzero.f` from the PORT Mathematical Software Library
- `root.f` from the NAPACK Fortran library
- `brentq.c` from SciPy

## Acknowledgements

A few bits and pieces are borrowed from other places, including
- `d1mach` from https://degenerateconic.com/
- `urandom_seed` from https://cyber.dabamos.de/programming/modernfortran/random-numbers.html