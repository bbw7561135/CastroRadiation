
subroutine ca_er_com2lab(lo, hi, &
     Snew,  S_l1,  S_l2,  S_l3,  S_h1,  S_h2,  S_h3, &
     Ecom, Ec_l1, Ec_l2, Ec_l3, Ec_h1, Ec_h2, Ec_h3, &
     F,     F_l1,  F_l2,  F_l3,  F_h1,  F_h2,  F_h3, iflx, nflx, & 
     Elab, El_l1, El_l2, El_l3, El_h1, El_h2, El_h3, ier, npv)
  use meth_params_module, only : NVAR, URHO, UMX, UMY, UMZ
  use rad_params_module, only : ngroups, clight, nnuspec, ng0, ng1, dlognu
  implicit none

  integer, intent(in) :: lo(3), hi(3)
  integer, intent(in) ::  S_l1,  S_l2,  S_l3,  S_h1,  S_h2,  S_h3
  integer, intent(in) :: Ec_l1, Ec_l2, Ec_l3, Ec_h1, Ec_h2, Ec_h3
  integer, intent(in) ::  F_l1,  F_l2,  F_l3,  F_h1,  F_h2,  F_h3, iflx, nflx
  integer, intent(in) :: El_l1, El_l2, El_l3, El_h1, El_h2, El_h3, ier, npv
  double precision,intent(in)   ::Snew( S_l1: S_h1, S_l2: S_h2, S_l3: S_h3,NVAR)
  double precision,intent(in)   ::Ecom(Ec_l1:Ec_h1,Ec_l2:Ec_h2,Ec_l3:Ec_h3,0:ngroups-1)
  double precision,intent(in)   ::F   ( F_l1: F_h1, F_l2: F_h2, F_l3: F_h3,0:nflx-1)
  double precision,intent(inout)::Elab(El_l1:El_h1,El_l2:El_h2,El_l3:El_h3,0:npv-1)

  integer :: i, j, k, g, ifx, ify, ifz
  double precision :: rhoInv, c2, vxc2, vyc2, vzc2
  double precision :: nufnux(-1:ngroups), nufnuy(-1:ngroups), nufnuz(-1:ngroups)
  double precision :: dlognuInv(0:ngroups-1)

  ifx = iflx
  ify = iflx + ngroups
  ifz = iflx + ngroups*2

  c2 = 1.d0/clight**2

  if (ngroups > 1) dlognuInv = 1.d0/dlognu

  do k = lo(3), hi(3)
  do j = lo(2), hi(2)
  do i = lo(1), hi(1)
     rhoInv = 1.d0/Snew(i,j,k,URHO)
     vxc2 = Snew(i,j,k,UMX)*rhoInv*c2
     vyc2 = Snew(i,j,k,UMY)*rhoInv*c2
     vzc2 = Snew(i,j,k,UMZ)*rhoInv*c2
     
     do g = 0, ngroups-1
        Elab(i,j,k,g+ier) = Ecom(i,j,k,g) + 2.d0*(vxc2*F(i,j,k,ifx+g) &
             &                                  + vyc2*F(i,j,k,ify+g) &
             &                                  + vzc2*F(i,j,k,ifz+g))
     end do
     
     if (ngroups > 1) then
        if (nnuspec .eq. 0) then
           
           do g=0,ngroups-1
              nufnux(g) = F(i,j,k,ifx+g)*dlognuInv(g)
              nufnuy(g) = F(i,j,k,ify+g)*dlognuInv(g)
              nufnuz(g) = F(i,j,k,ifz+g)*dlognuInv(g)
           end do
           nufnux(-1) = -nufnux(0)
           nufnuy(-1) = -nufnuy(0)
           nufnuz(-1) = -nufnuz(0)
           nufnux(ngroups) = -nufnux(ngroups-1)
           nufnuy(ngroups) = -nufnuy(ngroups-1)              
           nufnuz(ngroups) = -nufnuz(ngroups-1)              
           do g=0,ngroups-1
              Elab(i,j,k,g+ier) = Elab(i,j,k,g+ier) &
                   - vxc2*0.5d0*(nufnux(g+1)-nufnux(g-1)) &
                   - vyc2*0.5d0*(nufnuy(g+1)-nufnuy(g-1)) &
                   - vzc2*0.5d0*(nufnuz(g+1)-nufnuz(g-1))
           end do
           
        else
           
           do g=0,ng0-1
              nufnux(g) = F(i,j,k,ifx+g)*dlognuInv(g)
              nufnuy(g) = F(i,j,k,ify+g)*dlognuInv(g)
              nufnuz(g) = F(i,j,k,ifz+g)*dlognuInv(g)
           end do
           nufnux(-1) = -nufnux(0)
           nufnuy(-1) = -nufnuy(0)
           nufnuz(-1) = -nufnuz(0)
           nufnux(ng0) = -nufnux(ng0-1)
           nufnuy(ng0) = -nufnuy(ng0-1)              
           nufnuz(ng0) = -nufnuz(ng0-1)              
           do g=0,ng0-1
              Elab(i,j,k,g+ier) = Elab(i,j,k,g+ier) &
                   - vxc2*0.5d0*(nufnux(g+1)-nufnux(g-1)) &
                   - vyc2*0.5d0*(nufnuy(g+1)-nufnuy(g-1)) &
                   - vzc2*0.5d0*(nufnuz(g+1)-nufnuz(g-1))
           end do
           
           if (nnuspec >= 2) then
              
              do g=ng0,ng0+ng1-1
                 nufnux(g) = F(i,j,k,ifx+g)*dlognuInv(g)
                 nufnuy(g) = F(i,j,k,ify+g)*dlognuInv(g)
                 nufnuz(g) = F(i,j,k,ifz+g)*dlognuInv(g)
              end do
              nufnux(ng0-1) = -nufnux(ng0)
              nufnuy(ng0-1) = -nufnuy(ng0)
              nufnuz(ng0-1) = -nufnuz(ng0)
              nufnux(ng0+ng1) = -nufnux(ng0+ng1-1)
              nufnuy(ng0+ng1) = -nufnuy(ng0+ng1-1)              
              nufnuz(ng0+ng1) = -nufnuz(ng0+ng1-1)              
              do g=ng0,ng0+ng1-1
                 Elab(i,j,k,g+ier) = Elab(i,j,k,g+ier) &
                      - vxc2*0.5d0*(nufnux(g+1)-nufnux(g-1)) &
                      - vyc2*0.5d0*(nufnuy(g+1)-nufnuy(g-1)) &
                      - vzc2*0.5d0*(nufnuz(g+1)-nufnuz(g-1))
              end do
              
           end if
           
           if (nnuspec == 3) then
              
              do g=ng0+ng1,ngroups-1
                 nufnux(g) = F(i,j,k,ifx+g)*dlognuInv(g)
                 nufnuy(g) = F(i,j,k,ify+g)*dlognuInv(g)
                 nufnuz(g) = F(i,j,k,ifz+g)*dlognuInv(g)
              end do
              nufnux(ng0+ng1-1) = -nufnux(ng0+ng1)
              nufnuy(ng0+ng1-1) = -nufnuy(ng0+ng1)
              nufnuz(ng0+ng1-1) = -nufnuz(ng0+ng1)
              nufnux(ngroups) = -nufnux(ngroups-1)
              nufnuy(ngroups) = -nufnuy(ngroups-1)              
              nufnuz(ngroups) = -nufnuz(ngroups-1)              
              do g=ng0+ng1,ngroups-1
                 Elab(i,j,k,g+ier) = Elab(i,j,k,g+ier) &
                      - vxc2*0.5d0*(nufnux(g+1)-nufnux(g-1)) &
                      - vyc2*0.5d0*(nufnuy(g+1)-nufnuy(g-1)) &
                      - vzc2*0.5d0*(nufnuz(g+1)-nufnuz(g-1))
              end do
              
           end if

        end if
     end if
  end do
  end do
  end do

end subroutine ca_er_com2lab


subroutine ca_compute_fcc(lo, hi, &
     lamx, lamx_l1, lamx_l2, lamx_l3, lamx_h1, lamx_h2, lamx_h3, &
     lamy, lamy_l1, lamy_l2, lamy_l3, lamy_h1, lamy_h2, lamy_h3, &
     lamz, lamz_l1, lamz_l2, lamz_l3, lamz_h1, lamz_h2, lamz_h3, nlam, &
     Eddf, Eddf_l1, Eddf_l2, Eddf_l3, Eddf_h1, Eddf_h2, Eddf_h3)
  use rad_params_module, only : ngroups
  use fluxlimiter_module, only : Edd_factor
  implicit none
  integer, intent(in) :: lo(3), hi(3)
  integer, intent(in) :: lamx_l1, lamx_l2, lamx_l3, lamx_h1, lamx_h2, lamx_h3
  integer, intent(in) :: lamy_l1, lamy_l2, lamy_l3, lamy_h1, lamy_h2, lamy_h3
  integer, intent(in) :: lamz_l1, lamz_l2, lamz_l3, lamz_h1, lamz_h2, lamz_h3, nlam
  integer, intent(in) :: Eddf_l1, Eddf_l2, Eddf_l3, Eddf_h1, Eddf_h2, Eddf_h3
  double precision,intent(in   )::lamx(lamx_l1:lamx_h1,lamx_l2:lamx_h2,lamx_l3:lamx_h3,0:nlam-1)
  double precision,intent(in   )::lamy(lamy_l1:lamy_h1,lamy_l2:lamy_h2,lamy_l3:lamy_h3,0:nlam-1)
  double precision,intent(in   )::lamz(lamz_l1:lamz_h1,lamz_l2:lamz_h2,lamz_l3:lamz_h3,0:nlam-1)
  double precision,intent(inout)::Eddf(Eddf_l1:Eddf_h1,Eddf_l2:Eddf_h2,Eddf_l3:Eddf_h3,0:ngroups-1)

  integer :: i, j, k, g, ilam
  double precision :: lamcc

  do g=0,ngroups-1
     ilam = min(g,nlam-1)
     do k = lo(3), hi(3)
        do j = lo(2), hi(2)
           do i = lo(1), hi(1)
              lamcc = (1.d0/6.d0)*(lamx(i,j,k,ilam)+lamx(i+1,j,k,ilam) &
                   +               lamy(i,j,k,ilam)+lamy(i,j+1,k,ilam) &
                   +               lamz(i,j,k,ilam)+lamz(i,j,k+1,ilam))
              Eddf(i,j,k,g) = Edd_factor(lamcc)
           end do
        end do
     end do
  end do
end subroutine ca_compute_fcc


subroutine ca_transform_flux (lo, hi, flag, &
     Snew,  S_l1,  S_l2,  S_l3,  S_h1,  S_h2,  S_h3, &
     f,     f_l1,  f_l2,  f_l3,  f_h1,  f_h2,  f_h3, &
     Er,   Er_l1, Er_l2, Er_l3, Er_h1, Er_h2, Er_h3, &
     Fi,   Fi_l1, Fi_l2, Fi_l3, Fi_h1, Fi_h2, Fi_h3, ifi, nfi, & 
     Fo,   Fo_l1, Fo_l2, Fo_l3, Fo_h1, Fo_h2, Fo_h3, ifo, nfo)
  use meth_params_module, only : NVAR, URHO, UMX, UMY, UMZ
  use rad_params_module, only : ngroups, nnuspec, ng0, ng1, dlognu
  implicit none

  integer, intent(in) :: lo(3), hi(3)
  double precision, intent(in) :: flag
  integer, intent(in) ::  S_l1,  S_l2,  S_l3,  S_h1,  S_h2,  S_h3
  integer, intent(in) ::  f_l1,  f_l2,  f_l3,  f_h1,  f_h2,  f_h3
  integer, intent(in) :: Er_l1, Er_l2, Er_l3, Er_h1, Er_h2, Er_h3
  integer, intent(in) :: Fi_l1, Fi_l2, Fi_l3, Fi_h1, Fi_h2, Fi_h3, ifi, nfi
  integer, intent(in) :: Fo_l1, Fo_l2, Fo_l3, Fo_h1, Fo_h2, Fo_h3, ifo, nfo
  double precision,intent(in   )::Snew( S_l1: S_h1, S_l2: S_h2, S_l3: S_h3,NVAR)
  double precision,intent(in   )::   f( f_l1: f_h1, f_l2: f_h2, f_l3: f_h3,0:ngroups-1)
  double precision,intent(in   )::  Er(Er_l1:Er_h1,Er_l2:Er_h2,Er_l3:Er_h3,0:ngroups-1)
  double precision,intent(in   )::  Fi(Fi_l1:Fi_h1,Fi_l2:Fi_h2,Fi_l3:Fi_h3,0:nfi-1)
  double precision,intent(inout)::  Fo(Fo_l1:Fo_h1,Fo_l2:Fo_h2,Fo_l3:Fo_h3,0:nfo-1)

  integer :: i, j, k, g, ifix, ifiy, ifiz, ifox, ifoy, ifoz
  double precision :: rhoInv,  vx, vy, vz, f1, f2, nx, ny, nz, foo, vdotn
  double precision :: nuvpnux(-1:ngroups), nuvpnuy(-1:ngroups), nuvpnuz(-1:ngroups)
  double precision :: dlognuInv(0:ngroups-1)
  double precision :: vdotpx(0:ngroups-1), vdotpy(0:ngroups-1), vdotpz(0:ngroups-1)

  ifix = ifi
  ifiy = ifi + ngroups
  ifiz = ifi + ngroups*2

  ifox = ifo
  ifoy = ifo + ngroups
  ifoz = ifo + ngroups*2

  if (ngroups > 1) dlognuInv = 1.d0/dlognu

  do k = lo(3), hi(3)
  do j = lo(2), hi(2)
  do i = lo(1), hi(1)
     rhoInv = 1.d0/Snew(i,j,k,URHO)
     vx = Snew(i,j,k,UMX)*rhoInv*flag
     vy = Snew(i,j,k,UMY)*rhoInv*flag
     vz = Snew(i,j,k,UMZ)*rhoInv*flag

     do g = 0, ngroups-1
        f1 = (1.d0-f(i,j,k,g))
        f2 = (3.d0*f(i,j,k,g)-1.d0)
        foo = 1.d0/sqrt(Fi(i,j,k,ifix+g)**2+Fi(i,j,k,ifiy+g)**2+Fi(i,j,k,ifiz+g)**2)
        nx = Fi(i,j,k,ifix+g)*foo
        ny = Fi(i,j,k,ifiy+g)*foo
        nz = Fi(i,j,k,ifiz+g)*foo
        vdotn = vx*nx+vy*ny+vz*vz
        vdotpx(g) = 0.5d0*Er(i,j,k,g)*(f1*vx + f2*vdotn*nx)
        vdotpy(g) = 0.5d0*Er(i,j,k,g)*(f1*vy + f2*vdotn*ny)
        vdotpz(g) = 0.5d0*Er(i,j,k,g)*(f1*vz + f2*vdotn*nz)
        Fo(i,j,k,ifix+g) = Fi(i,j,k,ifix+g) + vx*Er(i,j,k,g) + vdotpx(g)
        Fo(i,j,k,ifiy+g) = Fi(i,j,k,ifiy+g) + vy*Er(i,j,k,g) + vdotpy(g)
        Fo(i,j,k,ifiz+g) = Fi(i,j,k,ifiz+g) + vz*Er(i,j,k,g) + vdotpz(g)
     end do

     if (ngroups > 1) then
        if (nnuspec .eq. 0) then
           
           do g=0,ngroups-1
              nuvpnux(g) = vdotpx(g)*dlognuInv(g)
              nuvpnuy(g) = vdotpy(g)*dlognuInv(g)
              nuvpnuz(g) = vdotpz(g)*dlognuInv(g)
           end do
           nuvpnux(-1) = -nuvpnux(0)
           nuvpnuy(-1) = -nuvpnuy(0)
           nuvpnuz(-1) = -nuvpnuz(0)
           nuvpnux(ngroups) = -nuvpnux(ngroups-1)
           nuvpnuy(ngroups) = -nuvpnuy(ngroups-1)              
           nuvpnuz(ngroups) = -nuvpnuz(ngroups-1)              
           do g=0,ngroups-1
              Fo(i,j,k,ifox+g) = Fo(i,j,k,ifox+g) - 0.5d0*(nuvpnux(g+1)-nuvpnux(g-1))
              Fo(i,j,k,ifoy+g) = Fo(i,j,k,ifoy+g) - 0.5d0*(nuvpnuy(g+1)-nuvpnuy(g-1))
              Fo(i,j,k,ifoz+g) = Fo(i,j,k,ifoz+g) - 0.5d0*(nuvpnuz(g+1)-nuvpnuz(g-1))
           end do

        else
           
           do g=0,ng0-1
              nuvpnux(g) = vdotpx(g)*dlognuInv(g)
              nuvpnuy(g) = vdotpy(g)*dlognuInv(g)
              nuvpnuz(g) = vdotpz(g)*dlognuInv(g)
           end do
           nuvpnux(-1) = -nuvpnux(0)
           nuvpnuy(-1) = -nuvpnuy(0)
           nuvpnuz(-1) = -nuvpnuz(0)
           nuvpnux(ng0) = -nuvpnux(ng0-1)
           nuvpnuy(ng0) = -nuvpnuy(ng0-1)              
           nuvpnuz(ng0) = -nuvpnuz(ng0-1)              
           do g=0,ng0-1
              Fo(i,j,k,ifox+g) = Fo(i,j,k,ifox+g) - 0.5d0*(nuvpnux(g+1)-nuvpnux(g-1))
              Fo(i,j,k,ifoy+g) = Fo(i,j,k,ifoy+g) - 0.5d0*(nuvpnuy(g+1)-nuvpnuy(g-1))
              Fo(i,j,k,ifoz+g) = Fo(i,j,k,ifoz+g) - 0.5d0*(nuvpnuz(g+1)-nuvpnuz(g-1))
           end do

           if (nnuspec >= 2) then

              do g=ng0,ng0+ng1-1
                 nuvpnux(g) = vdotpx(g)*dlognuInv(g)
                 nuvpnuy(g) = vdotpy(g)*dlognuInv(g)
                 nuvpnuz(g) = vdotpz(g)*dlognuInv(g)
              end do
              nuvpnux(ng0-1) = -nuvpnux(ng0)
              nuvpnuy(ng0-1) = -nuvpnuy(ng0)
              nuvpnuz(ng0-1) = -nuvpnuz(ng0)
              nuvpnux(ng0+ng1) = -nuvpnux(ng0+ng1-1)
              nuvpnuy(ng0+ng1) = -nuvpnuy(ng0+ng1-1)              
              nuvpnuz(ng0+ng1) = -nuvpnuz(ng0+ng1-1)              
              do g=ng0,ng0+ng1-1
                 Fo(i,j,k,ifox+g) = Fo(i,j,k,ifox+g) - 0.5d0*(nuvpnux(g+1)-nuvpnux(g-1))
                 Fo(i,j,k,ifoy+g) = Fo(i,j,k,ifoy+g) - 0.5d0*(nuvpnuy(g+1)-nuvpnuy(g-1))
                 Fo(i,j,k,ifoz+g) = Fo(i,j,k,ifoz+g) - 0.5d0*(nuvpnuz(g+1)-nuvpnuz(g-1))
              end do

           end if

           if (nnuspec == 3) then

              do g=ng0+ng1,ngroups-1
                 nuvpnux(g) = vdotpx(g)*dlognuInv(g)
                 nuvpnuy(g) = vdotpy(g)*dlognuInv(g)
                 nuvpnuz(g) = vdotpz(g)*dlognuInv(g)
              end do
              nuvpnux(ng0+ng1-1) = -nuvpnux(ng0+ng1)
              nuvpnuy(ng0+ng1-1) = -nuvpnuy(ng0+ng1)
              nuvpnuz(ng0+ng1-1) = -nuvpnuz(ng0+ng1)
              nuvpnux(ngroups) = -nuvpnux(ngroups-1)
              nuvpnuy(ngroups) = -nuvpnuy(ngroups-1)              
              nuvpnuz(ngroups) = -nuvpnuz(ngroups-1)              
              do g=ng0+ng1,ngroups-1
                 Fo(i,j,k,ifox+g) = Fo(i,j,k,ifox+g) - 0.5d0*(nuvpnux(g+1)-nuvpnux(g-1))
                 Fo(i,j,k,ifoy+g) = Fo(i,j,k,ifoy+g) - 0.5d0*(nuvpnuy(g+1)-nuvpnuy(g-1))
                 Fo(i,j,k,ifoz+g) = Fo(i,j,k,ifoz+g) - 0.5d0*(nuvpnuz(g+1)-nuvpnuz(g-1))
              end do

           end if

        end if
     end if
  end do
  end do
  end do

end subroutine ca_transform_flux
