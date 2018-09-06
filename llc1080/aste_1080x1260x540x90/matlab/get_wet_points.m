clear all
dirRoot='/work/03901/atnguyen/llc1080/aste_1080x1260x540x90/';
dirGrid=[dirRoot 'GRID/'];

nx=1080;ny=2*1260+nx+540;nz=90;nfx=[nx 0 nx 540 1260];nfy=[1260 0 nx nx nx];

%first, build a set of indices:
%u:
strv={'C','W','S'};
for ivar=1:size(strv,2);

  fprintf('%s ',strv{ivar});

  i1=nan(6,nz);			%1:5: 5 faces, 6: full compact
  i2=nan(6,nz);i2(:,1)=0;
  ind=nan(nx*ny*nz,6);

  for iz=1:nz

    clear iwet ifwet hf hff ioffset ifoffset

    hf=read_slice([dirGrid 'hFac' strv{ivar} '.data'],nx,ny,iz);
  
  %first, deal in compact format:
    ioffset=(iz-1)*nx*ny;
    iwet=find(hf(:)>0);
  
  %index count of wet point, per layer
    if(iz==1);
      i1(6,iz)=i2(6,iz)+1;
    else;
      i1(6,iz)=i2(6,iz-1)+1;
    end;
    i2(6,iz)=i1(6,iz)-1+length(iwet);
  
  %actual wet indices:
    ind(i1(6,iz):i2(6,iz),6)=iwet+ioffset;
  
  %now split into faces:
    hff=get_aste_faces(hf,nfx,nfy);
  
    for iface=[1,3:5];
  
      clear ifwet ifoffset
;
      ifoffset=(iz-1)*nfx(iface)*nfy(iface);
      ifwet=find(hff{iface}(:)>0);
  
      if(iz==1);
        i1(iface,iz)=i2(iface,iz)+1;
      else;
        i1(iface,iz)=i2(iface,iz-1)+1;
      end;
      i2(iface,iz)=i1(iface,iz)-1+length(ifwet);
  
      ind(i1(iface,iz):i2(iface,iz),iface)=ifwet+ifoffset;
    end;

    fprintf('%i ',iz);
  
  end;%iz
  

%now assinging and save:
  imax=i2(6,nz);
  ind=ind(1:imax,:);

  fOut=[dirGrid 'Index_wet_hfac' strv{ivar} '.mat'];
  save(fOut,'-v7.3','ind','i1','i2');
  fprintf('%s\n',fOut);
  
end;	%ivar
