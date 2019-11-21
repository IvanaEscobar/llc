clear all;

%now read in the global/region/Gulfstream2 grid to locate these points:
dirrun2='/work/03901/atnguyen/llc4320/global/regions/GulfStream2/';
dirgrid2=[dirrun2 'grid/'];
dirout2=[dirrun2 'extract_hourly/'];if(~exist(dirout2));mkdir(dirout2);end;
nx2=2016;ny2=1661;
deltaT2=25;yrstart2=2011;mostart2=09;dastart2=10;
fprofpoint2=[dirout2 'unique_profpoint_GulfStream2_L104_m69p5.bin'];

if(~exist(fprofpoint2));
		%/*{{{*/ exist_fprofpoint2
%first get the NA region wetpts:
  dirRoot='/work/03901/atnguyen/Ivana/llc4320/NA_4320x2160x1080x90/';
  dirGrid=[dirRoot 'GRID/'];
  
  RunStr='run_c67h_tidal_bc_pk0000000001';
  dirin=[dirRoot RunStr '/extract_hourly/'];if(~exist(dirin));error('dir hourly not existed');end;
  
  Lprofpoint=104;section_name='_m69p5';
  fprofpoint=[dirin 'unique_profpoint_L' num2str(Lprofpoint) section_name '.bin'];pp=readbin(fprofpoint,[1 Lprofpoint]);
  findex=[dirin 'ind_wet_L104_m69p5Section.mat'];load(findex,'indcompact','indwet','indprof');
  
  fGrid=[dirGrid 'Index_wet_hfacC_2D.mat'];load(fGrid,'ind');
  
  nx=2160;ny=nx;
  
  yc=rdmds([dirGrid 'YC']);yc=reshape(yc,nx,ny);yc=yc(ind(:,6));	%wet
  xc=rdmds([dirGrid 'XC']);xc=reshape(xc,nx,ny);xc=xc(ind(:,6));	%wet

%get wet indices for top layer only
  for j=1:length(pp);
      ij=find(indprof==pp(j));indwet1(j)=indwet(ij(1));
  end;
  
  yc=yc(indwet1);
  xc=xc(indwet1);

%now read in the global/region/Gulfstream2 grid to locate these points:
  yc2=readbin([dirgrid2 'YC_2016x1661'],[nx2 ny2]);
  xc2=readbin([dirgrid2 'XC_2016x1661'],[nx2 ny2]);
  
  for i=1:length(yc);
    tmpyc=abs(yc2(:)-yc(i));
    tmpxc=abs(xc2(:)-xc(i));
  
    ij=find(tmpyc<1e-3 & tmpxc<1e-3);
    if(length(ij)==1)
      pp2(i)=ij;
    else;
      fprintf('%i ');
    end;
  end;
  %somehow pp2 is in reverse order? sort to make it easier to read
  pp2=sort(pp2);
  writebin(fprofpoint2,pp2);

else;		%/*}}}*/ exist_fprofpoint2
  Lprofpoint=104;
  pp=readbin(fprofpoint2,[1 Lprofpoint]);	%already sorted
end;

%now extracting Etan
tsstr='0001278864_0001492992';nobs=1488;
fout=[dirout2 'Eta_L104_m69p5.' tsstr '.data'];
fsave=[dirout2 'Eta_L104_m69p5_info.mat'];
if(~exist(fout));
  flist=dir([dirrun2 'Eta/000*_Eta_15169.9265.1_2016.1661.1']);	%lots of files	%/*{{{*/ %get_etan_timeseries
  L=length(flist);
  ii=length(flist)-1488+1:length(flist);				%take the last 1488 records, 2mo

  Eta=zeros(length(pp),length(ii));
  idash=find(flist(1).name=='_');
  tsstr=[flist(ii(1)).name(1:idash(1)-1) '_' flist(ii(end)).name(1:idash(1)-1)];

  for i=1:length(ii);
    tmp=readbin([dirrun2 'Eta/' flist(ii(i)).name],[max(pp) 1]);
    Eta(:,i)=tmp(pp);
    if(mod(i,100)==0|i==length(ii));fprintf('%i ',i);end;
  end;
  writebin(fout,Eta,1,'real*4');

%get the rest of the info in order to do nodal correction:
  nobs=length(ii);
  clear tt;
  tt=zeros(nobs,6);
  for i=1:nobs
    ts=str2num(flist(ii(i)).name(1:idash(1)-1));
    tmp=datevec(ts2dte(ts,deltaT2,yrstart2,mostart2,dastart2));
    tt(i,1:5)=[tmp(1:3) 0 30];tt(i,6)=ts;
  end;
  a=[];
  a.deltaT=deltaT2;
  a.yrstart=yrstart2;
  a.mostart=mostart2;
  a.dastart=dastart2;
  tmp=datevec(ts2dte(a.tt(1,6),a.deltaT,a.yrstart,a.mostart,a.dastart));
  a.startTime=[tmp(1:3) 0 30 0];
  a.nx=nx2;
  a.ny=ny2;
  a.tt=tt;
  a.pp=pp';	%note the prime
    yc2=readbin([dirgrid2 'YC_2016x1661'],[nx2 ny2]);a.yc=yc2(pp)';	%note the prime
    xc2=readbin([dirgrid2 'XC_2016x1661'],[nx2 ny2]);a.xc=xc2(pp)';	%note the prime
    D2 =readbin([dirgrid2 'Depth_2016x1661'],[nx2 ny2]);a.D=D2(pp)';	%note the prime
  m69p5=a;
  save(fsave,'m69p5');
					%%/*}}}*/  %get_etan_timeseries
else;
  Eta=readbin(fout,[length(pp) nobs]);
  load(fsave,'m69p5');
end;

%========================

file_constituent=['~atnguyen/matlab/atn_tools/tide_constituent.mat'];load(file_constituent);

%nobs=length(ii);
nobsu=nobs-rem(nobs-1,2);           %nobsu=nobs if length(ii) is odd
dt=1;
t=dt*([1:nobs]'-ceil(nobsu./2));    %time vector for entire timeseries, center @ midpt [hr]
nameu=['Q1  ';'O1  ';'K1  ';'N2  ';'M2  ';'S2  '];
nameu1={'Q1  ';'O1  ';'K1  ';'N2  ';'M2  ';'S2  '};
M=size(nameu,1);
for iM=1:M
  itide(iM)=strmatch(nameu(iM,:),tide_constituent.name);
  tmp=nameu(iM,:);
  m69p5.nameu{iM}=tmp;
end;
w=tide_constituent.freq(itide);             % Q1,O1,K1,N2,M2,S2
m69p5.w=w;

%now pretend read in data one at a time:
  N=nobs;
  G=nan(N,2*M+1);				% nt x 2*M+1 [1488 x 13]
  G(:,1)=1;
    for iM=1:M;
      G(:,0*M+1+iM)=cos(2.*pi.*w(iM).*t(1:N));
      G(:,1*M+1+iM)=sin(2.*pi.*w(iM).*t(1:N));
    end;
  BIGG=G'*G;BIGG=pinv(BIGG);BIGG=BIGG*G';		%2*M+1 x nt [13 x 1488]
  M_tide_k=zeros(Lprofpoint,2*M+1);			%[length(pp) 2*M+1]
  for i=1:nobs;
    FF=Eta(:,i);
    clear temp temp1;
    temp=BIGG(:,i);
    temp1=squeeze(reshape(FF(:)*temp(:).',length(pp),1,[]));%[104 2*M+1]
    M_tide_k=M_tide_k+temp1;
  end;

  for itide=1:4;
        if(itide==1);namet='M2  ';llim=[-.005,1];
    elseif(itide==2);namet='S2  ';llim=[-.005,1];
    elseif(itide==3);namet='K1  ';llim=[-.005,1];
    elseif(itide==4);namet='O1  ';llim=[-.005,.1]; end;
    itide1=strmatch(namet,m69p5.nameu);
    tmp=datevec(ts2dte(m69p5.tt(1,6),m69p5.deltaT,m69p5.yrstart,m69p5.mostart,m69p5.dastart));
    m69p5.startTime=[tmp(1:3) 0 30 0];
    starttime=datenum(m69p5.startTime);
%check size
    sz=size(M_tide_k);sz1=size(m69p5.yc);if(sz(1)==sz1(2));yc=yc';else;yc=m69p5.yc;end;
    [AMP,PHA]=func_get_3d_ap_mod2(M_tide_k,namet,1,nobs,starttime,yc);

    m69p5.AMP(:,itide)=AMP;
    m69p5.PHA(:,itide)=PHA;
  end;
  save(fsave,'m69p5');
