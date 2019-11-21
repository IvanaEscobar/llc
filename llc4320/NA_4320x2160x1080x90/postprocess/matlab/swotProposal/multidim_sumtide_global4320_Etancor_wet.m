clear all;

%now read in the global/region/Gulfstream2 grid to locate these points:
dirrun2='/work/03901/atnguyen/llc4320/global/regions/GulfStream2/';
dirgrid2=[dirrun2 'grid/'];
dirout2=[dirrun2 'extract_hourly/'];if(~exist(dirout2));mkdir(dirout2);end;
nx2=2016;ny2=1661;
deltaT2=25;yrstart2=2011;mostart2=09;dastart2=10;

%get wet indices:
hf=readbin([dirgrid2 'hFacC_2016x1661x1'],[nx2 ny2]);
iwet=find(hf(:)>0);		%2618709

%now extracting Etan
tsstr='0001278864_0001492992';nobs=1488;

fOut=[dirout2 'Eta_' tsstr '_Lwet' num2str(length(iwet)) '.mat'];
fsave=[dirout2 'Eta_Mtidek_pointC.mat'];
if(~exist(fOut));
  flist=dir([dirrun2 'Eta/000*_Eta_15169.9265.1_2016.1661.1']);	%lots of files	%/*{{{*/ %get_etan_timeseries
  L=length(flist);
  ii=length(flist)-1488+1:length(flist);				%take the last 1488 records, 2mo
  idash=find(flist(1).name=='_');

%get the rest of the info in order to do nodal correction:
  nobs=length(ii);
  clear tt;
  tt=zeros(nobs,6);
  for i=1:nobs
    ts=str2num(flist(ii(i)).name(1:idash(1)-1));
    tmp=datevec(ts2dte(ts,deltaT2,yrstart2,mostart2,dastart2));
    tt(i,1:5)=[tmp(1:3) 0 30];tt(i,6)=ts;
  end;
  ptC=[];
  ptC.deltaT=deltaT2;
  ptC.yrstart=yrstart2;
  ptC.mostart=mostart2;
  ptC.dastart=dastart2;
  ptC.tt=tt;
  tmp=datevec(ts2dte(ptC.tt(1,6),ptC.deltaT,ptC.yrstart,ptC.mostart,ptC.dastart));
  ptC.startTime=[tmp(1:3) 0 30 0];
  ptC.nx=nx2;
  ptC.ny=ny2;
					%%/*}}}*/  %get_etan_timeseries
%========================
  file_constituent=['~atnguyen/matlab/atn_tools/tide_constituent.mat'];load(file_constituent);
  nobsu=nobs-rem(nobs-1,2);           %nobsu=nobs if length(ii) is odd
  dt=1;
  t=dt*([1:nobs]'-ceil(nobsu./2));    %time vector for entire timeseries, center @ midpt [hr]
  nameu=['Q1  ';'O1  ';'K1  ';'N2  ';'M2  ';'S2  '];
  nameu1={'Q1  ';'O1  ';'K1  ';'N2  ';'M2  ';'S2  '};
  M=size(nameu,1);
  for iM=1:M
    itide(iM)=strmatch(nameu(iM,:),tide_constituent.name);
  end;
  w=tide_constituent.freq(itide);             % Q1,O1,K1,N2,M2,S2

  ptC.nameu=nameu;
  ptC.w=w;
  save(fsave,'ptC');

%now pretend read in data one at a time:
  N=nobs;
  G=nan(N,2*M+1);				% nt x 2*M+1 [1488 x 13]
  G(:,1)=1;
    for iM=1:M;
      G(:,0*M+1+iM)=cos(2.*pi.*w(iM).*t(1:N));
      G(:,1*M+1+iM)=sin(2.*pi.*w(iM).*t(1:N));
    end;
  BIGG=G'*G;BIGG=pinv(BIGG);BIGG=BIGG*G';		%2*M+1 x nt [13 x 1488]
  M_tide_k=zeros(length(iwet),2*M+1);			%[length(pp) 2*M+1]
  for it=1:nobs;
    t1=clock;
    FF=readbin([dirrun2 'Eta/' flist(ii(it)).name],[nx2*ny2,1]);FF=FF(iwet);
    clear temp temp1;
    temp=BIGG(:,it);
    temp1=squeeze(reshape(FF(:)*temp(:).',length(iwet),1,[]));%[104 2*M+1]
    M_tide_k=M_tide_k+temp1;
    if(mod(it,10)==0|it==nobs);fprintf('%i %f ',etime(clock,t1);end;
  end;
  save(fOut,'M_tide_k','it','iwet');fprintf('%s\n',fOut);
else;
  load(fOut);
  load(fsave,'ptC');
end;

plot_fig=0;
if(plot_fig);
  xc=readbin([dirgrid2 'XC_2016x1661'],[nx2 ny2]);xc=xc(iwet);
  yc=readbin([dirgrid2 'YC_2016x1661'],[nx2 ny2]);yc=yc(iwet);
  hf=readbin([dirgrid2 'hFacC_2016x1661x1'],[nx2 ny2]);hf=hf(iwet);
  d=readbin([dirgrid2 'Depth_2016x1661'],[nx2 ny2]);d=d(iwet);

  for itide=1:4;
        if(itide==1);namet='M2  ';llim=[-.005,1];
    elseif(itide==2);namet='S2  ';llim=[-.005,1];
    elseif(itide==3);namet='K1  ';llim=[-.005,1];
    elseif(itide==4);namet='O1  ';llim=[-.005,.1]; end;
    itide1=strmatch(namet,ptC.nameu);

    idot=find(fOut=='.');
    fOut1=[fOut(1:idot-1) '_' strtrim(namet) '_AMP_PHA' fOut(idot:end)]

    if(~exist(fOut1));
	%/*{{{*/
      %tmp=datevec(ts2dte(ptC.tt(1,6),ptC.deltaT,ptC.yrstart,ptC.mostart,ptC.dastart));
      %ptC.startTime=[tmp(1:3) 0 30 0];
      starttime=datenum(ptC.startTime);
%check size
      sz=size(M_tide_k);sz1=size(yc);if(sz(1)==sz1(2));yc=yc';else;yc=yc;end;
      [AMP,PHA]=func_get_3d_ap_mod2(M_tide_k,namet,1,nobs,starttime,yc);

      AMP=squeeze(AMP);		%[Lwet_layer1 1]
      PHA=squeeze(PHA);		%[Lwet_layer1 1]

%saving
      clear tide
      tide.name=namet;
      tide.freq=ptC.w(itide1);
      tide.startTime=ptC.startTime;
      tide.tt=ptC.tt;
        tide.iwet=iwet;%1:Lwet_layer1;
        tide.iy=[];
      tide.LON=xc;
      tide.LAT=yc;
      tide.mask=hf;
      tide.bathy=d;
      tide.AMP=AMP;
      tide.PHA=PHA;
      tic;save(fOut1,'tide');toc;		%30sec to save
      fprintf('%s\n',fOut);	%/*}}}*/
    else;
      load(fOut1);
    end;

    clear tmp;tmp=zeros(nx2,ny2);tmp(tide.iwet)=tide.LAT;yc_ref=tmp(1500,:);clear tmp
    clear tmp;tmp=zeros(nx2,ny2);tmp(tide.iwet)=tide.LON;xc_ref=tmp(:,400);clear tmp
    clear tmp;tmp=zeros(nx2,ny2);tmp(tide.iwet)=tide.bathy;D=tmp;clear tmp;
    clear tmp;tmp=zeros(nx2,ny2);tmp(tide.iwet)=tide.mask; mask=tmp;clear tmp;mask(find(mask>0))=1;
    clear AMP;AMP=zeros(nx2,ny2);AMP(tide.iwet)=tide.AMP;
    clear PHA;PHA=zeros(nx2,ny2);PHA(tide.iwet)=tide.PHA;

    lat_ref=25:5:50;for i=1:length(lat_ref);iy_ref(i)=closest(lat_ref(i),yc_ref,1);end;
    lon_ref=-80:5:-40;for i=1:length(lon_ref);ix_ref(i)=closest(lon_ref(i),xc_ref,1);end;

    figure(1);clf;colormap(jet(21));
    mypcolor(1:nx2,1:ny2,AMP');caxis([0 1]);colorbar;hold on;
    [aa,bb]=contour(1:nx2,1:ny2,D',[1.5e3 3.5e3 5e3]);set(bb,'color',.3.*[1 1 1],'linestyle',':');
    [aa,bb]=contour(1:nx2,1:ny2,PHA',0:30:360);set(bb,'color',.9.*[1 1 1],'linewidth',3);hold off;
    shadeland(1:nx2,1:ny2,1-mask',.5.*[1 1 1]);
    set(gca,'Xtick',ix_ref,'Xticklabel',num2str(lon_ref'),...
            'Ytick',iy_ref,'Yticklabel',num2str(lat_ref'));
    xlabel('Longitude [degE]');ylabel('Latitude [degN]');
    title(['SSH' ' tidal Amp+phase, ' strtrim(namet) ' ' tsstr],'interpreter','none');
    set(gca,'dataaspectratio',[1 1 1]);
    fpr=[dirout2 'Eta_' tsstr '_Lwet' num2str(length(tide.iwet)) '_' lower(strtrim(namet)) '.png'];
    set(gcf,'paperunit','inches','paperposition',[0 0 10 10]);print(fpr,'-dpng');
  end;
end;
