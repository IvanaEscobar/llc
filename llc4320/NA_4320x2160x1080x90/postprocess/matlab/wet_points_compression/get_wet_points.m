clear all
%get_directories
define_indices;

dirGrid='/work/05427/iescobar/stampede2/llc/llc4320/NA_4320x2160x1080x90/GRID/';
nx= 2160;%id.n.x/2;
ny= 2160; %id.n.y;
nz= id.n.z;
nfx= id.nf.x;
nfy= id.nf.y;

%first, build a set of indices:
%u:
strv={'C','W','S'};
for ivar=1:size(strv,2);

  fprintf('\n%s \n',strv{ivar});

  % i1: rows 1:5 account for the 5 faces, and row 6 is the full compact
  i1=nan(6,nz);	
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
  
    for iface=[1,5];
      clear ifwet ifoffset;
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
