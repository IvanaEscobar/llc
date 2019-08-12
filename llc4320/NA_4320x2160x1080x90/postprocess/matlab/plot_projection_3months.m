%%function plot_projection_NA4320(color_name)
    clearvars -except color_name;clc; warning off;

    nx=2160; ny=2160;nz=90;
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
    
    ts='0000026880';
%    theta=read_slice([dirIn 'PICKUP/pickup.ckptB.data'], nx,ny, 1+(3-1)*nz);
%    theta=theta.*hf; thetaf=get_aste_faces(theta,nfx,nfy);clear theta
    eta=read_slice([dirIn 'diags/STATE/state_2d_hourly.' ts '.data'], nx, ny, 1); %1st variable in state_2d_hourly*
    eta=eta.*hf; etaf=get_aste_faces(eta,nfx,nfy);clear eta
    
    figure(2); clf;
    color_name='jet256';
    colormap(jet(256));
%    if (color_name=="jet84")
%        colormap(jet(84)); 
%    elseif (color_name=="jet256")
%        colormap(jet(256)); 
%    elseif (color_name=="seismic84")
%        colormap(seismic(84)); 
%    elseif (color_name=="seismic256")
%        colormap(seismic(256)); 
%    end
    FF=etaf;
    jy{1}=1:1080; ix{1}=1:2160; % indicies in local face coordinates for llc gcmfaces
    jy{5}=1:2160; ix{5}=1:1080; % j points in v direction, and i in u direction
    m_proj('lambert', 'lat', [27 44], 'long', [-84 -4]);
    
    for i=[1,5];
        tmp=nan.*xg{i};tmp(1:end-1,1:end-1)=FF{i};
        m_pcolor(xg{i}(ix{i},jy{i}),yg{i}(ix{i},jy{i}),tmp(ix{i},jy{i}));
        shading flat;hold on;
    end;
    hold off;
    caxis([-1.45 1.1]);
    m_coast('patch',.7.* [1 1 1],'edgecolor','none');
    %m_grid('linest','none','tickdir','out','fontsize',12,... %24,...
    m_grid('tickdir','in','fontsize',12,... %24,...
           'yaxislocation','left','xaxislocation','top','ticklen',.005,'box','fancy');
    ll=colorbar;set(ll,'location','southoutside','fontsize',12);%,'position',[.155 .13 .6 .02]);%,'ytick',[-1:.5:1]);
    set(gcf,'paperunits','inches','paperposition',[0 0 18 12]);
    fpr=[dirIn 'eta_z1_' color_name '.png'];
    print(fpr,'-dpng');
%end
