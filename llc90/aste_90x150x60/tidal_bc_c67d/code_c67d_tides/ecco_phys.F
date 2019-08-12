#include "ECCO_OPTIONS.h"

      subroutine ecco_phys( mythid )

c     ==================================================================
c     SUBROUTINE ecco_phys
c     ==================================================================
c
c     ==================================================================
c     SUBROUTINE ecco_phys
c     ==================================================================

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#include "DYNVARS.h"
#include "FFIELDS.h"
#include "GRID.h"

#ifdef ALLOW_ECCO
# include "ecco.h"
#endif
#ifdef ALLOW_PTRACERS
# include "PTRACERS_SIZE.h"
# include "PTRACERS_FIELDS.h"
#endif

c     == routine arguments ==

      integer mythid

c     == local variables ==

      integer bi,bj
      integer i,j,k
      integer jmin,jmax
      integer imin,imax
#ifdef ALLOW_GENCOST_CONTRIBUTION
      integer kgen, kgen3d, itr
      _RL areavolTile(nSx,nSy), areavolGlob
      _RL tmpfld, tmpvol, tmpmsk, tmpmsk2, tmpmskW, tmpmskS
c      _RL tmpVol(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)

#ifdef ALLOW_GENCOST_DTHETADR
      integer k1,k2,i1(nr),j1(nr),bi1(nr),bj1(nr),kdthetadr
      integer icount,nstep
      _RL dthetadr, dthetaL, dthetaR, xC0, yC0, zC0, ss
      _RL Tcutoff,lonline,latlower,latupper
#endif
#ifdef ALLOW_GENCOST_SIGMAR
      _RL rhoKp1  (1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL rhoKm1  (1-OLx:sNx+OLx,1-OLy:sNy+OLy)
      _RL sigmaX  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL sigmaY  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL sigmaR  (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
c      INTEGER iMin, iMax
c      INTEGER jMin, jMax
#endif
#endif

c- note defined with overlap here, not needed, but more efficient
      _RL trVolW(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL trVolS(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL trHeatW(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL trHeatS(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL trSaltW(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL trSaltS(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      _RL T_ref,S_ref,temp

#ifdef ATMOSPHERIC_LOADING
      _RL sIceLoadFac
#endif
#ifdef ALLOW_PSBAR_STERIC
      _RL RHOInSituLoc(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RL VOLsumTile(nSx,nSy),RHOsumTile(nSx,nSy)
#endif

c      CHARACTER*(MAX_LEN_MBUF) msgBuf
c      _RL tmpfld(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

      T_ref = -1.9 _d 0
      S_ref = 34.8 _d 0

c need to include halos for find_rho_2d
      iMin = 1-OLx
      iMax = sNx+OLx
      jMin = 1-OLy
      jMax = sNy+OLy

#ifdef ALLOW_PSBAR_STERIC

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
          do k = 1,nr
            CALL FIND_RHO_2D(
     I                iMin, iMax, jMin, jMax, k,
     I                theta(1-OLx,1-OLy,k,bi,bj),
     I                salt (1-OLx,1-OLy,k,bi,bj),
     O                RHOInSituLoc(1-OLx,1-OLy,k,bi,bj),
     I                k, bi, bj, myThid )
          enddo
        enddo
      enddo

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
          RHOsumTile(bi,bj)=0. _d 0
          VOLsumTile(bi,bj)=0. _d 0
          VOLsumGlob=0. _d 0
          RHOsumGlob=0. _d 0
          do k = 1,nr
            do j = 1,sNy
              do i =  1,sNx
                RHOsumTile(bi,bj)=RHOsumTile(bi,bj)+
     &            (rhoConst+RHOInSituLoc(i,j,k,bi,bj))*
     &            hFacC(i,j,k,bi,bj)*drF(k)*rA(i,j,bi,bj)
                VOLsumTile(bi,bj)=VOLsumTile(bi,bj)+
     &            hFacC(i,j,k,bi,bj)*drF(k)*rA(i,j,bi,bj)
              enddo
            enddo
          enddo
        enddo
      enddo
      CALL GLOBAL_SUM_TILE_RL( VOLsumTile, VOLsumGlob, myThid )
      CALL GLOBAL_SUM_TILE_RL( RHOsumTile, RHOsumGlob, myThid )
      RHOsumGlob=RHOsumGlob/VOLsumGlob

      if (RHOsumGlob_0.GT.0. _d 0) then
        sterGloH=VOLsumGlob_0/globalArea
     &        *(1. _d 0 - RHOsumGlob/RHOsumGlob_0)
      else
        sterGloH=0. _d 0
      endif

c     WRITE(msgBuf,'(A,1PE21.14)') ' sterGloH= ', sterGloH
c        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
c    &                       SQUEEZE_RIGHT, myThid )

#endif

#ifdef ATMOSPHERIC_LOADING
      sIceLoadFac=zeroRL
      IF ( useRealFreshWaterFlux ) sIceLoadFac=recip_rhoConst
#endif

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
            do j = jmin,jmax
              do i =  imin,imax
                m_eta(i,j,bi,bj)=
     &                 etan(i,j,bi,bj)
#ifdef ATMOSPHERIC_LOADING
     &                +sIceLoad(i,j,bi,bj)*sIceLoadFac
#endif
#ifdef ALLOW_PSBAR_STERIC
     &                +sterGloH
#endif
              enddo
            enddo
        enddo
      enddo

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
          do k = 1,nr
            do j = 1,sNy
              do i =  1,sNx
                m_UE(i,j,k,bi,bj)=0. _d 0
                m_VN(i,j,k,bi,bj)=0. _d 0
              enddo
            enddo
          enddo
        enddo
      enddo

      CALL ROTATE_UV2EN_RL(
     U          uVel, vVel, m_UE, m_VN,
     I          .TRUE., .TRUE., .FALSE., Nr, mythid )


c--   trVol : volume flux    --- [m^3/sec] (order of 10^6 = 1 Sv)
c--   trHeat: heat transport --- [Watt] (order of 1.E15 = PW)
c--   trSalt: salt transport --- [kg/sec] (order 1.E9 equiv. 1 Sv in vol.)
c--       convert from [ppt*m^3/sec] via rhoConst/1000.
c--       ( 1ppt = 1000*[mass(salt)]/[mass(seawater)] )

c-- init
      call ecco_zero(trVol,Nr,zeroRL,myThid)
      call ecco_zero(trHeat,Nr,zeroRL,myThid)
      call ecco_zero(trSalt,Nr,zeroRL,myThid)

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
c-- init: if done with overlap, more efficient. But since overwritten
c immediately afterward, init is probably not needed.
          do k = 1,nr                  !/*{{{*/ [2]
            do j = 1,sNy
              do i =  1,sNx
                trVolW(i,j,k)=0. _d 0
                trVolS(i,j,k)=0. _d 0
                trHeatW(i,j,k)=0. _d 0
                trHeatS(i,j,k)=0. _d 0
                trSaltW(i,j,k)=0. _d 0
                trSaltS(i,j,k)=0. _d 0
              enddo
            enddo
          enddo                        !/*}}}*/ [2]
        enddo
      enddo

#ifdef ALLOW_GENCOST_SIGMAR
c copy from do_oceanc_phys.F                !/*{{{*/ [1]

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
        iMin = 1-OLx
        iMax = sNx+OLx
        jMin = 1-OLy
        jMax = sNy+OLy

        DO k=1,Nr                 !/*{{{*/ [2]
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
C This is currently used by GMRedi, IVDC, MXL-depth  and Diagnostics
           sigmaX(i,j,k) = 0. _d 0
           sigmaY(i,j,k) = 0. _d 0
           sigmaR(i,j,k) = 0. _d 0
          ENDDO
         ENDDO
        ENDDO

        DO j=1-OLy,sNy+OLy
         DO i=1-OLx,sNx+OLx
          rhoKm1 (i,j)   = 0. _d 0
          rhoKp1 (i,j)   = 0. _d 0
         ENDDO
        ENDDO                     !/*}}}*/ [2]

c------ k loop in reverse
        DO k=Nr,1,-1              !/*{{{*/ [2]
         IF (k.GT.1) THEN
                   CALL FIND_RHO_2D(
     I                 iMin, iMax, jMin, jMax, k,
     I                 theta(1-OLx,1-OLy,k-1,bi,bj),
     I                 salt (1-OLx,1-OLy,k-1,bi,bj),
     O                 rhoKm1,
     I                 k-1, bi, bj, myThid )
         ENDIF
         DO j=jMin,jMax
          DO i=iMin,iMax
           rhoKp1(i,j) = rhoInSitu(i,j,k,bi,bj)
          ENDDO !i
         ENDDO  !j
         CALL GRAD_SIGMA(
     I          bi, bj, iMin, iMax, jMin, jMax, k,
     I          rhoInSitu(1-OLx,1-OLy,k,bi,bj), rhoKm1, rhoKp1,
     O          sigmaX, sigmaY, sigmaR,
     I          myThid )

         DO j=jMin,jMax
          DO i=iMin,iMax
           sigmaRfield(i,j,k,bi,bj)=sigmaR(i,j,k)
          ENDDO  !i
         ENDDO   !j
        ENDDO    !k                !/*}}}*/ [2]
c--- done k loop
       ENDDO    !bi
      ENDDO     !bj

                                   !/*}}}*/ [1]
#endif /* ALLOW_GENCOST_SIGMAR */

#ifdef ALLOW_GENCOST_DTHETADR
      kdthetadr=0                                         !/*{{{*/ [1]
      do kgen=1,NGENCOST
        if (gencost_barfile(kgen)(1:10).EQ.'m_dthetadr') then
          Tcutoff  = gencost_preproc_r(1,kgen)
          lonline  = gencost_preproc_r(2,kgen)
          latlower = gencost_preproc_r(3,kgen)
          latupper = gencost_preproc_r(4,kgen)
          k1=gencost_preproc_i(1,kgen)
          k2=gencost_preproc_i(2,kgen)
          kdthetadr = kgen
        endif
      enddo

      if(kdthetadr .gt. 0) then
       do k=1,nr         !/*{{{*/ [2]
        bi1(k)=0
        bj1(k)=0
        i1(k)=0
        j1(k)=0
       enddo             !/*}}}*/ [2]
       dthetadr=0. _d 0
       do bj=myByLo(myThid),myByHi(myThid)         !/*{{{*/ [2]
        do bi=myBxLo(myThid),myBxHi(myThid)
         do j=2,sNy-1
          do i=2,sNx-1
c- cant tell at the moment if this is along i or j, assume i for now
           if((abs(xc(i,j,bi,bj)-(lonline)).lt. 0.001 _d 0) .and.
     &            (yc(i,j,bi,bj).gt. latlower  .and. 
     &             yc(i,j,bi,bj).lt. latupper)) then
            dthetaL = 0. _d 0
            dthetaR = 0. _d 0
            do k=k1,k2
 
             if((hFacC(i-1,j,k  ,bi,bj).gt.0.9 _d 0 .and.
     &           hFacC(i  ,j,k  ,bi,bj).gt.0.9 _d 0      ).and.
     &          (hFacC(i-1,j,k+1,bi,bj).gt.0.9 _d 0 .and.
     &           hFacC(i  ,j,k+1,bi,bj).gt.0.9 _d 0      )) then
 
              dthetaL=theta(i-1,j,k  ,bi,bj)-Tcutoff
              dthetaR=theta(i  ,j,k  ,bi,bj)-Tcutoff
 
              if (dthetaL.lt.0. _d 0 .and. dthetaR.ge.0. _d 0) then
                 bi1(k) = bi
                 bj1(k) = bj
                 i1(k)  = i
                 j1(k)  = j
              endif
             endif  !hFacC=1.0
            enddo !k=k1,k2
           endif
          enddo   !i
         enddo    !j
        enddo     !bi
       enddo      !bj                               !/*}}}*/ [2]
 
c-- now compute gradient d distance dz

c-- dthetadr: the slope in m_hor/m_ver of the isothermal line Tcutoff
       dthetadr = 0. _d 0
       icount   = 0
       do k=k1,k2                    !/*{{{*/ [2]
        if(   (bi1(k).gt.0.and.bi1(k+1).gt.0)
     &   .and.(bj1(k).gt.0.and.bj1(k+1).gt.0) ) then

         ss=1. _d 0
         nstep = 1
c         xC0 = 0. _d 0
c         yC0 = 0. _d 0
         zC0 = 0. _d 0
         i=i1(k)
         j=j1(k)
         bi=bi1(k)
         bj=bj1(k)

c- note overestimate the slope by 1 grid point
c- because vertical slope is infinite (dz/dx) or zero (dx/dz)
         if(i1(k).le.i1(k+1)) then
c          do i=i1(k),i1(k+1),nstep
c           xC0 = xC0 + dxC(i,j,bi,bj)*ss
c          enddo
          zC0 = zC0 + drC(k+1)
          icount = icount + 1
          dthetaR = theta(i,j,k+1,bi,bj)-theta(i,j,k,bi,bj)
c          dthetadr = dthetadr + ss*SQRT(xC0*xC0+yC0*yC0)/zC0
          dthetadr = dthetadr + dthetaR/zC0
         endif
        endif
       enddo                          !/*}}}*/ [2]
       if(icount .gt. 0) dthetadr = dthetadr / icount

      endif!kdthetadr
                                                   !/*}}}*/ [1]
#endif /* ALLOW_GENCOST_DTHETADR */

#ifdef ALLOW_GENCOST_CONTRIBUTION

c      DO bj=myByLo(myThid),myByHi(myThid)          !/*{{{*/
c       DO bi=myBxLo(myThid),myBxHi(myThid)
c          do k = 1,nr
c            do j = 1-OLy,sNy+Oly
c              do i = 1-OLx,sNx+OLx
c                tmpVol(i,j,k,bi,bj)=
c     &          hFacC(i,j,k,bi,bj)*drF(k)*rA(i,j,bi,bj)
c              enddo
c            enddo
c          enddo
c        enddo
c      enddo                                        !/*}}}*/

      do kgen=1,NGENCOST

      itr = gencost_itracer(kgen)

      call ecco_zero(gencost_storefld(1-OLx,1-OLy,1,1,kgen),
     &     1,zeroRL,myThid)

      do bj=myByLo(myThid),myByHi(myThid)
       do bi=myBxLo(myThid),myBxHi(myThid)
         areavolTile(bi,bj)=0. _d 0
       enddo
      enddo
      areavolGlob=0. _d 0

      do bj=myByLo(myThid),myByHi(myThid)
       do bi=myBxLo(myThid),myBxHi(myThid)
        do j = 1,sNy
         do i =  1,sNx

          do k = 1,nr
            tmpvol=hFacC(i,j,k,bi,bj)*drF(k)*rA(i,j,bi,bj)
c
            tmpmsk=0. _d 0
            if (.NOT.gencost_msk_is3d(kgen)) then
              tmpmsk=gencost_mskCsurf(i,j,bi,bj,kgen)*
     &               gencost_mskVertical(k,kgen)
#ifdef ALLOW_GENCOST3D
            else
              kgen3d=gencost_msk_pointer3d(kgen)
              tmpmsk=gencost_mskC(i,j,k,bi,bj,kgen3d)
#endif
            endif
c
            tmpfld=0. _d 0
            tmpmsk2=0. _d 0
            if (gencost_barfile(kgen)(1:15).EQ.'m_boxmean_theta') then !/*{{{*/ [1]
              tmpfld=theta(i,j,k,bi,bj)
              if (tmpmsk.NE.0. _d 0) tmpmsk2=1. _d 0
            elseif (gencost_barfile(kgen)(1:14).EQ.'m_boxmean_salt')
     &        then
              tmpfld=salt(i,j,k,bi,bj)
              if (tmpmsk.NE.0. _d 0) tmpmsk2=1. _d 0
catn: note the sigmar and dthetadr will need testing.  working ok
c on c65q but not yet tested on later checkpoints
#ifdef ALLOW_GENCOST_SIGMAR
            elseif (gencost_barfile(kgen)(1:16).EQ.'m_boxmean_sigmaR')
     &        then
              tmpfld=sigmaRfield(i,j,k,bi,bj)
              if (tmpmsk.NE.0. _d 0) tmpmsk2=1. _d 0
#endif /* ALLOW_GENCOST_SIGMAR */
#ifdef ALLOW_GENCOST_DTHETADR
         elseif (gencost_barfile(kgen)(1:18).EQ.'m_boxmean_dthetadr')
     &   then
          if(dthetadr.gt.0 _d 0 .and. i.eq.1.and.j.eq.1) then !/*{{{*/ [2]
           gencost_storefld(i,j,bi,bj,kgen) = 
     &     gencost_storefld(i,j,bi,bj,kgen) + dthetadr
          else
           gencost_storefld(i,j,bi,bj,kgen) = 0. _d 0
          endif
          if(dthetadr.gt.0 _d 0) then
            areavolTile(bi,bj)= 1. _d 0
          else
            areavolTile(bi,bj)= 0. _d 0
          endif                                               !/*}}}*/ [2]
#endif /* ALLOW_GENCOST_DTHETADR */
#ifdef ALLOW_PTRACERS
            elseif (gencost_barfile(kgen)(1:17).EQ.'m_boxmean_ptracer')
     &        then
              tmpfld=pTracer(i,j,k,bi,bj,itr)
              if (tmpmsk.NE.0. _d 0) tmpmsk2=1. _d 0
#endif
            endif                                               !/*}}}*/ [1]
c
            gencost_storefld(i,j,bi,bj,kgen) =
     &          gencost_storefld(i,j,bi,bj,kgen)
     &          +tmpmsk*tmpfld*tmpvol
            areavolTile(bi,bj)=areavolTile(bi,bj)
     &          +tmpmsk2*eccoVol_0(i,j,k,bi,bj)
c
          enddo !k=1,nr
c---------
          tmpmsk=maskC(i,j,1,bi,bj)*gencost_mskCsurf(i,j,bi,bj,kgen)
          tmpfld=0. _d 0
          tmpmsk2=0. _d 0
          if (gencost_barfile(kgen)(1:13).EQ.'m_boxmean_eta') then
            tmpfld=m_eta(i,j,bi,bj)
            if (tmpmsk.NE.0. _d 0) tmpmsk2=1. _d 0
          endif
c
          gencost_storefld(i,j,bi,bj,kgen) =
     &        gencost_storefld(i,j,bi,bj,kgen)
     &        +tmpmsk*tmpfld*rA(i,j,bi,bj)
          areavolTile(bi,bj)=areavolTile(bi,bj)
     &        +tmpmsk2*rA(i,j,bi,bj)
c---------
catn treat transport on separate nr block
          do k = 1,nr
c
            tmpmskW=0. _d 0
            tmpmskS=0. _d 0
            if (.NOT.gencost_msk_is3d(kgen)) then        !/*{{{*/
              tmpmskW=gencost_mskWsurf(i,j,bi,bj,kgen)
     &          *gencost_mskVertical(k,kgen)
              tmpmskS=gencost_mskSsurf(i,j,bi,bj,kgen)
     &          *gencost_mskVertical(k,kgen)
#ifdef ALLOW_GENCOST3D
            else
              kgen3d=gencost_msk_pointer3d(kgen)
              tmpmskW=gencost_mskW(i,j,k,bi,bj,kgen3d)
              tmpmskS=gencost_mskS(i,j,k,bi,bj,kgen3d)
#endif
            endif                                        !/*}}}*/
            tmpmskW=tmpmskW*hFacW(i,j,k,bi,bj)*dyG(i,j,bi,bj)*drF(k)
            tmpmskS=tmpmskS*hFacS(i,j,k,bi,bj)*dxG(i,j,bi,bj)*drF(k)
c
            if ((gencost_barfile(kgen)(1:13).EQ.'m_horflux_vol').OR.
     &          (gencost_barfile(kgen)(1:14).EQ.'m_horflux_heat').OR.
     &          (gencost_barfile(kgen)(1:14).EQ.'m_horflux_salt')) then 
                trVolW(i,j,k) =
     &                 uVel(i,j,k,bi,bj)*tmpmskW
     &                *maskInW(i,j,bi,bj)
                trVolS(i,j,k) =
     &                 vVel(i,j,k,bi,bj)*tmpmskS
     &                *maskInS(i,j,bi,bj)

                trVol(i,j,k,bi,bj)=trVolW(i,j,k)+trVolS(i,j,k)

             if (gencost_barfile(kgen)(1:13).EQ.'m_horflux_vol') then
              gencost_storefld(i,j,bi,bj,kgen) =        !/*{{{*/ [2]
     &          gencost_storefld(i,j,bi,bj,kgen)
     &           +trVolW(i,j,k)+trVolS(i,j,k)           !/*}}}*/ [2]

             elseif (gencost_barfile(kgen)(1:14).EQ.'m_horflux_heat') 
     &         then
                                                        !/*{{{*/ [2]
                temp=((theta(i,j,k,bi,bj)+theta(i-1,j,k,bi,bj))*halfRL
     &                 - T_ref)
                if (temp.ge. 0. _d 0) then
                  trHeatW(i,j,k) = trVolW(i,j,k)
     &                  *temp*HeatCapacity_Cp*rhoConst
                endif

                temp=((theta(i,j,k,bi,bj)+theta(i,j-1,k,bi,bj))*halfRL
     &                 - T_ref)
                if (temp.ge. 0. _d 0) then
                  trHeatS(i,j,k) = trVolS(i,j,k)
     &                  *temp*HeatCapacity_Cp*rhoConst
                endif

              gencost_storefld(i,j,bi,bj,kgen) =
     &          gencost_storefld(i,j,bi,bj,kgen)
     &           +trHeatW(i,j,k)+trHeatS(i,j,k)         !/*}}}*/ [2]
                trHeat(i,j,k,bi,bj)=trHeatW(i,j,k)+trHeatS(i,j,k)

             elseif (gencost_barfile(kgen)(1:14).EQ.'m_horflux_salt') 
     &         then 
                                                       !/*{{{*/ [2]
                temp=1. _d 0 - ((salt(i,j,k,bi,bj)+salt(i-1,j,k,bi,bj))
     &                 *halfRL)/S_ref
                if (temp.ge. 0. _d 0) then
                  trSaltW(i,j,k) = trVolW(i,j,k)
     &                  *temp*rhoConst/1000.
                endif

                temp=1. _d 0 - ((salt(i,j,k,bi,bj)+salt(i,j-1,k,bi,bj))
     &                 *halfRL)/S_ref
                if (temp.ge. 0. _d 0) then
                  trSaltS(i,j,k) = trVolS(i,j,k)
     &                  *temp*rhoConst/1000.
                endif

              gencost_storefld(i,j,bi,bj,kgen) =
     &          gencost_storefld(i,j,bi,bj,kgen)
     &           +trSaltW(i,j,k)+trSaltS(i,j,k)       
                                                      !/*}}}*/ [2]
                trSalt(i,j,k,bi,bj)=trSaltW(i,j,k)+trSaltS(i,j,k)

             endif

            endif !gencost_barfile

          enddo !k=1,nr
c---------
         enddo
        enddo
       enddo
      enddo

catn: why are we not summning up m_hor ?
      if (gencost_barfile(kgen)(1:9).EQ.'m_boxmean') then
        CALL GLOBAL_SUM_TILE_RL( areavolTile, areavolGlob, myThid )
        CALL ecco_div( gencost_storefld(1-OLx,1-OLy,1,1,kgen),
     &                 1, areavolGlob, myThid )
      endif

      enddo !kgen

#endif /* ALLOW_GENCOST_CONTRIBUTION */


      return
      end
