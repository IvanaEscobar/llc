%28.Aug.2019: this reads in centered u/v in wet_compact format
clear all;%close all;

define_indices;
get_Etancortide=0;	%1=calculating;0=plotting
dirGrid='/work/03901/atnguyen/Ivana/llc4320/NA_4320x2160x1080x90/GRID/';
if(~exist(dirGrid));
  error('dirgrid not exist');
end;
nx= id.n.x/2;   % 2160
ny= id.n.y;     % 2160
nz= id.n.z;     % 90
nfx= id.nf.x;   % [2160 0 0 0 1080]
nfy= id.nf.y;   % [1080 0 0 0 2160]

deltaT=90;yrStart=2002;moStart=1;daStart=1;hrStart=0;

yc=rdmds([dirGrid  'YC']);yc=reshape(yc,[nx,ny]);
xc=rdmds([dirGrid  'XC']);xc=reshape(xc,[nx,ny]);
acs=rdmds([dirGrid 'AngleCS']);acs=reshape(acs,nx,ny);
asn=rdmds([dirGrid 'AngleSN']);asn=reshape(asn,nx,ny);

%=== full domain indices ====
ix0=1:nx;iy0=1:ny;iz0=1:90;nz=90;Lx=length(ix0);Ly=length(iy0);Lz=length(iz0);
%============================

%=== wet points =======
%load indices
fGrid=[dirGrid 'Index_wet_hfacC_2D.mat'];              	 %C: 3390920
load(fGrid,'ind');%,'i1','i2');%tic;toc;                 %8.7sec
%Lmax=size(ind,1);                                       %C: 264652695 111578238; W: 110767778; S: 110664810
iwet_layer1=ind(:,6);
Lwet_layer1=length(iwet_layer1);        %1952025
generic_layer1=zeros(nx,ny);generic_layer1(iwet_layer1)=iwet_layer1;

%save just wet point for ETAN field:
%klev=1;
%ii=i1(6,klev):i2(6,klev);
%ioffset=(klev-1)*nx*ny;        		%0 for top layer
%iwet_layer1=ind(ii,6)-ioffset;
%Lwet_layer1=length(iwet_layer1);	%1952025
%generic_layer1=zeros(nx,ny);generic_layer1(iwet_layer1)=iwet_layer1;
%=======================

%load(['/work/03901/atnguyen/llc2160/global/matlab/tide_constituent.mat']);
file_constituent=['~atnguyen/matlab/atn_tools/tide_constituent.mat'];
load(file_constituent);
save_as_ASTE=0;
save_as_wet=1;
save_as_compact=0;

%=== set up RunStr ========

%dirRun='/scratch/03901/atnguyen/aste_1080x1260x540x90/run_tides_it0000_pk0001270800/';	%/*{{{*/
%dirRun='/work/03901/atnguyen/llc1080/aste_1080x1260x540x90/';
%dirRun='/nobackupp6/atnguye4/llc2160/global/';
%dirOut='/nobackupp6/atnguye4/llc2160/';						%/*}}}*/
dirRoot='/work/03901/atnguyen/Ivana/llc4320/NA_4320x2160x1080x90/';
if(~exist(dirRoot));
  error('dirRoot not exists');
end;
%RunStr='run_tides_run2_hourly_it0000_pk0001577880';ext='';
%RunStr='run_tidesallOFF_sp1_run2_hourly_it0000_pk0001577880';ext='_ls5';
%RunStr='run_tidesallOFF_winds49hr_run2_hourly_it0000_pk0001577880';ext='';
RunStr='run_c67h_tidal_bc_pk0000000001';ext='';
dirRun=[dirRoot RunStr ext '/'];if(~exist(dirRun));error('dirRun not exist');end;
dirOut=[dirRun 'Mean/'];if(exist(dirOut)==0);mkdir(dirOut);end;

vvar={'ETANcor'};%,'W'};

%======= START ==============
if(get_Etancortide==1);	%otherwise, we only analyze (get amp+phase) and plot fig
%/*{{{*/ %[calc M_tide_k]
  %flist=dir([dirRun 'diags/' vvar{1} '/' vvar{1} '*.data']);%8760, now hardcode to save time
  nt=1488;%length(flist);			%8760 (or 720 if run only 1 mo)
%note: should break into 12-months to get a seasonal cycle instead of do a full 1-yr?
%for 2d field, we can afford to test both
  
  post_06apr2015 = 1;

%pick a point to keep time-series for post-testing
  get_PointA=1;	%just pick a point in NA domain where bathy is deep: 
% [381,1861] this is on face5
  if(get_PointA==1);
%need to get index for pointA in wet compact:
    ix=381;iy=1861;iz=1;
    PointA.ind=generic_layer1(ix,iy,iz);		%4017981, global index <-- important if start out full compact
    PointA.ind_wet=find(iwet_layer1==PointA.ind);	%2766078, index within wet points , important if read in only wet point
    PointA.ijk=[ix iy iz];
    PointA.Lat=yc(ix,iy,iz);%38.2063 , same as yc(PointA.ind) = yc_wet(PointA.ind_wet) , where yc_wet=yc(iwet_layer1);
    PointA.Lon=xc(ix,iy,iz);%-50.4896
    PointA.deltaT=deltaT;   %90sec in data
    PointA.RefDate=[2002 10 08 0 30 0]; %ts2dte(268800,90,2002,1,1), data: niter0=268800, deltaT=90, data.cal: startDate_1=20020101, startDate_2=000000,
  end;

%precompute matrix G for nt timesteps for 9 major tide components for time = 1:1:nt hours, technically it's time-0.5hr (centered)
%load in 35 tidal components got from t_tide
  %load(['/nobackupp6/atnguye4/llc2160/global/matlab/tide_constituent.mat']);
  %load(['/work/03901/atnguyen/llc2160/global/matlab/tide_constituent.mat']);
  load(file_constituent);

  dt=1;
  ii=[0:nt-1]+1;
  N=length(ii);
  if(get_PointA==1);
    PointA.timeindex=ii;
  end;
  
  if(~post_06apr2015);
    itide=[15,17,14,8,6,24,31,27,26];		%grab 9 most important const.	%/*{{{*/
    w=tide_constituent.freq(itide);		%M2,S2,N2,K1,O1,M4,M6,S4,MS4
    M=length(itide);
    t=ii-1;									%/*}}}*/
  else;
  %centered t to facilitate comparing with t_tide
    %t=dt*([1:nobs]'-ceil(nobsu/2));  <--- this is exact time used for Gmatrix in t_tide
  
    nobs=length(ii);
    nobsu=nobs-rem(nobs-1,2);		%nobsu=nobs if length(ii) is odd
    t=dt*([1:nobs]'-ceil(nobsu./2));	%time vector for entire timeseries, center @ midpt [hr]
    nameu=['Q1  ';'O1  ';'K1  ';'N2  ';'M2  ';'S2  '];
    nameu1={'Q1  ';'O1  ';'K1  ';'N2  ';'M2  ';'S2  '};
    M=size(nameu,1);
    for iM=1:M
      itide(iM)=strmatch(nameu(iM,:),tide_constituent.name);
    end;
    w=tide_constituent.freq(itide);		% Q1,O1,K1,N2,M2,S2
  end
  if(get_PointA==1);
    PointA.w=w;			%/*{{{*/
    PointA.nameu=nameu;
    PointA.nameu1=nameu1;
    PointA.t=t;			%/*}}}*/
  end;

%now pretend read in data one at a time:
  t1=clock;
  G=nan(N,2*M+1);				% nt x 2*M+1 [1488 x 13]
  G(:,1)=1;
%prior to 6.apr.2015, this is what i used:
  if(post_06apr2015==0);
    for iM=1:M;
      G(:,(iM-1)*2+2)=sin(2.*pi.*w(iM).*t(1:N));
      G(:,(iM-1)*2+3)=cos(2.*pi.*w(iM).*t(1:N));
    end;
  else;
%post 6.apr.2015: modify to this to facilitate merging with t_tide:
%the way t_tide is done:
  %tc=[ones(length(t),1) cos((2*pi)*t*fu') sin((2*pi)*t*fu') ];
    for iM=1:M;
      G(:,0*M+1+iM)=cos(2.*pi.*w(iM).*t(1:N));
      G(:,1*M+1+iM)=sin(2.*pi.*w(iM).*t(1:N));
    end;
  end;
  t2=clock;fprintf('done constructing G, clock time: %f\n',etime(t2,t1));
  t1=clock;
  BIGG=G'*G;BIGG=pinv(BIGG);BIGG=BIGG*G';		%2*M+1 x nt [13 x 1488]
  t2=clock;fprintf('done constructing BIGG, clock time: %f\n',etime(t2,t1));
  %fOut=[dirOut 'BIGG_matrix.mat'];save(fOut,'BIGG');

%first: deal with real signal
%for u+iv, as simple as that:
  for ivar=1:1;%size(vvar,2)
    %dirIn=[dirRun 'diags/ETANcor/'];
    %flist=dir([dirIn vvar{ivar} '.*.data']);
    dirIn=[dirRun 'diags/state_2d_hourly_Cwet/'];%ETANcor/'];
    flist=dir([dirIn 'state_2d_hourly_*.*.data']);
    flist=flist(ii);L=length(flist);
    if(ivar==1);
      idot=find(flist(1).name=='.');idot=idot(1)+1:idot(2)-1;
      for k=1:L
        ts(k)=str2num(flist(k).name(idot));
      end
      if(get_PointA==1);
        PointA.ts=ts';
        %WRONG: PointA.startTime=datevec(ts2dte(ts(1),PointA.deltaT,PointA.RefDate(1),PointA.RefDate(2),PointA.RefDate(3)));
        %PointA.startTime=datevec(ts2dte(ts(1),PointA.deltaT,yrStart,moStart,daStart));%if use ts2dte, MUST HOOK UP to 2002/1/1
        tmp=datevec(ts2dte(ts(1),PointA.deltaT,yrStart,moStart,daStart));%if use ts2dte, MUST HOOK UP to 2002/1/1
        PointA.startTime=[tmp(1:3) 0 30 0];%
      end;
    end;
    fprintf('%s ',vvar{ivar});fprintf('Length: %i\n',L);
    istart=1;iend=N;

% initializing:
    ta=clock;
  
    if(save_as_wet);
      M_tide_k=zeros(Lwet_layer1,2*M+1);			%[Lwet_layer1 2*M+1]
    elseif(save_as_ASTE);
      M_tide_k=zeros(2*nx,nfy(1)+nfy(3)+nfx(4),2*M+1);	%[2*nx nfy(1)+nfy(3)+nfx(4) 2*M+1]
    else;
      M_tide_k=zeros(Lx,Ly,2*M+1);			%[Lx Ly 2*M+1]
    end;
    tb=clock;fprintf('done initializing, time: %f\n',etime(tb,ta));
  
    for it=istart:iend;

      clear FF

      t1(it,:)=clock;
      %fE=[dirRun '/diags/ETANcor/' flist(it).name];
      %FF=readbin(fE,[nx ny]);%tic;toc;0.14sec %[nx x ny]);
      %FF=FF(iwet_layer1);	%[Lwet_layer1 x 1]
      fE=[dirRun 'diags/state_2d_hourly_Cwet/' flist(it).name];
      FF=readbin(fE,[Lwet_layer1 1]);
      %fid=fopen(fE,'r','b');%skip=Lwet_layer1*12;		%x12 because there are 12 fields before ETANcor
      %if(fseek(fid,skip*4,'bof')<0), error('past end of file'); end
      %FF=fread(fid,Lwet_layer1,'real*4');fclose(fid);		%size [Lwet_layer1 x 1]

      if(get_PointA==1);
        eval([vvar{ivar}   '_ptA(it)=FF(PointA.ind_wet);']);%ix,iy);']);
      end;

      t2(it,:)=clock;

      clear temp temp1;
      temp=BIGG(:,it);							%[2*M+1 1] [13 x 1]

      if(save_as_wet);
        temp1=squeeze(reshape(FF(:)*temp(:).',Lwet_layer1,1,[]));%tic;toc;%[Lwet_layer1 2*M+1] , 0.22sec
      elseif(save_as_ASTE);                         
        temp1=reshape(FF(:)*temp(:).',2*nx,nfy(1)+nfy(3)+nfx(4),[]);	%[2*Lx nfy(1)+nx+nfx(4) 2*M+1]
      else;
        temp1=reshape(FF(:)*temp(:).',Lx,Ly,[]);			%[Lx Ly 2*M+1]
      end;
      M_tide_k=M_tide_k+temp1;

      t3(it,:)=clock;
      if(mod(it,60)==0|it==iend);
        fprintf('%i %4.1f %4.1f ',[it etime(t2(it,:),t1(it,:)) etime(t3(it,:),t1(it,:))]);
      end

      if(mod(it,732)==0|it==iend);
        %fprintf('\n');
        %fprintf('saving: ');
        ta=clock;
% the "p" is for prime = baroclinic
        if(save_as_wet);
          fOut=[dirOut vvar{ivar} '_' myint2str(ts(1),10) '_' myint2str(ts(end),10) '_Lwet' num2str(Lwet_layer1) '.mat'];
        elseif(save_as_compact);
          fOut=[dirOut vvar{ivar} '_' myint2str(ts(1),10) '_' myint2str(ts(end),10) '.mat'];
        elseif(save_as_ASTE);
          fOut=[dirOut vvar{ivar} 'ASTE' '_' myint2str(ts(1),10) '_' myint2str(ts(end),10) '.mat'];
        end;
        save(fOut,'M_tide_k','it');fprintf('%s\n',fOut);
        tb=clock;fprintf('%i %4.1f ',etime(tb,ta));
        fprintf('\n');
      end%mod720
    end;%it
    fprintf('\n');

    if(get_PointA==1);
      eval(['PointA.' vvar{ivar}   '=' vvar{ivar} '_ptA;']);
    end;
  end
  if(get_PointA==1);	%/*{{{*/ [get_pointA]
    if(save_as_wet);	
      fOutPtA=[dirOut 'PointA_' vvar{ivar} '_' myint2str(ts(1),10) '_' myint2str(ts(end),10) '_wet.mat'];
    elseif(save_as_compact);	
      fOutPtA=[dirOut 'PointA_' vvar{ivar} '_' myint2str(ts(1),10) '_' myint2str(ts(end),10) '.mat'];
    elseif(save_as_ASTE);
      fOutPtA=[dirOut 'PointA_' vvar{ivar} 'ASTE_' myint2str(ts(1),10) '_' myint2str(ts(end),10) '.mat'];
    end;
    save(fOutPtA,'PointA');fprintf('%s\n',fOutPtA);
  end;			%/*}}}*/ [get_pointA]
%/*}}}*/ %[calc M_tide_k]
%================================================================
%================================================================
%================================================================
else;%not.get_Etancortide, then we analyze + plot fig
					%/*{{{*/ [analyze+plot_fig]
  yc=rdmds([dirGrid  'YC']);yc=reshape(yc,nx,ny);yc(find(yc==0))=nan;
  xc=rdmds([dirGrid  'XC']);xc=reshape(xc,nx,ny);xc(find(xc==0))=nan;
  d =rdmds([dirGrid  'Depth']);d=reshape(d,nx,ny);d=abs(d);
  hf=readbin([dirGrid 'hFacC.data'],[nx,ny,1]);hf(find(hf<1))=nan;
  if(save_as_ASTE);
    yc=get_aste_tracer(yc,nfx,nfy);	yc1=yc;
    xc=get_aste_tracer(xc,nfx,nfy);	xc1=xc;
    d =get_aste_tracer(d,nfx,nfy);	d1 =d;
    hf=get_aste_tracer(hf,nfx,nfy);	hf1=hf;
  end;
  if(save_as_wet);
    yc1=get_aste_tracer(yc,nfx,nfy);	yc=yc(iwet_layer1);
    xc1=get_aste_tracer(xc,nfx,nfy);	xc=xc(iwet_layer1);
    d1 =get_aste_tracer(d,nfx,nfy);	d =d(iwet_layer1);
    hf1=get_aste_tracer(hf,nfx,nfy);	hf=hf(iwet_layer1);
  end;

  addpath('~/matlab/Tidal_ellipse_v2/');
  tsstr='0000268840_0000328320';
  if(save_as_wet);
    fname=[dirRun 'Mean/' vvar{1} '_' tsstr '_Lwet' num2str(Lwet_layer1) '.mat'];
  elseif(save_as_compact);
    fname=[dirRun 'Mean/' vvar{1} '_' tsstr '.mat'];
  elseif(save_as_ASTE);
    fname=[dirRun 'Mean/' vvar{1} 'ASTE_' tsstr '.mat'];
  end;
  load(fname,'M_tide_k','it');			%loading in here, 14sec to load

  if(~save_as_ASTE&~save_as_wet);M_tide_k=get_aste_tracer(M_tide_k,nfx,nfy);end;

  idot=find(fname=='.');
  %ntot=it/2;%768/2;
  %ttime=-ntot:1:ntot-1;
  if(save_as_wet);
    fPointA=[dirRun 'Mean/' 'PointA_' vvar{1} '_' tsstr '_wet.mat'];
  elseif(save_as_compact);
    fPointA=[dirRun 'Mean/PointA_' vvar{1} '_' tsstr '.mat'];
  elseif(save_as_ASTE);
    fPointA=[dirRun 'Mean/PointA_' vvar{1} 'ASTE_' tsstr '.mat'];
  end;
  load(fPointA);	%PointA

%re-saving PointA because PointA.startTime is wrong:
  if(PointA.startTime(1)>2020);
    %PointA.startTime=datevec(ts2dte(PointA.ts(1),PointA.deltaT,yrStart,moStart,daStart));%if use ts2dte, MUST HOOK UP to 2002/1/1
    tmp=datevec(ts2dte(PointA.ts(1),PointA.deltaT,yrStart,moStart,daStart));%if use ts2dte, MUST HOOK UP to 2002/1/1
    PointA.startTime=[tmp(1:3) 0 30 0];
    save(fPointA,'PointA');
  end;
%re-saving PointA if missing longitude
    if(~isfield(PointA,'Lon'));
      PointA.Lon=xc(PointA.ind_wet);	%126.3123
      save(fPointA,'PointA');
    end;

  %startdate=datenum(PointA.startTime);%this startdate is wrong because mistakenly hooking it to 2014/1/1 instead of 2002/1/1
  %startdate=datenum(ts2dte(PointA.ts(1),deltaT,yrStart,moStart,daStart));	%datevec(startdate): 2014 1 1 1 0 0
%after talking with Laurie, must start at the exact time of the first record, which is 1/2 hour into 2014/1/1 
%for     diurnnal = 1 cycle per 360deg (per 24 hr), if off by 1 hr, that's off by 360/24 = 15deg in phase
%for semidinurnal = 2 cycle per 360deg (per 24 nr), if off by 1 hr, that's off by 360/12 = 30deg in phase
    %tmp=datevec(startdate);
    %starttime=datenum(tmp(1:3));						%datevec(starttime): 2014 1 1 0 0 0
    tmp=PointA.startTime;							%datevec(starttime): 2014 1 1 0 30 0
    starttime=datenum(tmp);							%datevec(starttime): 2014 1 1 0 30 0
    nobs=length(PointA.t);

%M2: Principal lunar semidiurnal
%S2: Principal solar semidiurnal
%K1: Lunar diurnal
%O1: Lunar dinurnal

  for itide=1:4;		%/*{{{*/ [itide]

    %    if(itide==1);namet='M2  ';llim=[-.005,1.2];elseif(itide==2);namet='S2  ';llim=[-.005,.45];
    %elseif(itide==3);namet='K1  ';llim=[-.005,.45];elseif(itide==4);namet='O1  ';llim=[-.005,.2]; end;
        if(itide==1);namet='M2  ';llim=[-.005,1];elseif(itide==2);namet='S2  ';llim=[-.005,1];
    elseif(itide==3);namet='K1  ';llim=[-.005,1];elseif(itide==4);namet='O1  ';llim=[-.005,.1]; end;

    itide1=strmatch(namet,PointA.nameu);
    tic;[AMP,PHA]=func_get_3d_ap_mod2(M_tide_k,namet,1,nobs,starttime,yc);toc;%6sec

    AMP=squeeze(AMP);		%[Lwet_layer1 1]
    PHA=squeeze(PHA);		%[Lwet_layer1 1]

%saving
    fOut=[fname(1:idot-1) '_' strtrim(namet) '_AMP_PHA' fname(idot:end)]
    clear tide
    tide.name=namet;
    tide.freq=PointA.w(itide1);
    tide.RefDate=PointA.RefDate;
    tide.startTime=PointA.startTime;
    tide.ts=PointA.ts;
    tide.LAT=yc;
    tide.LON=xc;
    tide.bathy=d;
    tide.mask=hf;
    if(save_as_wet);
      tide.ix=iwet_layer1;%1:Lwet_layer1;
      tide.iy=[];
    else;
      tide.ix=1:nx;%ix;
      tide.iy=1:ny;%iy;
    end;
    tide.AMP=AMP;
    tide.PHA=PHA;
    tic;save(fOut,'tide');toc;		%30sec to save
    fprintf('%s\n',fOut);

%plotting
    plot_fig=1;
    if(plot_fig==1);			%/*{{{*/ [plot_fig]

%note: for plotting, need to understand what happens to the phase if we rotate face3... so for now
%leave in compact format and simply convert to aste_faces, thus leaving the orientation undisturbed.
%For now, we can easily merge face3+4 , but need to understand the discontinuity between face1 to 3.
%(can we simply add in a 90deg? (we made a 90rot clockwise to get org face3 into aste)
      if(save_as_wet);	%need to expand to global
        clear i j
        amp0=AMP;pha0=PHA;
        clear AMP PHA 
        AMP=nan(nx,ny);AMP(iwet_layer1)=amp0;	AMP=get_aste_tracer(AMP,nfx,nfy);%tic;toc;	%0.1sec
        PHA=nan(nx,ny);PHA(iwet_layer1)=pha0;	PHA=get_aste_tracer(PHA,nfx,nfy);%tic;toc;	%0.1sec
      end;
      if(save_as_ASTE|save_as_wet);
        ixp=5:3750;iyp=17:1056; N=15;
      else;
        ixp=1:nx;iyp=1:nfy(1)+nfy(5);	N=15;
      end;
      ix=ixp(1):N:ixp(end);iy=iyp(1):N:iyp(end);
      [iyq,ixq]=meshgrid(iy,ix);

      yc_ref=yc1(2000,iyp);lat_ref=25:5:45;for i=1:length(lat_ref);iy_ref(i)=closest(lat_ref(i),yc_ref,1);end;
      xc_ref=xc1(ixp,600); lon_ref=-75:5:-5;for i=1:length(lon_ref);ix_ref(i)=closest(lon_ref(i),xc_ref,1);end;

      tmp1=smooth2a(d1(ixp,iyp),3);tmp2=smooth2a(PHA(ixp,iyp),3);
      figure(2);clf;colormap(jet(21));
      imagescnan1(ixp,iyp,AMP(ixp,iyp)');caxis(llim);colorbar;hold on;
      [a,b]=contour(ixp,iyp,tmp1',[1500,3500,4500]);set(b,'color',.3.*[1,1,1],'linestyle',':');
      [a,b]=contour(ixp,iyp,tmp2',[0:15:360]);set(b,'color',.9.*[1,1,1],'linewidth',2);
      shadeland(ixp,iyp,isnan(hf1(ixp,iyp,1))',.7.*[1 1 1]);
      set(gca,'Xtick',ix_ref,'Xticklabel',num2str(lon_ref'),'Ytick',iy_ref,'Yticklabel',num2str(lat_ref'));
      xlabel('Longitude [degE]');ylabel('Latitude [degN]');
      hold off;title(['SSH' ' tidal Amp+phase, ' strtrim(namet) ' ' tsstr],'interpreter','none');
      set(gca,'dataaspectratio',[1 1 1]);
      figure(2);set(gcf,'paperunits','inches','paperposition',[0 0 17 6]);
      if(save_as_ASTE|save_as_wet);set(gcf,'paperunits','inches','paperposition',[0 0 17 6]);end;
      if(save_as_wet);
        fpr=[dirRun 'Mean/' vvar{1} '_' tsstr '_Lwet' num2str(Lwet_layer1) '_' lower(strtrim(namet)) '_0.png'];
      elseif(save_as_compact);
        fpr=[dirRun 'Mean/' vvar{1} '_' tsstr '_' lower(strtrim(namet)) '_0.png'];
      elseif(save_as_ASTE);
        fpr=[dirRun 'Mean/' vvar{1} 'ASTE_' tsstr '_' lower(strtrim(namet)) '_0.png'];
      end;
      figure(2);saveas(gcf,fpr,'png');

    end;					%/*}}}*/ [plot_fig]

  end; %itide				%/*}}}*/ [itide]
					%/*}}}*/ [analyze+plot_fig]
end;%analyze + plot_fig
