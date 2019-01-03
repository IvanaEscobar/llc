%continuation from step0_get_indices.m
clear all;

%set generic indices + constants
%load predefined indices:
define_indices;

%set directory
set_directory;
dirIn = dirOBCS;
dirOut = dirIn;

% load in grid
hFacC=rdmds([dirGrid0 'hFacC']);hFacC=reshape(hFacC,nx0,ny0,nz0);
hFacW=rdmds([dirGrid0 'hFacW']);hFacW=reshape(hFacW,nx0,ny0,nz0);iiW=find(hFacW(:)==0);
hFacS=rdmds([dirGrid0 'hFacS']);hFacS=reshape(hFacS,nx0,ny0,nz0);iiS=find(hFacS(:)==0);
Dep  =rdmds([dirGrid0 'Depth']);Dep  =reshape(Dep  ,nx0,ny0);
%Dep=abs(readbin([dirGrid0 'bathy_fill9iU42Ef_noStLA.bin'],[nx0 ny0],1,'real*8'));
rF   =abs(squeeze(rdmds([dirGrid0 'RF'])));
drF  =abs(squeeze(rdmds([dirGrid0 'DRF'])));

% load step 0 obcs structures
fIn=[dirIn 'step0_obcs_' datestamp '.mat'];
load(fIn,'obcs0');		%obcs obcs0

% list dirRun files:
temp=dir([dirRun 'diags/state_3d_set1.*.data']);
if(length(temp)==0);extT = 'STATE/'; extU = 'TRSP/';else;extT='';extU='';end;
flistT=dir([dirRun 'diags/' extT 'state_3d_set1.*.data']);LL=length(flistT);
flistU=dir([dirRun 'diags/' extU 'trsp_3d_set1.*.data']);
prec1=get_precision([dirRun 'diags/' extT flistT(1).name(1:end-4) 'meta']);
prec2=get_precision([dirRun 'diags/' extU flistU(1).name(1:end-4) 'meta']);

%first loop: get time
idot=find(flistT(1).name=='.');idot=idot(1)+1:idot(2)-1;
tt=zeros(LL,4);
for k=1:LL
  ts=str2num(flistT(k).name(idot));
  tmp=datevec(ts2dte(ts,deltaT,yrStart,moStart,0));	%take 1 day off to get month correct
  tt(k,1:3)=tmp(1:3);tt(k,4)=ts;
end;

%define range of obcs timestep
ii=find(tt(:,1)==yr_obcs(1));istart=ii(1);
ii=find(tt(:,1)==yr_obcs(end));iend=ii(end);

%predefine matrices to reserve memory
for iobcs=1:size(obcs0,2);
  iface=obcs0{iobcs}.face;
  ix=unique(obcs0{iobcs}.iC1(2,:));Lix=length(ix);
  jy=unique(obcs0{iobcs}.jC1(2,:));Ljy=length(jy);
  iu=unique(obcs0{iobcs}.ivel(2,:));
  jv=unique(obcs0{iobcs}.jvel(2,:));
  imask=obcs0{iobcs}.imask;		%mask

  if(iu~=0 & jv==0);                  %either E or W
    T0{iobcs}=zeros(Ljy,nz0,LL);
  elseif(jv~=0 & iu==0);              %either N or S
    T0{iobcs}=zeros(Lix,nz0,LL);
  end;
  S0{iobcs}=T0{iobcs};
  U0{iobcs}=T0{iobcs};
  V0{iobcs}=T0{iobcs};
  msk{iobcs}=repmat(imask',[1 nz0]);
end;

%main loop
cc=0;
for klist=istart:iend;
  cc=cc+1;
  if(mod(cc,12)==0);fprintf('%i ',cc);end;
  finT=[dirRun 'diags/' extT flistT(klist).name]; finU=[dirRun 'diags/' extU flistU(klist).name];

  temp=read_slice(finT,nx0,ny0, 1:nz0,prec1);     THETA=get_aste_faces(temp,nfx0,nfy0);clear temp
  temp=read_slice(finT,nx0,ny0,[1:nz0]+nz0,prec1);SALT =get_aste_faces(temp,nfx0,nfy0);clear temp

  temp=read_slice(finU,nx0,ny0, 1:nz0,prec2);     temp(iiW)=nan;temp=temp./hFacW;UVEL=get_aste_faces(temp,nfx0,nfy0);clear temp;
  temp=read_slice(finU,nx0,ny0,[1:nz0]+nz0,prec2);temp(iiS)=nan;temp=temp./hFacS;VVEL=get_aste_faces(temp,nfx0,nfy0);clear temp;
  
%loop through the list of obcs:
  for iobcs=1:size(obcs0,2);	
    iface=obcs0{iobcs}.face;
    ix=unique(obcs0{iobcs}.iC1(2,:));Lix=length(ix);
    jy=unique(obcs0{iobcs}.jC1(2,:));Ljy=length(jy);
    iu=unique(obcs0{iobcs}.ivel(2,:));
    jv=unique(obcs0{iobcs}.jvel(2,:));

    T0{iobcs}(:,:,cc)=squeeze(THETA{iface}(ix,jy,:));		%first wet point
    S0{iobcs}(:,:,cc)=squeeze(SALT{iface}(ix,jy,:));		%first wet point

    if(iu~=0 & jv==0);			%either E or W
      U0{iobcs}(:,:,cc)=squeeze(UVEL{iface}(iu,jy,:));
    elseif(jv~=0 & iu==0);		%either N or S
      V0{iobcs}(:,:,cc)=squeeze(VVEL{iface}(ix,jv,:));
    end;

%16.Mar.2017: add msk here
    tmp=msk{iobcs};tmp(find(tmp==0))=nan;
    T0{iobcs}(:,:,cc)=T0{iobcs}(:,:,cc).*tmp;
    S0{iobcs}(:,:,cc)=S0{iobcs}(:,:,cc).*tmp;
    U0{iobcs}(:,:,cc)=U0{iobcs}(:,:,cc).*tmp;
    V0{iobcs}(:,:,cc)=V0{iobcs}(:,:,cc).*tmp;
  end;
end;
fprintf('\n');

%--- 26-Jun-2013:
%add mask, bathy and dx/dy, using convention minus = outside, plus = inside of velocity points
df =get_aste_faces(Dep,nfx0,nfy0);
hfs=get_aste_faces(hFacS,nfx0,nfy0);
hfw=get_aste_faces(hFacW,nfx0,nfy0);
hfc=get_aste_faces(hFacC,nfx0,nfy0);

for iobcs=1:size(obcs0,2);
  iface=obcs0{iobcs}.face;
  ix1=unique(obcs0{iobcs}.iC1(2,:));Lix=length(ix);
  ix2=unique(obcs0{iobcs}.iC2(2,:));
  jy1=unique(obcs0{iobcs}.jC1(2,:));Ljy=length(jy);
  jy2=unique(obcs0{iobcs}.jC2(2,:));
  iu =unique(obcs0{iobcs}.ivel(2,:));
  jv =unique(obcs0{iobcs}.jvel(2,:));

  if(iu~=0 & jv==0);			%either E or W
    obcs0{iobcs}.D1=squeeze(df{iface}(ix1,jy1))'.*msk{iobcs}(:,1);		%prime to make a column vector
    obcs0{iobcs}.D2=squeeze(df{iface}(ix2,jy1))'.*msk{iobcs}(:,1);		%prime to make a column vector
    obcs0{iobcs}.hfC1=squeeze(hfc{iface}(ix1,jy1,:)).*msk{iobcs};
    obcs0{iobcs}.hfC2=squeeze(hfc{iface}(ix2,jy1,:)).*msk{iobcs};
    obcs0{iobcs}.hfW =squeeze(hfw{iface}(iu,jy1,:)).*msk{iobcs};
    obcs0{iobcs}.hfS =zeros(Ljy,nz0);
  elseif(jv~=0 & iu==0);
    obcs0{iobcs}.D1=squeeze(df{iface}(ix1,jy1)).*msk{iobcs}(:,1);
    obcs0{iobcs}.D2=squeeze(df{iface}(ix1,jy2)).*msk{iobcs}(:,1);
    obcs0{iobcs}.hfC1=squeeze(hfc{iface}(ix1,jy1,:)).*msk{iobcs};
    obcs0{iobcs}.hfC2=squeeze(hfc{iface}(ix1,jy2,:)).*msk{iobcs};
    obcs0{iobcs}.hfS =squeeze(hfs{iface}(ix1,jv,:)).*msk{iobcs};
    obcs0{iobcs}.hfW =zeros(Lix,nz0);
  end;

  obcs0{iobcs}.rF=rF;
  obcs0{iobcs}.drF=drF;
  obcs0{iobcs}.tt=tt;
  obcs0{iobcs}.RunStr=RunStr;
  obcs0{iobcs}.RunStrShort=RunStrShort;

end;

%datestamp=date;datestamp(find(datestamp=='-'))='';
fsave=[dirOut 'step1_obcs_' datestamp '.mat'];save(fsave,'obcs0','T0','S0','U0','V0');fprintf('%s\n',fsave);
