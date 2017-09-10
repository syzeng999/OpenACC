
module kern
  
  use vars

  implicit none

  contains

  subroutine set_xy(xlo, xhi, ylo, yhi)
    real, intent(in) :: xlo, xhi, ylo, yhi

    integer :: k
    real :: wx, wy, dx, dy

    if (.not. allocated(x) .or. .not. allocated(y)) then
       stop 'Error: kern: set_xy: x and/or y is not allocated'
    endif

    ! let x and y arrays vary uniformly between lo and hi 
    wx = xhi - xlo
    wy = yhi - ylo
    dx = wx / (nx - 1)
    dy = wy / (ny - 1)

    !$acc data copy(nx, ny, xlo, ylo, dx, dy) copyout(x, y)
    !$acc kernels 
    do k = 1, nx
       x(k) = xlo + (k-1) * dx
    enddo

    do k = 1, ny
       y(k) = ylo + (k-1) * dy
    enddo
    !$acc end kernels
    !$acc end data

  end subroutine set_xy

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  subroutine gen_gauss2d()
    integer :: i, j
    real :: norm, expx, expy, argx, argy, argxy, arg
    real, parameter :: pi = 4.0 * atan(1.0)

    norm = 2.0 * pi * sx * sy * sqrt(1.0 - rho**2)
    
    ! $ acc data pcopy(nx, ny, sx, sy, rho, x0, y0, x, y, curve) pcreate(norm, argx, argy, argxy, arg)
    !$acc data
    !$acc parallel loop collapse(2) 
!private(argx, argy, argxy, arg) 
    do i = 1, nx
       do j = 1, ny
          argx  = (x(i) - x0)**2 / sx**2
          argy  = (y(j) - y0)**2 / sy**2
          argxy = 2 * rho * (x(i) - x0) * (y(j) - y0) / (sx * sy)
          arg   = (argx + argy - argxy) / (-2 * (1.0 - rho**2))
          curve(i,j) = exp(arg) / norm
       enddo
    enddo
    !$acc end parallel loop
    !$acc end data

  end subroutine gen_gauss2d

  !+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

end module kern
