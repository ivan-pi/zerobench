

FC = gfortran-13
CC = gcc-13
CXX = g++-13

FFLAGS = -Wall -fcheck=all -O2
CFLAGS = -Wall -O2
CXXFLAGS = -Wall -O2 -std=c++20

BOOST_INC = -I/usr/local/include
LDLIBS = -lstdc++

roots: roots.f90 zeroin.o timers.o root.o dzero.o d1mach.o brentq.o brent_zero.o toms748.o
	$(FC) -o $@ $(FFLAGS) $^ $(LDLIBS)

zeroin.o: zeroin.f
	$(FC) -c $(FFLAGS) $<
dzero.o: dzero.f
	$(FC) -c $(FFLAGS) $<
root.o: root.f
	$(FC) -c $(FFLAGS) -freal-4-real-8 $<
d1mach.o: d1mach.f90
	$(FC) -c $(FFLAGS) $<

# Brent's original translation from Algol
# (does not converge)
brent_zero.o: brent_zero.f
	$(FC) -c $(FFLAGS) -freal-4-real-8 $<

# SciPy Zeros
brentq.o: ./Zeros/brentq.c ./Zeros/zeros.h
	$(CC) -c $(CFLAGS) $<

# Boost
toms748.o: toms748.c ./Zeros/zeros.h
	$(CXX) -c $(CXXFLAGS) $(BOOST_INC) $<

timers.o: timers.c
	$(CC) -c $(CFLAGS) $<

.phony: clean

clean:
	rm -f *.o *.mod *.txt roots 
