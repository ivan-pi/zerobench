

FC = gfortran-13
CC = gcc-13

FFLAGS = -Wall -fcheck=all -O2
CFLAGS = -Wall -O2

roots: roots.f90 zeroin.o timers.o root.o dzero.o d1mach.o brentq.o
	$(FC) -o $@ $(FFLAGS) $^

zeroin.o: zeroin.f
	$(FC) -c $(FFLAGS) $<
dzero.o: dzero.f
	$(FC) -c $(FFLAGS) $<
root.o: root.f
	$(FC) -c $(FFLAGS) -freal-4-real-8 $<
d1mach.o: d1mach.f90
	$(FC) -c $(FFLAGS) $<

# SciPy Zeros
brentq.o: ./Zeros/brentq.c ./Zeros/zeros.h
	$(CC) -c $(CFLAGS) $<

timers.o: timers.c
	$(CC) -c $(CFLAGS) $<

.phony: clean

clean:
	rm -f *.o *.mod *.txt roots 
