
module vars

  implicit none

  public

  type gaussian2d
    integer :: ratio   ! sy / sx
    real :: sx, sy     ! dispersions
    integer :: nx, ny  ! number of points along each direction
    real, dimension(:), allocatable :: x, y ! coordinates
    real, dimension(:,:), allocatable :: curve ! the 2D gaussian curve
  end type

  type(gaussian2d) :: g2d 
 
  contains 

  subroutine h2d(a)
    type(gaussian2d) :: a
    !$acc enter data copyin(a)
    !$acc enter data create(a%ratio, a%sx, a%sy, a%nx, a%ny, a%x, a%y, a%curve)
  end subroutine h2d

  subroutine d2h(b)
    type(gaussian2d) :: b
    !$acc exit data copyout(b%x, b%y, b%curve)
    !$acc exit data delete(b)
  end subroutine d2h
 
end module vars
