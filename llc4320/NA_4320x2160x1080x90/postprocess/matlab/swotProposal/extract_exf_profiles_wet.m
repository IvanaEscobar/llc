clear all;
define_indices;
addpath('~atnguyen/matlab/MITprof_toolbox/');
addpath('~atnguyen/matlab/MITprof_toolbox_extra/');
%% Setting Directories and Domain Info: Escobar's NA setup
dirWork='/work/05427/iescobar/stampede2/llc/llc4320/NA_4320x2160x1080x90/';
dirScratch='/scratch/05427/iescobar/llc/llc4320/NA_4320x2160x1080x90/run_c67h_tidal_bc_pk0000000001/';
dirGrid=[dirWork 'GRID/'];

%dirRoot='/work/03901/atnguyen/Ivana/llc4320/NA_4320x2160x1080x90/';
%dirRun=[dirRoot 'run_c67h_tidal_bc_pk0000000001/'];
dirOut =[dirScratch 'extract_hourly/']; if(~exist(dirOut)); mkdir(dirOut); end
%dirGrid=[dirRoot 'GRID/'];
%need to reserve variable ind for loading wet_indices

deltaT=90;yrstart=2002;mostart=1;dastart=1;	

%% =====================================================================================
%===================================== STEP 1 ========================================
%=====================================================================================
%nothing here;  if need to define compact point pp, edit get_wet_ind_single_section.m
Lprofpoint=155;section_name='_m73p9_cluster';
fprofpoint=[dirOut 'unique_profpoint_L' num2str(Lprofpoint) section_name 'Section.bin'];
if(~exist(fprofpoint))
  error('run get_wet_ind_single_section.m to get a set of profpoint first');
else
  pp=readbin(fprofpoint,[1 Lprofpoint]);
%=== wet points =======
%load indices
  fGrid=[dirGrid 'Index_wet_hfacC_2D.mat'];                  %
  load(fGrid,'ind');ind2d=ind;Lwet_layer1=size(ind2d,1);clear ind
  
  fGrid=[dirGrid 'Index_wet_hfacC.mat'];                  %
  load(fGrid,'ind','i1','i2');%tic;toc;                   %8.7sec
  indC=ind;i1C=i1;i2C=i2;
  LmaxC=size(indC,1);                                     
  clear ind i1 i2
end
  
%% =====================================================================================
%===================================== STEP 1a =======================================
%=====================================================================================
step1a=1;%get/load in ind_wet
if(step1a)
%/*{{{*/ step1a
  Lprofpoint=155;section_name='_m73p9_cluster';
  findex=[dirOut '../ind_wet_L' num2str(Lprofpoint) section_name 'Section.mat'];
  if(~exist(findex))
    error('run get_wet_ind_single_section.m first to get correction section index');
  else
    load(findex,'indcompact','indwet','indprof');
  end
%/*}}}*/ step1a
end

%% =====================================================================================
%===================================== STEP 2 ========================================
%=====================================================================================
step2=1;
if(step2)
  %fldList1={...			%/*{{{*/ [step2]
  % 'EXFpreci','EXFevap' ,'EXFroff' ,'EXFempmr','EXFswdn' ,'EXFlwdn' ,'EXFswnet','EXFlwnet',...
  % 'EXFqnet' ,'EXFatemp','EXFaqh'  ,'EXFtaux' ,'EXFtauy' ,'EXFuwind','EXFvwind','EXFpress',...
  % 'EXFhs'   ,'EXFhl'   ,'EXFsnow' ,'EXFtidep'};
  %nf1=size(fldList1,2);if1c=[1:11 16:20];if1c1=[12,13,14,15];
  %fldList2={...
  % 'ETAN'    ,'SIarea'  ,'SIheff'  ,'SIhsnow' ,'DETADT2' ,'PHIBOT'  ,'sIceLoad','SIatmQnt',...
  % 'SIatmFW' ,'oceQnet' ,'oceFWflx','oceTAUX' ,'oceTAUY' ,'ADVxHEFF','ADVyHEFF','DFxEHEFF',...
  % 'DFyEHEFF','ADVxSNOW','ADVySNOW','DFxESNOW','DFyESNOW','SIuice'  ,'SIvice'  ,'ETANSQ'  ,'ETANcor'};
  %nf2=size(fldList2,2);if2c=[1:11,24:25];if2c1=[12,13,14,15,18,19,22,23];
  fldList2={'ETAN'};nf2=1;if2c=1;


  %get wet indices for top layer only
  for j=1:length(pp)
      ij=find(indprof==pp(j));indwet1(j)=indwet(ij(1));
  end

%=======================

  %flistexfc=dir([dirRun 'diags/exf_zflux_hourly_Cwet/exf_zflux_hourly_*.data']);Lfile=length(flistexfc);
  %flistexfc1 =dir([dirRun 'diags/exf_zflux_hourly_UVcwet/exf_zflux_hourly_c*.data']);
  fliststac  =dir([dirScratch 'diags/state_2d_hourly_Cwet/state_2d_hourly_*.data']);Lfile=length(fliststac);
  %fliststac1 =dir([dirRun 'diags/state_2d_hourly_UVcwet/state_2d_hourly_c*.data']);
  idot=find(fliststac(1).name=='.');idot=idot(1)+1:idot(end)-1;

%loop once to get time
  fsave=[dirOut '../time_step.mat'];
  if(~exist(fsave))
    tt=zeros(Lfile,6);
    for i=1:Lfile;
      ts=str2num(fliststac(i).name(idot));	
      tmp=datevec(ts2dte(ts,deltaT,yrstart,mostart,dastart));
      tt(i,1:4)=tmp(1:4);tt(i,5)=ts;tt(i,6)=datenum(tmp);
    end;
    save(fsave,'tt');
  else;
    load(fsave,'tt');
  end;

  strout=[sprintf('%10.10i',tt(1,5)) '_' sprintf('%10.10i',tt(end,5))];

  %for iloop=1:1;%serious memory: 49GB
  %    if(iloop==1);str='exf_zflux_hourly_Cwet';  iff=if1c; fldList=fldList1;flist=flistexfc;
  %elseif(iloop==2);str='exf_zflux_hourly_UVcwet';iff=if1c1;fldList=fldList1;flist=flistexfc1;
  %elseif(iloop==3);str='state_2d_hourly_Cwet';   iff=if2c; fldList=fldList2;flist=fliststac;
  %elseif(iloop==4);str='state_2d_hourly_UVcwet'; iff=if2c1;fldList=fldList2;flist=fliststac1;end;
  str='state_2d_hourly_Cwet';   iff=if2c; fldList=fldList2;flist=fliststac;

  vv=nan(length(pp),length(iff),Lfile);

  fout=[dirOut fldList{iff(1)} '.' strout '.bin'];
  if(exist(fout));
    for j=1:length(iff);
      fout=[dirOut fldList{iff(j)} '.' strout '.bin'];clear a;a=readbin(fout,[length(pp),Lfile]);
      vv(:,j,:)=permute(a,[1 3 2]);fprintf('%s\n',fout);
    end;
    tmp=sum(a,1);inan=find(isnan(tmp)==1);if(length(inan)>0);istart=inan(1);else;istart=length(flist)+1;end;%-10
  else;
    istart=1;
  end;

  fprintf('istart: %i\n',istart);

  t0=clock;
  if(istart<=length(flist));
  for ifile=istart:length(flist)				%2.27sec if use rdmds, 1.73sec if use readbin;
    %a=zeros(nx*ny,length(if1c));a(indC([i1C(6,1):i2C(6,1)]',6),:)=tmp;exfc(:,:,ifile)=a(pp,:);
    tmp=readbin([dirScratch 'diags/' str '/' flist(ifile).name],[Lwet_layer1 length(iff)]);
    vv(:,:,ifile)=tmp(indwet1,:);

    if(mod(ifile,240)==0|ifile==length(flist));
      for j=1:length(iff);
        tmp=squeeze(vv(:,j,:));fout=[dirOut fldList{iff(j)} '.' strout '_1.bin'];writebin(fout,tmp);
      end;
      fprintf('\n');
    end;

    if(mod(ifile,24)==0);t1=etime(clock,t0);fprintf('%i %f ',[ifile t1]);t0=clock;end;
  end;
  end;%istart<=length(flist)
%				/*}}}*/ [step2] 
end;

%% =====================================================================================
%===================================== STEP 2P =======================================
%=====================================================================================
step2p=0;	%extract 3d, need to to double check, for now, 1 month is enough to check
if(step2p);
%/*{{{*/ [step2p]

 fldList3={'THETA','SALT','UVELMASSc','VVELMASSc'};nf3=size(fldList3,2);%,'WVELMASSc'
 varw={'C','C','C','C'};%'W','S','C'};

 for ivar=1:4;

  flist=dir([dirScratch 'diags/' fldList3{ivar} '_wet/' fldList3{ivar} '_*.*.data']);%tic;toc; %4.5sec

  if(length(flist)==0);fprintf('note %s missing, skip\n',fldList3{ivar});
  else;
  idot=find(flist(1).name=='.');idot=idot(1)+1:idot(end)-1;

%loop once to get time
  fsave=[dirOut '../time_step.mat'];
  if(~exist(fsave));
    tt=zeros(length(flist),6);		%/*{{{*/
    for i=1:length(flist);
      ts=str2num(flist(i).name(idot));	
      tmp=datevec(ts2dte(ts,deltaT,yrstart,mostart,dastart));
      tt(i,1:4)=tmp(1:4);tt(i,5)=ts;tt(i,6)=datenum(tmp);
    end;
    save(fsave,'tt');			%/*}}}*/
  else;
    load(fsave,'tt');
  end;

  strout=[sprintf('%10.10i',tt(1,5)) '_' sprintf('%10.10i',tt(end,5))];
  
  %for now , take upper 550m (1:40)
  iz=1:87;						% %0-5682m , deepest in Arctic Depth: 5501m
  state=nan(length(pp),length(iz),length(tt));		%serious memory: iz 1:86 -> 242GB, 1:40: 121GB, for 162pts: 1GB
  if(get_section);
    mskstate=nan(length(iz),length(pp));		%correct, iz first dim
    %mskstate_error=nan(length(pp),length(iz));		%incorrect, iz 2nd dim
    for i=1:length(pp);
      ij=find(indprof==pp(i));mskstate(1:length(ij),i)=1;
      %ij=find(indprof==pp(i));mskstate_error(i,1:length(ij))=1;
    end;
    ind_state=find(mskstate==1);clear mskstate;
    %ind_state_error=find(mskstate_error==1);clear mskstate_error;
  end;
  
  indfile=[dirOut 'ind_ts_avail_' fldList3{ivar} '.mat'];
  if(exist(indfile));
    load(indfile,'ind_ts_avail');

    fout=[dirOut fldList3{ivar} '_k' sprintf('%3.3i',iz(1)) '.' strout '.bin'];
    if(exist(fout));
      for j=length(iz):-1:1;	%need to sum from bottom up because at the bottom there's no data so always get nan
        clear a;
        fout=[dirOut fldList3{ivar} '_k' sprintf('%3.3i',iz(j)) '.' strout '.bin'];a=readbin(fout,[length(pp),length(tt)]);
        state(:,j,:)=permute(a,[1 3 2]);%fprintf('%s\n',fout);
      end;
      tmp=sum(a,1);inan=find(isnan(tmp)==1);if(length(inan)>0);istart=inan(1);else;istart=length(flist)+1;end;%-10
      %there is a potential the ind_ts_avail were saved but we have not written out the files, so need to reset ind_ts_avail:
      clear ij;ij=find(ind_ts_avail(:)==1&isnan(tmp(:))==1);
      if(length(ij)>0);ind_ts_avail(ij)=0;end;clear ij;
    else;
      istart=1;
      ind_ts_avail=zeros(length(tt),1);
    end;
  else;
    istart=1;
    ind_ts_avail=zeros(length(tt),1);
  end;

  fprintf('istart: %i\n',istart);

  t0=clock;
  if(istart<=length(flist));
  for ifile=istart:length(flist);

    ts=str2num(flist(ifile).name(idot));
    i_ts=find(tt(:,5)==ts);

    if(ind_ts_avail(i_ts)==0);
      ind_ts_avail(i_ts)=1;

      if(get_single_profile);
        ain=readbin([dirScratch 'diags/' fldList3{ivar} '_wet/' flist(ifile).name],[1 LmaxC]);%tic;toc;	%3.2sec
        %aout=zeros(nx,ny,nz);aout(ind(:,6))=ain;aout=aout(:,:,iz);aout=reshape(aout,nx*ny,length(iz));%tic;toc;%4.5sec
        %state(:,:,i_ts)=aout(pp,:);
        %tic;
        for j=1:length(pp);
          l=length(indwet{j});
          state(j,1:l,i_ts)=ain(indwet{j});
        end;
        %toc;
      elseif(get_section);	%can even save time here because we know the max indwet
        ain=readbin([dirScratch 'diags/' fldList3{ivar} '_wet/' flist(ifile).name],[1 max(indwet)]);
        %tmp_error=nan(length(pp),length(iz));tmp_error(ind_state_error)=ain(indwet);
        tmp=nan(length(iz),length(pp));tmp(ind_state)=ain(indwet);
        state(:,:,i_ts)=tmp';	%note the prime
      end;

      if(mod(ifile,240)==0|ifile==length(flist));
        for j=1:length(iz);
          tmp=squeeze(state(:,j,:));
          fout=[dirOut fldList3{ivar} '_k' sprintf('%3.3i',iz(j)) '.' strout '.bin'];writebin(fout,tmp);
        end;
        save(indfile,'ind_ts_avail');
        fprintf('\n');%tic;toc; 375sec to write all 40lev --> ~9.3sec / lev (total 6min15sec)
      end;

      if(mod(ifile,24)==0);t1=etime(clock,t0);fprintf('%i %f ',[ifile t1]);t0=clock;end;
      
    end;
  end;
  end;%istart<=length(flist)
  end;%length(flist)>0
 end;%ivar
%				/*}}}*/ [step2p] 
end;

%% =====================================================================================
%===================================== STEP 3  =======================================
%=====================================================================================
step3=0;
if(step3);
			%/*{{{*/ [step3]
%note after checking: there's a 1hr offset between first rec of prof and 1st rec of model's 
%EXF and state fields, again, this is simply because the model saves the hourly avg as the 
%"LAST" time-step -> onto the next hour to give avg of the last hr.
%So, it's best to just subtract 1-hr from tt(:,6): tt(1,6)-1/24 = a0.prof_date(1) = 735600
  load([dirOut 'time_step.mat']);
  nt=8760;	%number of hours in 1 yr (365 days)
  tt(:,6)=tt(:,6)-1/24;

%now we can simply get the t_slice that fits into each .nc file:
%for the virtual NABOS moorings, we know time is continuous, so it's very easy
%to just get beginning at end of time:

%now read in the list of actual aste_compact_prof_point which we used to extract exf:
  tmp=dir([dirOut 'unique_profpoint_L*.bin']);L=tmp.bytes/4;
  pp_aste=readbin([dirOut tmp.name],[L 1]);

  %now loop through exf and state_2d
  flist0=dir([dirOut '*.bin']);ind0=zeros(1,length(flist0));
  for i=1:length(flist0);
    if(flist0(i).bytes/4/L/nt==1);ind0(i)=1;end;
  end;
  ind0=find(ind0==1);
  flist0=flist0(ind0);
  jdot=find(flist0(1).name=='.');tsstr=flist0(1).name(jdot(1)+1:jdot(2)-1);

%how much memory do we have? can we read in ALL the .nc files?
%first read in prof files, get global prof_point as well as aste_compact_prof_point

%also: we just need some EXF and some state, not ALL
  varstr={'EXFpreci','EXFevap' ,'EXFroff' ,'EXFempmr','EXFqnet' ,'EXFatemp','EXFtaux' ,...
          'EXFtauy' ,'EXFuwind','EXFvwind','EXFpress','EXFhs'   ,'EXFhl'   ,'EXFtidep',...
          'ETAN'    ,'SIarea'  ,'SIheff'  ,'SIhsnow' ,'PHIBOT'  ,'sIceLoad','oceQnet',...
          'oceFWflx','oceTAUX' ,'oceTAUY' ,'SIuice'  ,'SIvice'  ,'THETA_k004','THETA_k005'};

  flist=dir([dirRun0 '*.nc']);
  for ifile=1:length(flist);
    clear a0
    idot=find(flist(ifile).name=='.');
    a0=MITprof_load([dirRun0 flist(ifile).name]);
    fprofpoint=[dirRun0 flist(ifile).name(1:idot-1) '_profpointASTE.mat'];load(fprofpoint,'prof_point','prof_point_aste_compact');
    it_slice=find(tt(:,6)>=a0.prof_date(1)&tt(:,6)<=a0.prof_date(end));	%745 hours, why such an odd number?

    %note there are 190 unique data pts, but only 155 unique prof_point
    %clear pp;lat=unique(a0.prof_lat);lon=a0.prof_lon(1);for i=1:length(lat);ii=find(a0.prof_lat==lat(i));pp(i)=a0.prof_point(ii(1));end %190

    a0.prof_point_astec_unique=prof_point_aste_compact;
    a0.prof_point_unique      =prof_point;		%restore because the order of prof_point_aste_compact is tied to prof_point

%cycle through once to define size
    for jvar=1:size(varstr,2);
      a0.(varstr{jvar})=nan(a0.np,1);
    end;

    for jvar=1:size(varstr,2);
      fprintf('%s ',varstr{jvar});
      t0=clock;a=read_slice([dirOut varstr{jvar} '.' tsstr '.bin'],L,1,it_slice);t1=clock;fprintf('%f ',etime(t1,t0));

      for l=1:length(prof_point_aste_compact);
        jj=find(pp_aste==prof_point_aste_compact(l));%should get a single number
        kk=find(a0.prof_point==prof_point(l) & a0.prof_date==a0.prof_date(1));	 % >1 if mult "data" interp onto 1 model pt
        Lkk(l)=length(kk);
        tmp=a(jj,:);				 %time-series of a single point, [1 x it_slice]
        if(length(kk)>1);tmp=repmat(tmp,[length(kk) 1]);end;
        %tmp=reshape(tmp,length(kk)*length(it_slice),1);
        for m=1:length(kk);
          mm=kk(m):kk(m)+length(it_slice)-1;
          eval(['a0.' varstr{jvar} '(mm,1)=tmp(m,:);']);
        end;
      end;
      t2=clock;fprintf('%f ',etime(t2,t1));
    end;
    fprintf('\n');

%now plot to check
    lat=unique(a0.prof_lat);lon=a0.prof_lon(1);%190;
    ii=find(a0.prof_lon==lon(1)&a0.prof_lat==lat(1)&a0.prof_date==a0.prof_date(1));
    mm=ii:ii+length(it_slice)-1;
    t=1:741;
    figure(1);clf;plot(a0.prof_Testim(mm,1));grid;hold on;plot(a0.THETA_k001(mm,1),'r-');hold off;
    for m=1:100;mm=(m-1)*length(it_slice)+1:m*length(it_slice);
      figure(1);clf;plot(t1,a0.prof_Testim(mm(t1),1),'linewidth',2);grid;hold on;
                    plot(t1,a0.THETA_k005(mm(t1),1),'r-');plot(t1,a0.THETA_k004(mm(t1),1),'g-');hold off;
      title(m);legend('Testim','T5','T4','location','northwest');
      pause;
    end;


%now re-writing a much bigger file:
    fout=[dirOut1 flist(ifile).name(1:idot-1) '_exf_state.mat'];
    save(fout,'a0','-v7.3');
    

  end

  %for i=1:length(flist0);
  %  a=readbin([dirOut flist0(i).name],[L nt]);
  %end;
				%/*}}}*/ [step3] 
end
