clear all;

nx=1080;nxstr=num2str(nx);
ncut1=540;ncut2=270;
%dirIn=['/nobackupp8/dmenemen/tarballs/llc_' nxstr '/run_template/'];
%dirGrid=[dirIn '../grid/'];
dirGrid=['/nobackupp2/atnguye4/llc' nxstr '/global/GRID/'];
dirOut=['/nobackupp2/atnguye4/llc' nxstr '/NA' num2str(ncut1) 'x' num2str(ncut2) '/run_template/input_obcs/'];

nx=1080;ny=nx*13;
ncut1=540;ncut2=270;

%actual indices on the faces:
%some calc from llc270: 586*fac+1 = 2345; 654*fac-fac/2 = 2614; where [586,654] are from llc270 global, or [226 294] for aste
ix1=1:ncut1;                    iy1=2345:2614;     Lx1=length(ix1);Ly1=length(iy1); %[1 540 2345 2614]; [540 270]
ix5=3*nx-[iy1(end):-1:iy1(1)]+1;iy5=sort(nx-ix1)+1;Lx5=length(ix5);Ly5=length(iy5);%[627 896 541 1080]; [270 540]

yg=readbin([dirGrid 'YG.data'],[nx ny]);%yg=reshape(yg,nx,ny);
yg1=yg(:,1:3*nx);
yg5=reshape(yg(:,10*nx+1:13*nx),3*nx,nx);

xc=readbin([dirGrid 'XC.data'],[nx ny]);%xc=reshape(xc,nx,ny);
xc1=xc(:,1:3*nx);
xc5=reshape(xc(:,10*nx+1:13*nx),3*nx,nx);

load([dirOut 'obcs_llc1080k106b_it0012_15Nov2016.mat']);	%Face1k106b, Face5k106b

%need at yg points
%Face1new.jVS = 9393;
jVS_1=Face1k106b.jVS(1);		%global
iCS_1=Face1k106b.iCS(1,:);

%Face1new.jCN_1st = 10433;
jVN_1=Face1k106b.jVN(1);		%global
iCN_1=Face1k106b.iCN(1,:);

%Face5new.iUE = 1065;
iUE_5=Face5k106b.iUE(1);		%global
jCE_5=Face5k106b.jCE(1,:);

%Face5new.iUW = 25;
iUW_5=Face5k106b.iUW(1);		%global
jCW_5=Face5k106b.jCW(1,:);

%Face1:
LatS_f1_NA = yg1(iCS_1,jVS_1);	%27.196542739868164
LonS_f1_NA = xc1(iCS_1,jVS_1);
LatN_f1_NA = yg1(iCN_1,jVN_1);	%43.414096832275391
LonN_f1_NA = xc1(iCN_1,jVN_1);

LatE_f5_NA = yg5(iUE_5,jCE_5); %27.196542739868164
LonE_f5_NA = xc5(iUE_5,jCE_5);
LatW_f5_NA = yg5(iUW_5,jCW_5); %43.414096832275391
LonW_f5_NA = xc5(iUW_5,jCW_5);

Face5.latE = LatE_f5_NA;
Face5.lonE = LonE_f5_NA;
Face5.latW = LatW_f5_NA;
Face5.lonW = LonW_f5_NA;
Face5.iE = iUE_5;	%<-- yg pts
Face5.jE = jCE_5;
Face5.iW = iUW_5;	%<-- yg pts
Face5.jW = jCW_5;

Face1.latS = LatS_f1_NA;
Face1.lonS = LonS_f1_NA;
Face1.latN = LatN_f1_NA;
Face1.lonN = LonN_f1_NA;
Face1.jN = jVN_1;	%<-- yg pts
Face1.iN = iCN_1;
Face1.jS = jVS_1;	%<-- yg pts
Face1.iS = iCS_1;

save([dirOut 'NA' num2str(ncut1) 'x' num2str(ncut2) '_latlon_fortides.mat'],'Face1','Face5');

figure(2);clf;
plot(Face1.lonS,Face1.latS,'b.-');hold on;
plot(Face5.lonE,Face5.latE,'r.-');
plot(Face1.lonN,Face1.latN,'b.-');hold on;
plot(Face5.lonW,Face5.latW,'r.-');
hold off;grid;
title(['Lat North: ' num2str(mean(Face1.latN)) '; ' ...
       'Lat South: ' num2str(mean(Face1.latS))]);
load coast;
hold on;plot(long,lat,'k-');hold off;
axis([-92.0382 23.8853 17.6829 52.6422]);
set(gcf,'paperunits','inches','paperposition',[0 0 8 6]);
print([dirOut 'NA' num2str(ncut1) 'x' num2str(ncut2) '_latlon_fortides.png'],'-dpng');

