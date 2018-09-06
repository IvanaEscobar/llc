clear all;

%define grid:
define_indices;

nxp=nx;ny=2*ncut1+ncut2+nx;

%--- set directory ---
set_directory;
dirIn  = dirOBCS;
dirOut = dirIn;

fIn=[dirOut 'step2b_obcs_' datestamp '.mat'];load(fIn,'obcs2');

% read in the bathymetry:
tmp=dir(fBathyIn);precIn='real*4';if(tmp.bytes/nxp/ny/4==2);precIn='real*8';end;
bathy=abs(readbin(fBathyIn,[nxp ny],1,precIn));
bathy=get_aste_faces(bathy,nfx,nfy);
bathy0=bathy;
ind=zeros(nxp,ny);ind=get_aste_faces(ind,nfx,nfy);

for iobcs=1:size(obcs2,2);
  iface=obcs2{iobcs}.face;
  ix1=unique(obcs2{iobcs}.iC1(2,:));
  ix2=unique(obcs2{iobcs}.iC2(2,:));
  jy1=unique(obcs2{iobcs}.jC1(2,:));
  jy2=unique(obcs2{iobcs}.jC2(2,:));
  imask=find(obcs2{iobcs}.imask==1);

  if(obcs2{iobcs}.obcsstr=='N'|obcs2{iobcs}.obcsstr=='S');	%N or S
    bathy{iface}(ix1(imask),jy1)=obcs2{iobcs}.D1(imask);
    bathy{iface}(ix1(imask),jy2)=obcs2{iobcs}.D2(imask);
    clear ij;tmp=ind{iface}(ix1(imask),jy1);ij=find(tmp(:)>=0);tmp(ij)=tmp(ij)+1;ind{iface}(ix1(imask),jy1)=tmp;
    clear ij;tmp=ind{iface}(ix1(imask),jy2);ij=find(tmp(:)>=0);tmp(ij)=tmp(ij)+1;ind{iface}(ix1(imask),jy2)=tmp;
    if(obcs2{iobcs}.obcsstr=='N');
      bathy{iface}(ix1(imask),jy1+1:nfy(iface))=0;
      ind{iface}(ix1(imask),jy1+1:nfy(iface))=-1;
    else;
      bathy{iface}(ix1(imask),1:jy1-1)=0;
      ind{iface}(ix1(imask),1:jy1-1)=-1;
    end;
  else;
    bathy{iface}(ix1,jy1(imask))=obcs2{iobcs}.D1(imask);
    bathy{iface}(ix2,jy1(imask))=obcs2{iobcs}.D2(imask);
    clear ij;tmp=ind{iface}(ix1,jy1(imask));ij=find(tmp(:)>=0);tmp(ij)=tmp(ij)+1;ind{iface}(ix1,jy1(imask))=tmp;
    clear ij;tmp=ind{iface}(ix2,jy1(imask));ij=find(tmp(:)>=0);tmp(ij)=tmp(ij)+1;ind{iface}(ix2,jy1(imask))=tmp;
    if(obcs2{iobcs}.obcsstr=='E');
      bathy{iface}(ix1+1:nfx(iface),jy1(imask))=0;
      ind{iface}(ix1+1:nfx(iface),jy1(imask))=-1;
    else;
      bathy{iface}(1:ix1-1,jy1(imask))=0;
      ind{iface}(1:ix1-1,jy1(imask))=-1;
    end;
  end;
%treat special case of Gibraltar Strait
  if(obcs2{iobcs}.flag_case==1);
    bathy{iface}(ix1,jy1(imask(1))-20:jy1(imask(1))-1)=0;
    bathy{iface}(ix1,jy1(end)+1:jy1(imask(end))+20)=0;
    bathy{iface}(ix1+1:nfx(iface),jy1(imask(1))-20:jy1(imask(end))+20)=0;
    ind{iface}(ix1,jy1(imask(1))-20:jy1(imask(1))-1)=-1;
    ind{iface}(ix1,jy1(imask(end))+1:jy1(imask(end))+20)=-1;
    ind{iface}(ix1+1:nfx(iface),jy1(imask(1))-20:jy1(imask(end))+20)=-1;
  end;
end;

iface=find(nfx>0);
nface=length(iface);
for i=1:length(iface);
  sz=size(bathy0{iface(i)});
  [iy,ix]=meshgrid(1:sz(2),1:sz(1));
  tmp=ind{iface(i)};
  ii=find(tmp(:)>0);
  ij=find(tmp(:)<0);

  figure(iface(i));clf;
  subplot(131);pcolor(bathy0{iface(i)}');caxis([0 1e3]);mythincolorbar;title(['bathy0, ' num2str(iface(i))]);
               shading flat;hold on;plot(ix(ii),iy(ii),'k.',ix(ij),iy(ij),'m.');hold off;
  subplot(132);pcolor(bathy{iface(i)}');caxis([0 1e3]);mythincolorbar;
               shading flat;hold on;plot(ix(ii),iy(ii),'k.',ix(ij),iy(ij),'m.');hold off;
  subplot(133);pcolor(bathy0{iface(i)}'-bathy{iface(i)}');caxis([-1e2 1e3]);mythincolorbar;grid;title('bathy0-bathy');
               shading flat;hold on;plot(ix(ii),iy(ii),'k.',ix(ij),iy(ij),'m.');hold off;
  %pause;
end;


%get rid of points due to overlapping obcs:
for i=1:length(iface);
  clear ii tmp1 tmp2
  tmp1=ind{iface(i)};
  tmp2=bathy{iface(i)};
  ii=find(tmp1<0);tmp2(ii)=0;bathy{iface(i)}=tmp2;
end;

%quick inspection: remove South America outside the domain:
ix=345:650;jy=120:270;bathy{1}(ix,jy)=0;

keyboard

%looks sort of ok, just skip the blending for now
%fOut=[dirRoot 'run_template/bathy_aste' nxstr 'x' num2str(ncut2) 'x' num2str(ncut1) '_obcs' datestamp '.bin'];
bcompact=get_aste_tracer(bathy,nfx,nfy);

figure(6);clf;mypcolor(bcompact');caxis([0 1e2]);mythincolorbar;grid;
%quick inspection, remove a few places inside the domain (away from obcs, w/in obcs, imask should already remove everything)
%ix=1175:1420;iy=1886:1887;bcompact(ix,iy)=0;
%ix=1980:2*1080;iy=1886:1887;bcompact(ix,iy)=0;

bcompact=aste_tracer2compact(bcompact,nfx,nfy);
bcompact=-abs(bcompact);
writebin(fBathyOut,bcompact,1,'real*4');

if(blend_bathy==1);

%now blend iymerge inside the domain, this is VERY SPECIFIC to ASTE
%merge 20 grid points in
temp=get_aste_tracer(bcompact,nfx,nfy);

%face1 & face5
iobcs=1;
jy=obcs2{iobcs}.jC2(2,1);

ix=1:2*nx;
iymerge=jy+1:jy+5;
Liy=length(iymerge);

for k=1:Liy;
  w1=k/Liy;w0=1-w1;	%[1/20 19/20]
  temp(ix,iymerge(k))=w1.*temp(ix,iymerge(end)+1)+w0.*temp(ix,jy);
  %fprintf('%i %f %f\n',[k w1 w0]);
end;

%face4:
jy=2014;	%can not touch this jy
ix=nx+1:2*nx;
iymerge=jy-1:-1:jy-5;
Liy=length(iymerge);

for k=1:Liy;
  w1=k/Liy;w0=1-w1;
  temp(ix,iymerge(k))=w1.*temp(ix,iymerge(end)-1)+w0.*temp(ix,jy);
end;

bcompact1=aste_tracer2compact(temp,nfx,nfy);bcompact1=-abs(bcompact1);
idot=find(fBathyOut=='.');
fOut=[fBathyOut(1:idot-1) 'sm' fBathyOut(idot:end)];
%fOut=[dirRoot 'run_template/bathy_aste' nxstr 'x' num2str(ncut2) 'x' num2str(ncut1) '_obcs' datestamp '_v1sm.bin'];
writebin(fOut,bcompact1,1,'real*4');
end;
