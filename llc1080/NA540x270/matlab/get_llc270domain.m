clear all;close all
warning off
%dirRoot='/net/nares/raid8/ecco-shared/';
nx=4320;nxstr=num2str(nx);
ncut1=2160;ncut2=1080;
ixp=nx-ncut1+1:nx+ncut1;        %[ixp(1) ixp(end)]: 2161 6480
iyp=737:737+ncut2-1;            %[iyp(1) iyp(end)]:  737 1816
ix1=[nx+1:ixp(end)]-nx;         %[1 2160]
iy1=iyp+2*nx;                   %[9377 10456]
ix5=3*nx-[iy1(end):-1:iy1(1)]+1;%[2505 3584]
iy5=ixp(1):nx;                  %[2161 4320]

nx0=270;
fac=nx/nx0;
%now mapping into llc270:
ix1_0=ceil(ix1(1)/fac):ix1(end)/fac;
iy1_0=[floor(iy1(1)/fac):iy1(end)/fac]-(3*nx0-450);
[ix1_0(1) ix1_0(end) iy1_0(1) iy1_0(end)]       %[1 135 226 293]

ix5_0=ceil(ix5(1)/fac):ix5(end)/fac;
iy5_0=ceil(iy5(1)/fac):iy5(end)/fac;
[ix5_0(1) ix5_0(end) iy5_0(1) iy5_0(end)]       %[157 224 136 270]

