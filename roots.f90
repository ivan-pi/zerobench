module roots

implicit none
private

public :: dp, pf
public :: pzeroin, pzero, proot

integer, parameter :: dp = kind(1.0d0)

abstract interface 
    function zerofun(x)
        import dp
        implicit none
        real(dp), intent(in) :: x
        real(dp) :: zerofun
    end function
    function pf(x, params)
        import dp
        implicit none
        real(dp), intent(in) :: x, params(*)
        real(dp) :: pf
    end function
end interface

interface

    ! FMM: https://netlib.org/fmm/
    ! The original procedure from Forsythe, Malcolm, and Moler
    ! available from zeroin.f
    function zeroin(ax,bx,f,tol)
        import dp, zerofun
        implicit none
        real(dp), intent(in) :: ax, bx
        procedure(zerofun) :: f
        real(dp), intent(in) :: tol
        real(dp) :: zeroin
    end function

    ! PORT: https://netlib.org/port/dzero.f
    function dzero(f,a,b,t)
        import dp, zerofun
        implicit none
        real(dp), intent(in) :: a, b  ! Bracket
        real(dp), intent(in) :: t     ! Tolerance
        procedure(zerofun) :: f
        real(dp) :: dzero
    end function

    ! NAPACK: https://netlib.org/napack/
    ! root - Solve a scalar equation
    function root(y,z,t,f)
        import dp, zerofun
        implicit none
        real(dp), intent(in) :: y, z  ! Bracket
        real(dp), intent(in) :: t     ! Tolerance
        procedure(zerofun) :: f
        real(dp) :: root
    end function

end interface

contains

    real(dp) function pzeroin(ax,bx,f,tol,params) result(rx)
        real(dp), intent(in) :: ax, bx, tol, params(*)
        procedure(pf) :: f
        rx = zeroin(ax,bx,fwrap,tol)
    contains
        function fwrap(x)
            real(dp), intent(in) :: x
            real(dp) :: fwrap
            fwrap = f(x,params)
        end function
    end function

    real(dp) function pzero(ax,bx,f,tol,params) result(rx)
        real(dp), intent(in) :: ax, bx, tol, params(*)
        procedure(pf) :: f
        rx = dzero(fwrap,ax,bx,tol)
    contains
        function fwrap(x)
            real(dp), intent(in) :: x
            real(dp) :: fwrap
            fwrap = f(x,params)
        end function
    end function

    real(dp) function proot(ax,bx,f,tol,params) result(rx)
        real(dp), intent(in) :: ax, bx, tol, params(*)
        procedure(pf) :: f
        rx = root(ax,bx,tol,fwrap)
    contains
        function fwrap(x)
            real(dp), intent(in) :: x
            real(dp) :: fwrap
            fwrap = f(x,params)
        end function
    end function

end module

module scipy

use, intrinsic :: iso_c_binding
implicit none
private

public :: pbrentq

type, bind(c) :: scipy_zeros_info
    integer(c_int) :: funcalls
    integer(c_int) :: iterations
    integer(c_int) :: errornum
end type

abstract interface
    function callback_type(x,param) bind(c)
        import c_double, c_ptr
        real(c_double), value :: x
        type(c_ptr), value :: param
        real(c_double) :: callback_type
    end function
end interface

integer(c_int), parameter :: CONVERGED = 0
integer(c_int), parameter :: SIGNERR = -1
integer(c_int), parameter :: CONVERR = -2
integer(c_int), parameter :: EVALUEERR = -3
integer(c_int), parameter :: INPROGRESS = 1

interface
    ! SciPy solver
    ! https://github.com/scipy/scipy/blob/v1.11.2/scipy/optimize/Zeros/zeros.h
    function brentq(f,xa,xb,xtol,rtol,iter,func_data_param,solver_stats) &
            bind(c,name="brentq")
        import
        implicit none
        procedure(callback_type) :: f
        real(c_double), value :: xa, xb, xtol, rtol
        integer(c_int) :: iter
        type(*) :: func_data_param
        type(scipy_zeros_info), intent(inout) :: solver_stats
        real(c_double) :: brentq
    end function

end interface

contains

    real(c_double) function pbrentq(ax,bx,f,tol,params) result(rx)
        use roots, only: pf
        real(c_double), intent(in) :: ax, bx, tol, params(*)
        procedure(pf) :: f

        real(c_double), parameter :: rtol = 4 * epsilon(1.0_c_double)
        integer, parameter :: maxiter = 100
        type(scipy_zeros_info) :: stats

        rx = brentq(fwrap,ax,bx,tol,rtol,maxiter,c_null_ptr,stats)
        if (stats%errornum /= CONVERGED) error stop stats%errornum

    contains
        function fwrap(x,ptr) bind(c)
            real(c_double), value :: x
            type(c_ptr), value :: ptr ! unused
            real(c_double) :: fwrap
            fwrap = f(x,params)
        end function
    end function

end module

module timers
use, intrinsic :: iso_c_binding, only: c_double
implicit none
public 
interface
    function timestamp() bind(c)
        import c_double
        real(c_double) :: timestamp
    end function
    function resolution() bind(c)
        import c_double
        real(c_double) :: resolution
    end function
end interface

end module

program root_benchmark
use roots, only: dp, pzeroin, proot, pzero
use timers, only: timestamp, resolution
use scipy, only: pbrentq
implicit none

integer, parameter :: n = 100000
real(dp), parameter :: tol = epsilon(1.0_dp)

real(dp), allocatable :: levels(:), out(:)
real(dp) :: s, runtime
integer :: i, k, niter, nseed
logical :: correct

call random_seed(size=nseed)
call random_seed(put=urandom_seed(nseed))

allocate(levels(n), out(n))

call random_number(levels)
levels = 1.5_dp * levels

niter = 1
do
    s = timestamp()
    do k = 1, niter
        do i = 1, n
            !out(i) = pzeroin(0.0_dp,2.0_dp,myfun,tol,levels(i))
            !out(i) = pbrentq(0.0_dp,2.0_dp,myfun,tol,levels(i)) ! Scipy Solver
            out(i) = pzero(0.0_dp,2.0_dp,myfun,tol,levels(i))
        end do
    end do
    runtime = timestamp() - s
    if (runtime > 0.2_dp) exit
    niter = niter * 2
end do

print *, runtime/niter

correct = all( [(isapprox( &
                    x=myfun(out(i),levels(i)), &
                    y=0.0_dp,&
                    atol=3*tol), i = 1, n) ] )

if (.not. correct) error stop "FAILED!"

contains

    pure function myfun(x,p)
        real(dp), intent(in) :: x, p(*)
        real(dp) :: myfun
        myfun = x * sin(x) - p(1)
    end function

    logical function isapprox(x,y,atol,rtol)
        real(dp), intent(in) :: x, y
        real(dp), intent(in), optional :: atol, rtol

        real(dp) :: atol_, rtol_

        atol_ = 0
        if (present(atol)) atol_ = atol

        rtol_ = sqrt(epsilon(1.0_dp))
        if (present(rtol)) rtol_ = rtol
        isapprox = abs(x - y) <= max(atol_,rtol_*max(abs(x),abs(y)))
    end function

    ! Seeding helper taken from
    ! https://cyber.dabamos.de/programming/modernfortran/random-numbers.html
    function urandom_seed(n, stat) result(seed)
        !! Returns a seed array filled with random values from `/dev/urandom`.
        integer, intent(in)            :: n
        integer, intent(out), optional :: stat
        integer                        :: seed(n)
        integer                        :: fu, rc

        open (access='stream', action='read', file='/dev/urandom', &
              form='unformatted', iostat=rc, newunit=fu)
        if (present(stat)) stat = rc
        if (rc == 0) read (fu) seed
        close (fu)
    end function urandom_seed

end program