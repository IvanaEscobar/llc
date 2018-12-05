clear all;

dirIn='/nobackupp8/dmenemen/tarballs/llc_4320/run_template/';
dirGrid=[dirIn '../grid/'];
dirOut=['/nobackupp2/atnguye4/llc4320/NA2160x1080/run_template/input_obcs/'];

nx=4320;ny=nx*13;
ncut1=2160;ncut2=1080;
ixp=nx-ncut1+1:nx+ncut1;        %[ixp(1) ixp(end)]: 2161 6480
iyp=737:737+ncut2-1;            %[iyp(1) iyp(end)]:  737 1816
ix1=[nx+1:ixp(end)]-nx;         %[1 2160]
iy1=iyp+2*nx;                   %[9377 10456]
ix5=3*nx-[iy1(end):-1:iy1(1)]+1;%[2505 3584]
iy5=ixp(1):nx;                  %[2161 4320]

yg=readbin([dirGrid 'YG.data'],[nx ny]);%yg=reshape(yg,nx,ny);
yg1=yg(:,1:3*nx);
yg5=reshape(yg(:,10*nx+1:13*nx),3*nx,nx);

xc=readbin([dirGrid 'XC.data'],[nx ny]);%xc=reshape(xc,nx,ny);
xc1=xc(:,1:3*nx);
xc5=reshape(xc(:,10*nx+1:13*nx),3*nx,nx);

%need at yg points
%Face1new.jVS = 9393;
jVS_1=9393;
iCS_1=1:ncut1;

%Face1new.jCN_1st = 10433;
jVN_1=10433;
iCN_1=1:ncut1;

%Face5new.iUE = 1065;
iUE_5=1065+ix5(1)-1;
jCE_5=ncut1+1:nx;

%Face5new.iUW = 25;
iUW_5=25+ix5(1)-1;
jCW_5=ncut1+1:nx;

%Face1:
LatS_f1_NA2160x1080 = yg1(iCS_1,jVS_1);	%27.196542739868164
LonS_f1_NA2160x1080 = xc1(iCS_1,jVS_1);
LatN_f1_NA2160x1080 = yg1(iCN_1,jVN_1);	%43.414096832275391
LonN_f1_NA2160x1080 = xc1(iCN_1,jVN_1);

LatE_f5_NA2160x1080 = yg5(iUE_5,jCE_5); %27.196542739868164
LonE_f5_NA2160x1080 = xc5(iUE_5,jCE_5);
LatW_f5_NA2160x1080 = yg5(iUW_5,jCW_5); %43.414096832275391
LonW_f5_NA2160x1080 = xc5(iUW_5,jCW_5);

Face5.latE = LatE_f5_NA2160x1080;
Face5.lonE = LonE_f5_NA2160x1080;
Face5.latW = LatW_f5_NA2160x1080;
Face5.lonW = LonW_f5_NA2160x1080;
Face5.iE = iUE_5;	%<-- yg pts
Face5.jE = jCE_5;
Face5.iW = iUW_5;	%<-- yg pts
Face5.jW = jCW_5;

Face1.latS = LatS_f1_NA2160x1080;
Face1.lonS = LonS_f1_NA2160x1080;
Face1.latN = LatN_f1_NA2160x1080;
Face1.lonN = LonN_f1_NA2160x1080;
Face1.jN = jVN_1;	%<-- yg pts
Face1.iN = iCN_1;
Face1.jS = jVS_1;	%<-- yg pts
Face1.iS = iCS_1;

save([dirOut 'NA2160x1080_latlon_fortides.mat'],'Face1','Face5');

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
print([dirOut 'NA2160x1080_latlon_fortides.png'],'-dpng');

