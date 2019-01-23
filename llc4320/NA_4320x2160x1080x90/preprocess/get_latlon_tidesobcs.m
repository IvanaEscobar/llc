clear all; clc;
warning off;

% Take velocity points as first available points. Ex: Face 1 will shift jC1
% for South OBC and iC1 for West OBC.
% From namelists/data:
%   OB_Jnorth = 2160*1057, 1080*0, 
%   OB_Jsouth = 2160*16  , 1080*0, 
%   OB_Ieast  = 539*0, 14*1531, 527*0, 2160*1065,
%   OB_Iwest  = 1080*0   , 2160*24, 
Face1N.jvel=[10433 1057]';  Face1N.jC1=[10433 1057]';
Face1S.jvel=[9393    17]';  Face1S.jC1=[9392    16]';
Face5E.ivel=[3569  1065]';  Face5E.iC1=[3569  1065]';
Face5W.ivel=[2529    25]';  Face5W.iC1=[2528    24]';
Face1E.ivel=[1531  1531]';  Face1E.iC1=[1531  1531]';

dirRoot='/scratch/ivana/llc/llc4320/NA_4320x2160x1080x90/run_template';
dirOut=[dirRoot 'input_obcs/'];
nx=2160;
ncut2=1080;
ny=2*ncut2;
nfx=[nx 0 0 0 ncut2];nfy=[ncut2 0 0 0 nx];

b=readbin([dirRoot 'input_binaries/SandSv18p1_NA4320x2160x1080_obcs13Jul2018.bin'],[nx ny]);
[b,bf]=get_aste_tracer(abs(b),nfx,nfy);
hf=readbin([dirRoot '../GRID/hFacC.data'],[nx ny]);hf(find(hf>0))=1;
[hf,hff]=get_aste_tracer(hf,nfx,nfy);

flist=dir([dirRoot 'input_binaries/tile*.mitgrid']);

list_fields2={'XC','YC','DXF','DYF','RAC','XG','YG','DXV','DYU','RAZ',...
    'DXC','DYC','RAW','RAS','DXG','DYG'};

i=1;
yg=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,7,'real*8');
xc=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,1,'real*8');
Face1N.yg=yg(1:nfx(i),Face1N.jvel(2,1));
Face1N.xc=xc(1:nfx(i),Face1N.jC1(2,1)); %outside point

yg=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,7,'real*8');
xc=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,1,'real*8');
Face1S.yg=yg(1:nfx(i),Face1S.jvel(2,1));
Face1S.xc=xc(1:nfx(i),Face1S.jC1(2,1));	

i=5;
yg=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,7,'real*8');
xc=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,1,'real*8');
Face5E.yg=yg(Face5E.ivel(2,1),1:nfy(i));
Face5E.xc=xc(Face5E.iC1(2,1) ,1:nfy(i));

yg=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,7,'real*8');
xc=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,1,'real*8');
Face5W.yg=yg(Face5W.ivel(2,1),1:nfy(i));
Face5W.xc=xc(Face5W.iC1(2,1) ,1:nfy(i));

i=1;
xg=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,6,'real*8');
yc=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,2,'real*8');
Face1E.xg=xg(Face1E.ivel(2,1),1:nfy(i));
Face1E.yc=yc(Face1E.iC1(2,1) ,1:nfy(i));

fsave=[dirOut 'latlon_for_obcs_tides.mat'];
save(fsave,'Face1N','Face1S','Face5E','Face5W', 'Face1E');

% NOTE: indices might look off between face5 and face1, but yg identically lined up.
load coast;
figure(1);clf;
subplot(221);
plot(long,lat,'k-', Face1N.xc,Face1N.yg,'r.',Face1S.xc,Face1S.yg,'g.',...
                    Face5E.xc,Face5E.yg,'c.',Face5W.xc,Face5W.yg,'b.',...
                    Face1E.xc,Face1E.yg,'m.');grid;
subplot(222);mypcolor(bf{1}');caxis([0 3e3]);mythincolorbar;hold on;
    plot(1:nfx(1),Face1N.jvel(2,1).*ones(1,nfx(1)),'k.-');
    plot(1:nfx(1),Face1S.jvel(2,1).*ones(1,nfx(1)),'k.-');
    plot(Face1E.ivel(2,1).*ones(1,nfy(1)),1:nfy(1),'k.-');
    grid;hold off;title('Face1N,Face1S,Face1E');
    %shadeland(1:nfx(1),1:nfy(1),1-hff{1}',.7.*[1 1 1]);
subplot(224);mypcolor(bf{5}');caxis([0 3e3]);mythincolorbar;hold on;
    plot(Face5E.ivel(2,1).*ones(1,nfy(5)),1:nfy(5),'k.-');
    plot(Face5W.ivel(2,1).*ones(1,nfy(5)),1:nfy(5),'k.-');
    grid;hold off;title('Face5E');
    %shadeland(1:nfx(5),1:nfy(5),1-hff{5}',.7.*[1 1 1]);

set(gcf,'paperunits','inches','paperposition',[0 0 12 10]);
fpr=[dirOut 'latlon_for_obcs_tides.png'];print(fpr,'-dpng');