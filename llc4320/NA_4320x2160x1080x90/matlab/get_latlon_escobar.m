%% Running in *sverdrup*
clear all;

%% For NA_4320x2160x1080x90, data.obcs gives:
%  OB_Jnorth =  2160*1057,  1080*0,
%  OB_Jsouth =  2160*16,    1080*0,
%  OB_Iwest =   1080*0,     2160*4,
%  OB_Ieast =   539*0,      14*1531,    527*0,      2160*1065,

define_indices;                 % Loads nx, ny, nfx, nfy, etc.
set_directory;                  % Loads dirs

dirIn = dirs.child.binaries;
dirOut = dirs.child.OBCS;

list_fields2={'XC','YC','DXF','DYF','RAC','XG','YG','DXV','DYU','RAZ',...
    'DXC','DYC','RAW','RAS','DXG','DYG'};

b = readbin(fBathyOut, [2160, 2160]);   % Compact global dimensions
[b,bf] = get_aste_tracer(abs(b), nfx, nfy);
hf = readbin([dirIn '../../GRID/hFacC.data'], [2160, 2160]);hf(find(hf>0))=1;
[hf,hff]=get_aste_tracer(hf,nfx,nfy);

flist=dir([dirIn 'tile*.mitgrid']);

i=1;
yg=read_slice([dirIn flist(i).name],nfx(i)+1,nfy(i)+1,7,'real*8');
xc=read_slice([dirIn flist(i).name],nfx(i)+1,nfy(i)+1,1,'real*8');
Face1S.yg=yg(1:nfx(i),Face1S.jvel(2,1));
Face1S.xc=xc(1:nfx(i),Face1S.jC1(2,1));	%outside point

i=5;
yg=read_slice([dirIn flist(i).name],nfx(i)+1,nfy(i)+1,7,'real*8');
xc=read_slice([dirIn flist(i).name],nfx(i)+1,nfy(i)+1,1,'real*8');
Face5E.yg=yg(Face5E.ivel(2,1),1:nfy(i));
Face5E.xc=xc(Face5E.iC1(2,1) ,1:nfy(i));

i=1;
xg=read_slice([dirIn flist(i).name],nfx(i)+1,nfy(i)+1,6,'real*8');
yc=read_slice([dirIn flist(i).name],nfx(i)+1,nfy(i)+1,2,'real*8');
Face1E.xg=xg(Face1E.ivel(2,1),1:nfy(i));
Face1E.yc=yc(Face1E.iC1(2,1) ,1:nfy(i));

fsave=[dirOut 'latlon_for_obcs_tides.mat'];
save(fsave,'Face1S','Face5E','Face1E');

%note the indices might look off between face5 and face1, but the yg identically lined up.
load coast;
figure(1);clf;
subplot(221);
plot(long,lat,'k-',Face1S.xc,Face1S.yg,'r.',Face5E.xc,Face5E.yg,'b.',...
                   Face1E.xg,Face1E.yc,'m.');grid;

subplot(222);mypcolor(bf{1}');caxis([0 3e3]);mythincolorbar;hold on;
 plot(1:nfx(1),Face1S.jvel(2,1).*ones(1,nfx(1)),'k.-');
 plot(Face1E.ivel(2,1).*ones(1,nfy(1)),1:nfy(1),'k.-');
 grid;hold off;title('Face1S,Face1E');
 %shadeland(1:nfx(1),1:nfy(1),1-hff{1}',.7.*[1 1 1]);
subplot(223);mypcolor(bf{5}');caxis([0 3e3]);mythincolorbar;hold on;
 plot(Face5E.ivel(2,1).*ones(1,nfy(5)),1:nfy(5),'k.-');grid;hold off;title('Face5E');
 %shadeland(1:nfx(5),1:nfy(5),1-hff{5}',.7.*[1 1 1]);




















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
