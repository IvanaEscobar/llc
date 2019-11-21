=clear all;

%now read in the global/region/Gulfstream2 grid to locate these points:
dirRoot='/work/03901/atnguyen/MITgcm_c67/mysetups/aste_1080x1260x540x90/';
dirGrid=[dirRoot 'GRID/'];
dirRun=[dirRoot 'run_tides_run2_hourly_it0000_pk0001577880/'];
dirout=[dirRun 'extract_hourly/'];if(~exist(dirout));mkdir(dirout);end;
dirout1=[dirRun 'extract_hourly/L104_m69p5Section/'];if(~exist(dirout1));mkdir(dirout1);end;
nx=1080;ncut1=1260;ncut2=540;ny=2*ncut1+nx+ncut2;nz=90;
deltaT=240;yrstart=2002;mostart=01;dastart=1;
fprofpoint=[dirout 'unique_profpoint_L104_m69p5.bin'];

%=====================================================================================
%===================================== STEP 1 ========================================
%=====================================================================================
if(~exist(fprofpoint));
		%/*{{{*/ exist_fprofpoint
%first get the NA region wetpts:
  dirRoot2='/work/03901/atnguyen/Ivana/llc4320/NA_4320x2160x1080x90/';
  dirGrid2=[dirRoot2 'GRID/'];
  
  RunStr2='run_c67h_tidal_bc_pk0000000001';
  dirin2=[dirRoot2 RunStr2 '/extract_hourly/'];if(~exist(dirin2));error('dir hourly not existed');end;
  
  Lprofpoint=104;section_name='_m69p5';
  fprofpoint2=[dirin2 'unique_profpoint_L' num2str(Lprofpoint) section_name '.bin'];
  pp2=readbin(fprofpoint2,[1 Lprofpoint]);
  findex2=[dirin2 'ind_wet_L104_m69p5Section.mat'];load(findex2,'indcompact','indwet','indprof');
  
  fGrid2=[dirGrid2 'Index_wet_hfacC_2D.mat'];load(fGrid2,'ind');
  
  nx2=2160;ny2=nx2;
  
  yc2=rdmds([dirGrid2 'YC']);yc2=reshape(yc2,nx2,ny2);yc2=yc2(ind(:,6));	%wet
  xc2=rdmds([dirGrid2 'XC']);xc2=reshape(xc2,nx2,ny2);xc2=xc2(ind(:,6));	%wet

%get wet indices for top layer only
  for j=1:length(pp2);
      ij=find(indprof==pp2(j));indwet1(j)=indwet(ij(1));
  end;
  
  yc2=yc2(indwet1);
  xc2=xc2(indwet1);
  flatlon='/work/03901/atnguyen/Proposal/SWOT2019/matlab/L104_m69p5Section_latlon.mat';
  save(flatlon,'yc2','xc2');

%now read in the global/region/Gulfstream2 grid to locate these points:
  yc=readbin([dirGrid 'YC.data'],[nx ny]);
  xc=readbin([dirGrid 'XC.data'],[nx ny]);
  
  for i=1:length(yc2);
    tmp=geoidd(yc(:),xc(:),yc2(i),xc2(i));
  
    ij=find(tmp==min(tmp));
    if(length(ij)==1)
      pp(i)=ij;
    else;
      fprintf('%i ',i);
    end;
  end;
  %%somehow pp2 is in reverse order for llc4320? sort to make it easier to read
  %pp2=sort(pp2);
  writebin(fprofpoint,pp);

else;		%/*}}}*/ exist_fprofpoint
  Lprofpoint=104;
  pp=readbin(fprofpoint,[1 Lprofpoint]);	%already sorted
%=== wet points =======
%load indices
  fGrid=[dirGrid 'Index_wet_hfacC_2D.mat'];                  %
  load(fGrid,'ind');ind2d=ind;Lwet_layer1=size(ind2d,1);clear ind
  
  fGrid=[dirGrid 'Index_wet_hfacC.mat'];                  %
  load(fGrid,'ind','i1','i2');%tic;toc;                   %8.7sec
  indC=ind;i1C=i1;i2C=i2;
  LmaxC=size(indC,1);                                       %C: 111578238; W: 110767778; S: 110664810
  clear ind i1 i2
end;
%=====================================================================================
%===================================== STEP 1a =======================================
%=====================================================================================
step1a=1;%get/load in ind_wet
if(step1a);
%/*{{{*/ step1a
  Lprofpoint=104;section_name='_m69p5';
  findex=[dirout 'ind_wet_L' num2str(Lprofpoint) section_name 'Section.mat'];
  if(~exist(findex));
    error('run get_wet_ind_single_section.m first to get correction section index');
  else;
    load(findex,'indcompact','indwet','indprof');
  end;
%/*}}}*/ step1a
end;

%=====================================================================================
%===================================== STEP 2 ========================================
%=====================================================================================
step2=1;
if(step2);
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
  fldList2={'ETANcor'};nf2=1;if2c=13;%25;


  %get wet indices for top layer only
  for j=1:length(pp);
      ij=find(indprof==pp(j));indwet1(j)=indwet(ij(1));
  end;

%=======================

  %flistexfc=dir([dirRun 'diags/exf_zflux_hourly_Cwet/exf_zflux_hourly_*.data']);Lfile=length(flistexfc);
  %flistexfc1 =dir([dirRun 'diags/exf_zflux_hourly_UVcwet/exf_zflux_hourly_c*.data']);
  fliststac  =dir([dirRun 'diags/state_2d_hourly_Cwet/state_2d_hourly_*.data']);Lfile=length(fliststac);
  %fliststac1 =dir([dirRun 'diags/state_2d_hourly_UVcwet/state_2d_hourly_c*.data']);
  idot=find(fliststac(1).name=='.');idot=idot(1)+1:idot(end)-1;

%loop once to get time
  fsave=[dirout 'time_step.mat'];
  if(~exist(fsave));
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

  %fout=[dirout1 fldList{iff(1)} '.' strout '.bin'];
  fout=[dirout1 fldList{1} '.' strout '.bin'];
  if(exist(fout));
    for j=1:length(iff);
      %fout=[dirout1 fldList{iff(j)} '.' strout '.bin'];
      fout=[dirout1 fldList{j} '.' strout '.bin'];
      clear a;a=readbin(fout,[length(pp),Lfile]);
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
    %tmp=readbin([dirRun 'diags/' str '/' flist(ifile).name],[Lwet_layer1 length(iff)]);
    tmp=read_slice([dirRun 'diags/' str '/' flist(ifile).name],Lwet_layer1,1,iff);
    vv(:,:,ifile)=tmp(indwet1,:);

    if(mod(ifile,240)==0|ifile==length(flist));
      for j=1:length(iff);
        tmp=squeeze(vv(:,j,:));
        %fout=[dirout1 fldList{iff(j)} '.' strout '_1.bin'];writebin(fout,tmp);
        fout=[dirout1 fldList{j} '.' strout '_1.bin'];writebin(fout,tmp);
      end;
      fprintf('\n');
    end;

    if(mod(ifile,24)==0);t1=etime(clock,t0);fprintf('%i %f ',[ifile t1]);t0=clock;end;
  end;
  end;%istart<=length(flist)
%				/*}}}*/ [step2] 
end;

%========================
