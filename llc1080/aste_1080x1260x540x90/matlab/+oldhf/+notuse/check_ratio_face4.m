clear all;

define_indices;
set_directory;

dirIn='/scratch/atnguyen/aste_1080x1440x540x90/run_template/input_obcs/';
load([dirIn 'step1_obcs_13Jan2018.mat']);
load([dirIn 'step0_obcs_13Jan2018.mat']);

hFacW=rdmds([dirGrid0 'hFacW']);hFacW=reshape(hFacW,nx0,ny0,nz0);iiW=find(hFacW(:)==0);
      [tmp,hfW]=get_aste_tracer(hFacW,nfx0,nfy0);
hFacS=rdmds([dirGrid0 'hFacS']);hFacS=reshape(hFacS,nx0,ny0,nz0);iiS=find(hFacS(:)==0);
      [tmp,hfS]=get_aste_tracer(hFacS,nfx0,nfy0);
drF  =abs(squeeze(rdmds([dirGrid0 'DRF'])));

f4=2;
A=obcs0{f4}.dyg'*obcs0{f4}.drF';

A=repmat(A.*obcs0{f4}.hfW,[1 1 168]);

tr1=A.*U0{f4};
tr1p=tr1;tr1p(1:45,:,:)=nan;

tr1_sum =nansum(reshape(tr1,nz0*nx0,168),1);
tr1p_sum=nansum(reshape(tr1p,nz0*nx0,168),1);

%note: there is more mass loss (leaving the domain) with exclude Okhost
figure(3);clf;
subplot(211);plot(1:168,tr1_sum,'.-',1:168,tr1p_sum,'r.-');grid;legend('full','exclude Okhost');
subplot(212);plot(1:168,tr1p_sum-tr1_sum,'r.-');grid;
resid=tr1p_sum-tr1_sum;mean(resid);	%-3.752068315711877e+04

%if want to calculating the missing mass transports:
%v{4}(123,45,1:3,1:168) * dxg{4}(123,45)*drF(1:3);

get_Okhost=0;
if(get_Okhost==1);
%copying from step1
  D    =rdmds([dirGrid0 'Depth']);D=reshape(D,nx0,ny0);[D,Df]=get_aste_tracer(D,nfx0,nfy0);
  DXG  =rdmds([dirGrid0 'DXG']);  DXG=reshape(DXG,nx0,ny0);[DXG,dxg]=get_aste_tracer(DXG,nfx0,nfy0);

% list dirRun files:
  temp=dir([dirRun 'diags/state_3d_set1.*.data']);
  if(length(temp)==0);extU = 'TRSP/';else;extU='';end;
  flistU=dir([dirRun 'diags/' extU 'trsp_3d_set1.*.data']);
  prec2=get_precision([dirRun 'diags/' extU flistU(1).name(1:end-4) 'meta']);

  idot=find(flistT(1).name=='.');idot=idot(1)+1:idot(2)-1;
  tt=zeros(LL,4);
  for k=1:LL
    ts=str2num(flistU(k).name(idot));
    tmp=datevec(ts2dte(ts,deltaT,yrStart,moStart,0));     %take 1 day off to get month correct
    tt(k,1:3)=tmp(1:3);tt(k,4)=ts;
  end;

%define range of obcs timestep
  ii=find(tt(:,1)==yr_obcs(1));istart=ii(1);
  ii=find(tt(:,1)==yr_obcs(end));iend=ii(end);

  i4=123;
  j4=45;
  k4=1:3;	%Depth is 29.3978m, so only k=1:3;
  nt=length(istart:iend);

  cc=0;
  V4=nan(length(k4),nt);
  for klist=istart:iend;
    cc=cc+1;
    if(mod(cc,12)==0);fprintf('%i ',cc);end;
    finU=[dirRun 'diags/' extU flistU(klist).name];
    temp=read_slice(finU,nx0,ny0,[1:nz0]+nz0,prec2);temp(iiS)=nan;
         temp=temp./hFacS;VVEL=get_aste_faces(temp,nfx0,nfy0);clear temp;
  
    V4(1:3,cc)=squeeze(VVEL{4}(i4,j4,k4));
  end;

  dxg4=squeeze(dxg{4}(i4,j4));
  hfs4=squeeze(hfs{4}(i4,j4,k4));
  A4=(dxg4)*(hfs4.*drF(k4));

  tr4=repmat(A4,[1 nt]).*V4;
  tr4_sum=sum(tr4,1);

  Okhost.i4=i4;
  Okhost.j4=j4;
  Okhost.k4=k4;
  Okhost.V4=V4;
  Okhost.dxg4=dxg4;
  Okhost.hfs4=hfs4;
  Okhost.A4=A4;
  Okhost.tr4=tr4;
  Okhost.tr4_sum=tr4_sum;
  Okhost.dirRun=dirRun;
  Okhost.istart=istart;
  Okhost.iend=iend;
  Okhost.tt=tt;

  save([dirIn 'OkhostSea_transport.mat'],'Okhost');
else;
  load([dirIn 'OkhostSea_transport.mat'],'Okhost');
end;

figure(3);subplot(212);hold on;plot(1:nt,tr4_sum,'k.-');hold off;
