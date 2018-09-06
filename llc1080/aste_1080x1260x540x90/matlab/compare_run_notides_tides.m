clear all;
%dirIn1='/scratch/atnguyen/aste_1080x1260x540x90/run_notides_it0000_pk0000065160/+PICKUP/';
dirIn1='/scratch/atnguyen/aste_1080x1260x540x90/run_notides_it0000_pk0001166400/';
dirIn2='/scratch/atnguyen/aste_1080x1260x540x90/run_tides_it0000_pk0000680400/';
%dirIn2='/scratch/atnguyen/aste_1080x1260x540x90/run_notides_it0000_pk0001166400/';
nx=1080;ny=2*1260+nx+540;nz=90;nfx=[nx 0 nx 540 1260];nfy=[1260 0 nx nx nx];
rc=abs(round(squeeze(rdmds([dirIn2 'RC']))));

load_bbmap;bbmap(16,:)=1.*[1 1 1];bbmap(17,:)=bbmap(16,:);

dt=240;yrStart=2002;moStart=1;daStart=1;
flist=dir([dirIn2 'pickup.*.data']);
idot=find(flist(1).name=='.');idot=idot(1)+1:idot(2)-1;
%for i=1:length(flist);
i=72;
  ts=flist(i).name(idot);
  fIn1=[dirIn1 'pickup.' ts '.data'];
  fIn2=[dirIn2 'pickup.' ts '.data'];
  if(exist(fIn1)&exist(fIn2));
    ts0=str2num(ts);ts0str=sprintf('%10.10i',ts0);%ts0=0000097200;
    ts1=str2num(ts);ts1str=sprintf('%10.10i',ts1);%ts1=0001676160;
    
    %Arctic:
    ix=948:2160;iy=1213:2544;ix1=ix(1):8:ix(end);iy1=iy(1):8:iy(end);f1=.4;f2=.4;f3=10;
    %North America
    %ix=588:1514;iy=260:1205;ix1=ix(1):4:ix(end);iy1=iy(1):4:iy(end);f1=1;f2=.7;f3=5;
    %Nordic + Lab Seas
    %ix=775:1787;iy=725:1376;ix1=ix(1):8:ix(end);iy1=iy(1):8:iy(end);f1=.4;f2=.8;f3=5;
    %vertical slice:
    %ix=1:800;iy=300;
    ix=700;iy=140:350;
    
    %for k=1:50;
    k=1:30;
      %u=read_slice([dirIn1 'pickup.' ts0str '.data'],nx,ny,k,'real*8');
      %v=read_slice([dirIn1 'pickup.' ts0str '.data'],nx,ny,k+nz,'real*8');
      T0=read_slice([dirIn1 'pickup.' ts0str '.data'],nx,ny,k+2*nz,'real*8');
      %[u,v]=get_aste_vector(u,v,nfx,nfy,1);
      %uc0=(u(1:end-1,1:end-1)+u(2:end,1:end-1))./2;
      %vc0=(v(1:end-1,1:end-1)+v(1:end-1,2:end))./2;
      %T0=get_aste_tracer(T,nfx,nfy);
    
      clear T u v
    
      %u=read_slice([dirIn2 'pickup.' ts1str '.data'],nx,ny,k,'real*8');
      %v=read_slice([dirIn2 'pickup.' ts1str '.data'],nx,ny,k+nz,'real*8');
      T1=read_slice([dirIn2 'pickup.' ts1str '.data'],nx,ny,k+2*nz,'real*8');
      %[u,v]=get_aste_vector(u,v,nfx,nfy,1);
      %uc1=(u(1:end-1,1:end-1)+u(2:end,1:end-1))./2;
      %vc1=(v(1:end-1,1:end-1)+v(1:end-1,2:end))./2;
      %T1=get_aste_tracer(T,nfx,nfy);
    
      clear T u v

      T0=T0(:,1261:1260+nx,:);
      T1=T1(:,1261:1260+nx,:);

      T0p=squeeze(T0(ix,iy,:));T0p(find(T0p==0))=nan;
      T1p=squeeze(T1(ix,iy,:));T1p(find(T1p==0))=nan;
    
      cc1=jet(21);cc1(1,:)=.7.*[1 1 1];
      figure(1);clf;colormap(cc1);
      subplot(211);mypcolor(iy,-[1:30],T0p');cc2=caxis;cc2=[-3 cc2(end)];caxis(cc2);colorbar;grid;
        set(gca,'Ytick',[-30:5:-5,-1],'Yticklabel',num2str(rc([30:-5:5,1])));
      subplot(212);mypcolor(iy,-[1:30],T1p'-T0p');caxis(cc2);colorbar;
        set(gca,'Ytick',[-30:5:-5,-1],'Yticklabel',num2str(rc([30:-5:5,1])));

      %figure(1);clf;colormap(bbmap);%jet(21));
      %subplot(122);mypcolor(ix,iy,T1(ix,iy)');cc1=caxis;caxis([f1.*cc1(1) f2*cc1(2)]);mythincolorbar;
      %%hold on;hh=myquiver(ix1,iy1,uc1(ix1,iy1)',vc1(ix1,iy1)',f3);hold off;set(hh,'color',.5.*[1 1 1]);
      %title([num2str(k) ' ' num2str(rc(k)) ' ' ts2dte(ts1,240,2002,1,1)]);grid;
    %
      %subplot(121);mypcolor(ix,iy,T0(ix,iy)');caxis([f1.*cc1(1) f2*cc1(2)]);mythincolorbar;
      %%hold on;hh=myquiver(ix1,iy1,uc0(ix1,iy1)',vc0(ix1,iy1)',f3);hold off;set(hh,'color',.5.*[1 1 1]);
      %title([num2str(k) ' ' num2str(rc(k)) ' ' ts2dte(ts0,240,2002,1,1)]);grid;
    
      pause;
    %end;
  end;
end;

continue_the_rest=0;
if(continue_the_rest==1);
%dirIn='/scratch/atnguyen/aste_1080x1260x540x90/run_notides_it0000_pk0000065160/';
dirIn='/scratch/atnguyen/aste_1080x1260x540x90/run_notides_it0000_pk0001166400/';
%dir0='/scratch/atnguyen/aste_1080x450x540x50/run_obcs_pk0000183744/diags/STATE/';
%dir0='/scratch/atnguyen/aste_1080x450x540x50/run_obcs_pk0000420768/diags/STATE/';
dir0='/scratch/atnguyen/aste_1080x450x540x50/run_obcs_pk0000876096/diags/STATE/';
%ts1=0000486000;						%12-sep-2005
%ts1=0001004400;						%29-feb-2008
ts1=0001676160;							%01-oct-2014
ts0=dte2ts(ts2dte(ts1,240,2002,1,1),300,2002,1,1)	%388800
rc=abs(round(squeeze(rdmds([dirIn 'RC']))))';
rc0=round(abs(squeeze(rdmds('/scratch/atnguyen/aste_1080x450x540x50/GRID/RC'))))';

nx=1080;
ny=2*1260+540+nx;nfx=[nx 0 nx 540 1260];nfy=[1260 0 nx nx nx];nz=90;
ny0=2*450+540+nx;nfx0=[nx 0 nx 540 450];nfy0=[450 0 nx nx nx];nz0=50;

for k=1:length(rc0);
  i1=closest(rc0(k),rc);
  T0=read_slice([dir0 'state_3d_set1.' sprintf('%10.10i',ts0) '.data'],nx,ny0,k,'real*4');
  T=read_slice([dirIn 'pickup.' sprintf('%10.10i',ts1) '.data'],nx,ny,i1+2*nz,'real*8');
  T0=get_aste_tracer(T0,nfx0,nfy0);T=get_aste_tracer(T,nfx,nfy);
  figure(3);clf;colormap(bbmap);
    subplot(121);mypcolor(T(:,nfy(1)-nfy0(1)+1:nfy(1)+720+360)');cc1=caxis;cc1=[cc1(1) .7*cc1(2)];
	caxis(cc1);mythincolorbar;grid;title(rc(i1));
    subplot(122);mypcolor(T0(:,1:nfy0(1)+720+360)');caxis(cc1);mythincolorbar;grid;
    title([num2str(nfy0(1)) ', ' num2str(rc0(k))]);
  pause;%(0.3);
end;
%end;
