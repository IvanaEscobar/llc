clear all;

warning off

dirGrid1=['/scratch/atnguyen/llc' num2str(nx) '/NA_4320x2160x1080x90/run_template/input_binaries/'];
flist1=dir([dirGrid1 'tile*.mitgrid']);
nx1=2160;ny1=2160;
nfx1=[nx1 0 0 0 ny1/2];
nfy1=[ny1/2 0 0 0 nx1];

ixg=6;iyg=7;

%hf=readbin([dirGrid 'hFacC.data'],[nx ny]);hf(find(hf<1))=nan;
hf1=readbin([dirGrid1 'SandSv18p1_NA4320x2160x1080_obcs13Jul2018.bin'],[nx1 ny1]);
hf1(find(hf1>=0))=nan;hf1(find(hf1<0))=1;
for i=[1,5];
  xg1{i}=read_slice([dirGrid1 flist(i).name],nfx1(i)+1,nfy1(i)+1,ixg,'real*8');
  yg1{i}=read_slice([dirGrid1 flist(i).name],nfx1(i)+1,nfy1(i)+1,iyg,'real*8');
end;

b1=abs(readbin([dirGrid1 'SandSv18p1_NA4320x2160x1080_obcs13Jul2018.bin'],[nx1 ny1]));
bf1{1}=b1(:,1:ny1/2);
bf1{5}=reshape(b1(:,ny1/2+1:ny1),ny1/2,nx1);
figure(4);clf;colormap(jet(84));FF=bf1;
jy1=1:1080;ix1=1:2160;
jy5=1:2160;ix5=1:1080;
m_proj('lambert','long',[-83 -6],'lat',[27 44]);
for i=[1,5];
    eval(['ix=ix' num2str(i) ';']);
    eval(['jy=jy' num2str(i) ';']);
    tmp=nan.*xg1{i};tmp(1:end-1,1:end-1)=FF{i};
    m_pcolor(xg1{i}(ix,jy),yg1{i}(ix,jy),tmp(ix,jy));shading flat;hold on;
end;
hold off;
caxis([0 5000]);
m_coast('patch',.7.* [1 1 1],'edgecolor','none');
%m_grid('linest','none','tickdir','out','fontsize',12,... %24,...
m_grid('tickdir','out','fontsize',12,... %24,...
       'yaxislocation','right','xaxislocation','top','ticklen',.005,'box','fancy');%,...
%       'yticklabels',[],'xticklabels',[]);

%ll=colorbar;set(ll,'location','southoutside','fontsize',24);%,'position',[.155 .13 .6 .02]);
%set(ll,'ytick',[-1:.5:1]);

%set(gcf,'paperunits','inches','paperposition',[0 0 14 18]);fpr=[dirIn 'sst_sss_sp.png'];print(fpr,'-dpng');

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

