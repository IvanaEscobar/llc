clear all;
dirIn1='/nobackupp2/atnguye4/llc4320/global/run_template/';
dirIn='/nobackupp8/dmenemen/tarballs/llc_4320/run_template/';
dirGrid=[dirIn '../grid/'];
nx=4320;nxstr=num2str(nx);
ny=nx*13;

%read in bathy
a=abs(read_llc_fkij([dirIn 'bathy4320_g5_r4'],nx,1,1,1:nx,2*nx+1:3*nx,'real*4'));
b=abs(read_llc_fkij([dirIn 'bathy4320_g5_r4'],nx,5,1,1:nx,2*nx+1:3*nx,'real*4'));
tmp_old=[b;a];

%read in Victor's new SandSv18p1 bathy
a=abs(read_llc_fkij([dirIn1 'SandSv18p1_compact.bin'],nx,1,1,1:nx,2*nx+1:3*nx,'real*4'));
b=abs(read_llc_fkij([dirIn1 'SandSv18p1_compact.bin'],nx,5,1,1:nx,2*nx+1:3*nx,'real*4'));
tmp=[b;a];
msk=ones(size(tmp));msk(find(tmp~=0))=0;

a=abs(read_llc_fkij([dirGrid 'YC.data'],nx,1,1,1:nx,2*nx+1:3*nx,'real*4'));
b=abs(read_llc_fkij([dirGrid 'YC.data'],nx,5,1,1:nx,2*nx+1:3*nx,'real*4'));
yc=[b;a];

ix=2137:4320+2170;iy=440:2013;
ncut1=2160;ncut2=1080;

ixp=nx-ncut1+1:nx+ncut1;
iyp=737:737+ncut2-1;

%actual indices on the faces:
ix1=[nx+1:ixp(end)]-nx;
iy1=iyp+2*nx;		%face1
ix5=3*nx-[iy1(end):-1:iy1(1)]+1;iy5=ixp(1):nx;	%face5

%[length(ix1) length(iy1) length(ix5) length(iy5)]
%     1680        1080        1080        2400
%     2400        1200        1200        2400

clf;mypcolor(ix,iy,tmp(ix,iy)');caxis([0 5e3]);colorbar;grid;
shadeland(ix,iy,msk(ix,iy)',[.7 .7 .7]);
hold on;plot([ixp(1) ixp(1) ixp(end) ixp(end) ixp(1)],[iyp(1) iyp(end) iyp(end) iyp(1) iyp(1)],'m-','linewidth',2);hold off;
hold on;[aa,bb]=contour(ix,iy,yc(ix,iy)',[5:5:65]);hold off;set(bb,'color','k');clabel(aa,'manual');

c=readbin([dirIn 'bathy4320_g5_r4'],[nx nx*13]);
c1=abs(c(1:nx,1:3*nx));
c5=abs(reshape(c(1:nx,10*nx+1:13*nx),3*nx,nx));
clear c

c1p=c1(ix1,iy1);
c5p=c5(ix5,iy5);

tmp1=tmp(ixp,iyp);
tmpp=[sym_g_mod(c5p,7,0);c1p];
sum(tmpp(:)-tmp1(:))		%0

%factor(1080)	  2     2     2           3     3     3     5
%factor(2160)	  2     2     2     2     3     3     3     5

%possible tile size:
% 24 30 40 45 54 60 72 90 108 120 

%write out first take of old bathy:
dirOut=['/nobackupp2/atnguye4/llc' nxstr '/NA' num2str(ncut1) 'x' num2str(ncut2) '/run_template/'];
%fOut=[dirOut 'bathy4320_g5_r4_NA' num2str(ncut1) 'x' num2str(ncut2) '.bin']
fOut=[dirOut 'SandSv18p1_NA' num2str(ncut1) 'x' num2str(ncut2) '.bin']

cout=cat(2,c1p,reshape(c5p,ncut1,ncut2));
writebin(fOut,cout,1,'real*4');

figure(1);set(gcf,'paperunits','inches','paperposition',[0 0 14 6]);
%print([dirOut 'bathy4320_g5_r4_NA' num2str(ncut1) 'x' num2str(ncut2) '.png'],'-dpng');
print([dirOut 'SandSv18p1_NA' num2str(ncut1) 'x' num2str(ncut2) '.png'],'-dpng');
