clear all;
warning off

%for aste_1080x1440x540x90:
% OB_Jsouth =   1080*256, 3060*0,
% OB_Ieast  =   680*0, 4*387, 756*0, 1080*0, 1080*494, 1080*1185,
%these are the first "wet point", but need to use the velocity points for tides, so it would have been:
% face1.S              face4.E            face5.E               face1.E
%[obcs2{1}.jvel(2,1) obcs2{2}.ivel(2,1) obcs2{3}.ivel(2,1) obcs2{4}.ivel(2,1)]	[257 494 1185 387]

%% for aste_90x150x60:
% From data.obcs:
% OB_Jsouth =   90*8, 300*0,
% OB_Ieast  =   86*0, 1*33, 63*0, 90*0, 90*42, 90*143,

%% [global local] indices for Face: 
% Ex: for llc 90 global indices on Face 1 are ALWAYS Nx=90 Ny=270
%     if we only use upper half of face, local indices are Nx=[1 135], Ny=[1 90].
%     global indices are Nx=[136 270], ny=[1 90]
% Obtained global indices from Step0 in preprocess
Face1S.jvel=[129    9  ]';  Face1S.jC1=[128     8  ]';
Face4E.ivel=[42     42 ]';  Face4E.iC1=[42      42 ]';
Face5E.ivel=[143    143]';  Face5E.iC1=[143     143]';
Face1E.ivel=[33     33 ]';  Face1E.iC1=[33      33 ]';

dirRoot='/work/05427/iescobar/stampede2/llc/llc90/aste_90x150x60/root/run_template/input_binaries/';
dirOut=[dirRoot '../input_obcs/'];
nx=90;
nfx=[nx 0 nx 60 150];nfy=[150 0 nx nx nx];

list_fields2={'XC','YC','DXF','DYF','RAC','XG','YG','DXV','DYU','RAZ',...
    'DXC','DYC','RAW','RAS','DXG','DYG'};

b=readbin([dirRoot 'bathy_obcs15Nov2018.bin'],[nx 2*nfy(1)+nx+nfx(4)],1,'real*8');
[b,bf]=get_aste_tracer(abs(b),nfx,nfy);
% iface=[1,4,5]; for i=1:size(iface,2); subplot(1,size(iface,2),i);mypcolor(bf{iface(i)}');mythincolorbar; title(["Face" num2str(iface(i))]);end
hf=readbin([dirRoot '../../GRID/hFacC.data'],[nx 2*nfy(1)+nx+nfx(4)]);hf(find(hf>0))=1;
[hf,hff]=get_aste_tracer(hf,nfx,nfy);
% for i=1:size(iface,2); subplot(1,size(iface,2),i);mypcolor(hff{iface(i)}');mythincolorbar; title(["Face" num2str(iface(i))]);end

flist=dir([dirRoot 'tile*.mitgrid']);

%% Saving lat/lon of boundaries
i=1;
yg=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,7,'real*8');
xc=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,1,'real*8');
Face1S.yg=yg(1:nfx(i),Face1S.jvel(2,1));
Face1S.xc=xc(1:nfx(i),Face1S.jC1(2,1));	%outside point

i=4;
yg=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,7,'real*8');
xc=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,1,'real*8');
Face4E.yg=yg(Face4E.ivel(2,1),1:nfy(i));
Face4E.xc=xc(Face4E.iC1(2,1) ,1:nfy(i));

i=5;
yg=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,7,'real*8');
xc=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,1,'real*8');
Face5E.yg=yg(Face5E.ivel(2,1),1:nfy(i));
Face5E.xc=xc(Face5E.iC1(2,1) ,1:nfy(i));

i=1;
xg=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,6,'real*8');
yc=read_slice([dirRoot flist(i).name],nfx(i)+1,nfy(i)+1,2,'real*8');
Face1E.xg=xg(Face1E.ivel(2,1),1:nfy(i));
Face1E.yc=yc(Face1E.iC1(2,1) ,1:nfy(i));

fsave=[dirOut 'latlon_for_obcs_tides.mat'];
save(fsave,'Face1S','Face4E','Face5E','Face1E');

%note the indices might look off between face5 and face1, but the yg identically lined up.
load coast;
figure(1);clf;
subplot(221);
plot(long,lat,'k-',Face1S.xc,Face1S.yg,'r.',Face5E.xc,Face5E.yg,'b.',...
                   Face4E.xc,Face4E.yg,'g.',Face1E.xg,Face1E.yc,'m.');grid;

subplot(222);mypcolor(bf{1}');caxis([0 3e3]);mythincolorbar;hold on;
 plot(1:nfx(1),Face1S.jvel(2,1).*ones(1,nfx(1)),'k.-');
 plot(Face1E.ivel(2,1).*ones(1,nfy(1)),1:nfy(1),'k.-');
 grid;hold off;title('Face1S,Face1E');
 %shadeland(1:nfx(1),1:nfy(1),1-hff{1}',.7.*[1 1 1]);
subplot(223);mypcolor(bf{4}');caxis([0 3e3]);mythincolorbar;hold on;
 plot(Face4E.ivel(2,1).*ones(1,nfy(4)),1:nfy(4),'k.-');grid;hold off;title('Face4E');
 %shadeland(1:nfx(4),1:nfy(4),1-hff{4}',.7.*[1 1 1]);
subplot(224);mypcolor(bf{5}');caxis([0 3e3]);mythincolorbar;hold on;
 plot(Face5E.ivel(2,1).*ones(1,nfy(5)),1:nfy(5),'k.-');grid;hold off;title('Face5E');
 %shadeland(1:nfx(5),1:nfy(5),1-hff{5}',.7.*[1 1 1]);

set(gcf,'paperunits','inches','paperposition',[0 0 12 10]);
fpr=[dirOut 'latlon_for_obcs_tides.png'];print(fpr,'-dpng');
