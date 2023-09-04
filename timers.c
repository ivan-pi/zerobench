#include <time.h>

// Time in seconds since some unspecified starting point
double timestamp(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double) ts.tv_sec + (double) ts.tv_nsec * 1.e-9;
}

// Resolution of the clock in seconds
double resolution(void) {
    struct timespec ts;
    clock_getres(CLOCK_MONOTONIC, &ts);
    return (double) ts.tv_sec + (double) ts.tv_nsec * 1.e-9;
}