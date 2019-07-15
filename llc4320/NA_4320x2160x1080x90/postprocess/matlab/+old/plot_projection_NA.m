clear all;clc;
warning off

nx=2160; ny=2160;
dirIn=['/scratch/05427/iescobar/llc/llc4320/NA_4320x2160x1080x90/run_c67h_pk0000000001/'];
dirGrid=[dirIn 'GRID/'];
flist=dir([dirGrid 'tile*.mitgrid']);
nfx=[nx 0 0 0 ny/2];
nfy=[ny/2 0 0 0 nx];

ixg=6;iyg=7;

hf=readbin([dirIn 'SandSv18p1_NA4320x2160x1080_obcs11Jan2019.bin'],[nx ny]);
hf(find(hf>=0))=nan;hf(find(hf<0))=1;
for i=[1,5];
  xg{i}=read_slice([dirGrid flist(i).name],nfx(i)+1,nfy(i)+1,ixg,'real*8');
  yg{i}=read_slice([dirGrid flist(i).name],nfx(i)+1,nfy(i)+1,iyg,'real*8');
end;

yrStart=2002;moStart=1;daStart=1;deltaT=90; %Based on modelStartDate in STDOUT.0000
ts='0000026880';dstr=ts2dte(str2num(ts),deltaT,yrStart,moStart,daStart);%29-Jan-2002
eta=read_slice([dirIn 'diags/STATE/state_2d_hourly.' ts '.data'], nx, ny, 1); %1st variable in state_2d_hourly*
%eta=eta.*hf; etaf=get_aste_faces(eta,nfx,nfy);clear eta
etaf=get_aste_faces(eta,nfx,nfy);clear eta;

figure(2); clf; 
colormap(jet(256)); FF=etaf;
jy{1}=1:1080; ix{1}=1:2160; % indicies in local face coordinates for llc gcmfaces
jy{5}=1:2160; ix{5}=1:1080; % j points in v direction, and i in u direction
m_proj('lambert', 'lat', [26 44], 'long', [-83 -6]);


%%b1=abs(readbin([dirIn 'SandSv18p1_NA4320x2160x1080_obcs11Jan2019.bin'],[nx ny]));
%%bf1{1}=b1(:,1:ny/2);
%%bf1{5}=reshape(b1(:,ny/2+1:ny),ny/2,nx);
%%figure(2);clf;colormap(jet(84));FF=bf1;
%%jy{1}=1:1080; ix{1}=1:2160; % indicies in local face coordinates for llc gcmfaces
%%jy{5}=1:2160; ix{5}=1:1080; % j points in v direction, and i in u direction
%%m_proj('lambert','long',[-83 -6],'lat',[27 44]);
for i=[1,5];
    tmp=nan.*xg{i};tmp(1:end-1,1:end-1)=FF{i};
    m_pcolor(xg{i}(ix{i},jy{i}),yg{i}(ix{i},jy{i}),tmp(ix{i},jy{i}));
    shading flat;hold on;
end;
hold off;
%caxis([0 5000]);
m_coast('patch',.7.* [1 1 1],'edgecolor','none');
%m_grid('linest','none','tickdir','out','fontsize',12,... %24,...
m_grid('tickdir','out','fontsize',12,... %24,...
       'yaxislocation','left','xaxislocation','top','ticklen',.005,'box','fancy');%,...
%       'yticklabels',[],'xticklabels',[]);

ll=colorbar;set(ll,'location','southoutside','fontsize',24);%,'position',[.155 .13 .6 .02]);
set(ll,'ytick',[-1:.5:1]);

set(gcf,'paperunits','inches','paperposition',[0 0 14 18]);fpr=[dirIn 'eta_jet256.png'];print(fpr,'-dpng');

%colormap(m_colmap('jet','step',10));
%m_grid('tickdir','out','yaxislocation','right',...
%                       'xaxislocation','top','ticklen',.001);%,xlabeldir','end'
%hold on;
%m_quiver(lon,lat,u,v);
%x_label('Simulated surface winds');
%subplot(122);
%m_coast('patch',.9.*[1 1 1],'edgecolor','none');
%m_grid('tickdir','out','yticklabels',[],...
%                       'xticklabels',[],'linestyle','none','ticklen',.02);
%hold on;
%[cs,h]=m_contour(lon,lat,sqrt(u.*u+v.*v));
%clabel(cs,h,'fontsize',8);
%xlabel('Simulated something else');
%m_coast('color',[0 .6 0]);
%m_proj('oblique','lat',[60 15],'lon',[-75 -25],'aspecti',1);%.8);
