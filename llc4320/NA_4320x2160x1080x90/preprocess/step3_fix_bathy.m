clear all;

%define grid:
define_indices;

nxp=ncut1;ny=2*ncut2;

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
figure(1);clf;
for i=1:length(iface);
  sz=size(bathy0{iface(i)});
  [iy,ix]=meshgrid(1:sz(2),1:sz(1));
  tmp=ind{iface(i)};
  ii=find(tmp(:)>0);
  ij=find(tmp(:)<0);

  subplot(2,3,(i-1)*3+1);pcolor(bathy0{iface(i)}');caxis([0 1e2]);mythincolorbar;
               title(['bathy0, ' num2str(iface(i))]);
               shading flat;hold on;plot(ix(ii),iy(ii),'k.',ix(ij),iy(ij),'m.');hold off;
  subplot(2,3,(i-1)*3+2);pcolor(bathy{iface(i)}');caxis([0 1e2]);mythincolorbar;
               shading flat;hold on;plot(ix(ii),iy(ii),'k.',ix(ij),iy(ij),'m.');hold off;
  subplot(2,3,(i-1)*3+3);pcolor(bathy0{iface(i)}'-bathy{iface(i)}');caxis([-1e1 1e1]);mythincolorbar;grid;
               title('bathy0-bathy');shading flat;hold on;plot(ix(ii),iy(ii),'k.',ix(ij),iy(ij),'m.');hold off;
  %pause;
end;


%get rid of points due to overlapping obcs:
for i=1:length(iface);
  clear ii tmp1 tmp2
  tmp1=ind{iface(i)};
  tmp2=bathy{iface(i)};
  ii=find(tmp1<0);tmp2(ii)=0;bathy{iface(i)}=tmp2;
end;
%

bathy_keep0=bathy;

fix_bathy_v1;

%now put face 1 and face5 together to blend
a=cat(1,sym_g_mod(bathy{5},7,0),bathy{1});

%%fOut=[dirRoot 'run_template/bathy_aste' nxstr 'x' num2str(ncut2) 'x' num2str(ncut1) '_obcs' datestamp '.bin'];
%bcompact=get_aste_tracer(bathy,nfx,nfy);
%
%bcompact=aste_tracer2compact(bcompact,nfx,nfy);
%bcompact=-abs(bcompact);
%writebin(fBathyOut,bcompact,1,'real*4');
%
%if(blend_bathy==1);
%
%%now blend iymerge inside the domain, this is VERY SPECIFIC to ASTE
%%merge 20 grid points in

a=cat(1,sym_g_mod(bathy{5},7,0),bathy{1});a0=a;
sz=size(a);

%blending South:
iobcs=1;
jy=obcs2{iobcs}.jC2(2,1);
iymerge=jy+1:jy+31;
Liy=length(iymerge);
ix=1:sz(1);
for k=1:Liy;
  w_far=k/Liy;w_near=1-w_far;	%[1/20 19/20]
  a(ix,iymerge(k))=w_far.*a(ix,iymerge(end)+1)+w_near.*a(ix,jy);
  %fprintf('%i %f %f\n',[k w1 w0]);
end;
%

%blending North:
iobcs=2;
jy=obcs2{iobcs}.jC2(2,1);
iymerge=jy-1:-1:jy-31;
Liy=length(iymerge);
ix=1:sz(1);
for k=1:Liy;
  w_far=k/Liy;w_near=1-w_far;	%[1/20 19/20]
  a(ix,iymerge(k))=w_far.*a(ix,iymerge(end)-1)+w_near.*a(ix,jy);
  %fprintf('%i %f %f\n',[k w1 w0]);
end;
%

bcompact1=aste_tracer2compact(a,nfx,nfy);bcompact1=-abs(bcompact1);
writebin(fBathyOut,bcompact1,1,'real*4');
