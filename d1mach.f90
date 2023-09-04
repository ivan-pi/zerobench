  pure function d1mach(i)

    integer, parameter :: dp = kind(1.0d0)

    integer, intent(in) :: i
    real(dp) :: d1mach

    real(dp), parameter :: x = 1.0_dp
    real(dp), parameter :: b = real(radix(x), dp)

    select case (i)
    case (1); d1mach = b**(minexponent(x) - 1) ! the smallest positive magnitude.
    case (2); d1mach = huge(x)                 ! the largest magnitude.
    case (3); d1mach = b**(-digits(x))         ! the smallest relative spacing.
    case (4); d1mach = b**(1 - digits(x))      ! the largest relative spacing.
    case (5); d1mach = log10(b)
    case default
        error stop 'Error in d1mach - i out of bounds'
    end select

  end function d1mach