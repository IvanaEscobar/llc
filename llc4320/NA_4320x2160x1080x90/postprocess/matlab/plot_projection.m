clear all;warning off;

% nx=4320;ny=nx*13;
% dirIn=['/scratch/atnguyen/llc' num2str(nx) '/global/run_70K/'];
% dirGrid=['/scratch/atnguyen/llc' num2str(nx) '/global/GRID/'];
nx=2160; ny=2160;

flist=dir([dirGrid 'tile*.mitgrid']);
ixg=6;iyg=7;

nfx=[nx nx nx 3*nx 3*nx];nfy=[3*nx 3*nx nx nx nx];
yrStart=2011;moStart=9;daStart=10;deltaT=25;
ice2wtr=0.8856;snow2wtr=0.3212;

%hf=readbin([dirGrid 'hFacC.data'],[nx ny]);hf(find(hf<1))=nan;
hf=readbin([dirGrid 'bathy4320_r4'],[nx ny]);
hf(find(hf>=0))=nan;hf(find(hf<0))=1;

for i=1:5;
  xg{i}=read_slice([dirGrid flist(i).name],nfx(i)+1,nfy(i)+1,ixg,'real*8');
  yg{i}=read_slice([dirGrid flist(i).name],nfx(i)+1,nfy(i)+1,iyg,'real*8');
end;

ts='0000279792';dstr=ts2dte(str2num(ts),deltaT,yrStart,moStart,daStart);%29-Nov-2011
%ts='0000157680';
%ts='0000894320';
eta=readbin([dirIn 'Eta.' ts '.data'],[nx 13*nx]);
%area=readbin([dirIn 'SIarea.' ts '.data'],[nx 13*nx]);
heff=readbin([dirIn 'SIheff.' ts '.data'],[nx 13*nx]);
hsnow=readbin([dirIn 'SIhsnow.' ts '.data'],[nx 13*nx]);
eta=(eta+(ice2wtr.*heff+snow2wtr.*hsnow)).*hf;
clear heff hsnow

etaf=get_aste_faces(eta,nfx,nfy);clear eta

sst=readbin([dirIn 'SST.' ts '.data'],[nx 13*nx]).*hf;sstf=get_aste_faces(sst,nfx,nfy);clear sst;
sss=readbin([dirIn 'SSS.' ts '.data'],[nx 13*nx]).*hf;sssf=get_aste_faces(sss,nfx,nfy);clear sss;
u  =readbin([dirIn 'Uvel_k1.' ts '.data'],[nx 13*nx]).*hf;uf=get_aste_faces(u,nfx,nfy);clear u;
v  =readbin([dirIn 'Vvel_k1.' ts '.data'],[nx 13*nx]).*hf;vf=get_aste_faces(v,nfx,nfy);clear v;
for i=1:5;spf{i}=sqrt(uf{i}.^2+vf{i}.^2);end;
%ignore that u,v are not centered, for purpose of only visualization; also simply mult [u,v] w/ hf

vstr={'etaf','sstf','sssf','spf'};
cclim=[-1,1;-2 12;31 36;0 1];
%figure(ivar+3);clf;
figure(4);clf;
for ivar=2:size(vstr,2);
  hh(ivar)=subplot(3,1,ivar-1);
  if(strcmp(vstr{ivar},'etaf'));colormap(hsv(84));end;
  if(strcmp(vstr{ivar},'spf'));colormap(hh(ivar),hot(84));end;
  if(strcmp(vstr{ivar},'sssf'));colormap(hh(ivar),1-hot(84));end;
  if(strcmp(vstr{ivar},'sstf'));colormap(hh(ivar),seismic(84));end;
  eval(['FF=' vstr{ivar} ';']);
  jy1=2621*4:3240*4;ix1=1:500*4;
  ix5=sort(3*nx-jy1)+1;jy5=sort(nx-[1:330*4])+1+1;	%<-- extra +1 to get to the edge
  m_proj('lambert','lat',[50 68],'long',[-64 -5]);
  for i=[1,5];
    eval(['ix=ix' num2str(i) ';']);
    eval(['jy=jy' num2str(i) ';']);
    tmp=nan.*xg{i};tmp(1:end-1,1:end-1)=FF{i};
    m_pcolor(xg{i}(ix,jy),yg{i}(ix,jy),tmp(ix,jy));shading flat;hold on;
  end;
  hold off;
  caxis(cclim(ivar,:));
  m_coast('patch',.7.* [1 1 1],'edgecolor','none');
  m_grid('linest','none','tickdir','out','fontsize',12,... %24,...
         'yaxislocation','right','xaxislocation','top','ticklen',.005,'box','fancy',...
         'yticklabels',[],'xticklabels',[]);
  %ll=colorbar;set(ll,'location','southoutside','fontsize',24);%,'position',[.155 .13 .6 .02]);
  if(strcmp(vstr{ivar},'etaf'));set(ll,'ytick',[-1:.5:1]);end;
  if(strcmp(vstr{ivar},'sstf'));set(ll,'ytick',[0:4:12]);%set(hh(ivar),'position',[.08 .65 .9 .3]);end;%2
     view(-10,90);set(hh(2),'position',[.08 0.36 .85 .85]);
  if(strcmp(vstr{ivar},'sssf'));set(ll,'ytick',[32:2:36]);%set(hh(ivar),'position',[.08 .35 .9 .3]);end;%3
     view(-10,90);set(hh(3),'position',[.08 0.08 .85 .85]);
  if(strcmp(vstr{ivar},'spf'));set(ll,'ytick',[0:.2:1]);%set(hh(ivar),'position',[.08 .05 .9 .3]);end; %4
     view(-10,90);set(hh(4),'position',[.08 -.2 .85 .85]);end;
  keyboard
end;
set(gcf,'paperunits','inches','paperposition',[0 0 14 18]);fpr=[dirIn 'sst_sss_sp.png'];print(fpr,'-dpng');

%  %set(gcf,'paperunits','inches','paperposition',[0 0 28 16]);
%  %fpr=[dirIn vstr{ivar} '.png'];print(fpr,'-dpng');
%  set(gcf,'paperunits','inches','paperposition',[0 0 14 8]);
%  %fpr=[dirIn vstr{ivar} '.eps'];saveas(gcf,fpr,'fig');
%  fpr=[dirIn vstr{ivar} '.fig'];saveas(gcf,fpr,'fig');
%  %print(fpr,'-depsc','-painters');
%  %keyboard
%end;


%note that the ssh looks problematic, likely a "spin up" , should use the llc1080 ssh instead
figure(3);clf;colormap(hsv(84));
m_proj('ortho','lat',48,'long',-60);
for i=1:5;
  tmp=nan.*xg{i};tmp(1:end-1,1:end-1)=etaf{i};
  ix=1:2:size(xg{i},1);iy=1:2:size(xg{i},2);
  m_pcolor(xg{i}(ix,iy),yg{i}(ix,iy),tmp(ix,iy));shading flat;
  hold on;
end;
hold off;
caxis([-1.5 1.5]);
m_coast('patch',[.7 .7 .7]);
m_grid('tickdir','out','ticklen',.001,'xticklabels',[],'yticklabel',[],'linestyle',':');
ll=colorbar;set(ll,'ytick',[-1.5:.5:1.5],'location','southoutside');
set(gcf,'paperunits','inches','paperposition',[0 0 28 28]);
fpr=[dirIn 'EtaN_global.png'];print(fpr,'-dpng');
%set(gcf,'paperunits','inches','paperposition',[0 0 14 14]);
%fpr=[dirIn 'EtaN_global.eps'];print(fpr,'-depsc','-painters');

%cc1=jet(21);cc1(1,:)=1.*[1 1 1];colormap(cc1);
%caxis([-4 100]);colorbar;
%fpr=[dirIn 'sic_NorESM1_M_rcp60_r1i1p1_' mostr{imo} '_' num2str(yr_r(1)) '_' num2str(yr_r(end)) '_rad40.eps'];
%set(gcf,'paperunits','inches','paperposition',[0 0 48 48]);print(fpr,'-depsc','-painters');
%fpr=[dirIn 'sic_NorESM1_M_rcp60_r1i1p1_' mostr{imo} '_' num2str(yr_r(1)) '_' num2str(yr_r(end)) '_rad40.png'];
%set(gcf,'paperunits','inches','paperposition',[0 0 48 48]);print(fpr,'-dpng');




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

