
#include <boost/math/tools/precision.hpp>
#include <boost/math/tools/roots.hpp>

#include "Zeros/zeros.h"

#include <iostream>

template <class T>
struct eps_xtol
{
   eps_xtol(T xtol) : xtol_(xtol) {};

   const T xtol_;
   bool operator()(const T& a, const T& b) const {
        return abs(b - a) <= xtol_;
   }
};

extern "C"
double toms748(double ax, double bx, callback_type f, double tol, void *ptr)
{
    using boost::math::tools::toms748_solve;
    using boost::math::tools::eps_tolerance;

    //int bits = std::numeric_limits<double>::digits;
    boost::uintmax_t max_iter = 10000000;

    //auto tolop = eps_tolerance<double>(bits-2);
    //auto tolop = eps_xtol<double>(tol);

    auto [xa,xb] = toms748_solve(
            [=](const double &x) { return f(x,ptr); },
            ax,bx,
            //tolop,
            [tol](const double& a, const double& b) {
                return abs(b - a) <= tol;
            },
            max_iter);
    return 0.5*(xa + xb);
}