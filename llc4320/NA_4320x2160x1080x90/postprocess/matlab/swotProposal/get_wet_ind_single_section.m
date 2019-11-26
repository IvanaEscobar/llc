%this is identical to the beginning of extract_exf_profiles_wet.m
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
dirOut =[dirScratch 'extract_hourly/'];        if(~exist(dirOut)); mkdir(dirOut); end
%dirGrid=[dirRoot 'GRID/'];
%need to reserve variable ind for loading wet_indices

deltaT=90;yrstart=2002;mostart=1;dastart=1;

%=================================================

%Section
  section_name='_m73p9_cluster';
  Lprofpoint=155;
  fprofpoint=[dirOut 'unique_profpoint_L' num2str(Lprofpoint) section_name 'Section.bin'];
  if(~exist(fprofpoint))
%indices in aste format: use get_aste_tracer to find
% EX:
%    ix=435;%(closest x index to longitude -73.9: xc_ref=xcaste(1:4320,540);ix_prof=closest(-73.9,xc_ref,1)
%    iy=21:10:1056;
    load([dirScratch 'crossOverPoints2.mat']); ix=xc_list; iy=yc_list;
    tmp=zeros(4320,1080);for i=1:length(iy);tmp(ix(i),iy(i))=1;end;tmp=aste_tracer2compact(tmp,id.nf.x,id.nf.y);
    pp=find(tmp(:)>0);
    Lprofpoint=length(pp);
    writebin(fprofpoint,pp,1,'real*4');
  else
    pp=readbin(fprofpoint,[1 Lprofpoint]);
  end

%=== wet points =======
%load indices
  fGrid=[dirGrid 'Index_wet_hfacC_2D.mat'];               %3390920
  load(fGrid,'ind');ind2d=ind;clear ind

  fGrid=[dirGrid 'Index_wet_hfacC.mat'];                  %
  load(fGrid,'ind','i1','i2');%tic;toc;                   %8.7sec
  indC=ind;i1C=i1;i2C=i2;
  LmaxC=size(indC,1);                                     %C: 264652695;
  clear ind i1 i2

%note here we're still looping over the number of points pp in order to facilitate single-pt
%extraction.  FOR massive amount of point, we can simply generate another matrix of indices
%pointing to which pp, and do in 1 go all the ind_wet and ind_compact, then later do 1 last
%loop over pp to split all the valid values(ind_wet) into indiv profile.

use_intersect_method=1;

    findex=[dirOut '../ind_wet_L' num2str(Lprofpoint) section_name 'Section.mat'];

  if(~exist(findex))
%%first, we get the indices of pp in the wet domain, called ind_wet, 
%%so that for any 2d field, field_wet(ind_wet) = field_compact(pp)
%     [icompact,~,jwet]=intersect(pp,ind2d(:,6));ind_wet=ind2d(jwet,6);%icompact=pp, as expected.

%for the same syntax, instead of getting all pp (2d), we can also split and get 3d as follows:
%first, make pp a [L x 1] vector
      if(size(pp,1)==1);pp=pp';end
      pp3d=repmat(pp,[1 id.n.z]);			%[length(pp) nz]
      for i=1:id.n.z;pp3d(:,i)=pp+(i-1)*id.n.x*id.n.y;end	%the vertical shift

%ind_compact is a reduced version of pp3d, now with only valid depths
        indwet=nan.*ones(length(pp3d(:)),1);indcompact=indwet;indprof=indcompact;

      i2p=0;i1p=[];
      for i=1:length(pp);
        clear icompact jwet 
        t1=clock;
        [icompact,~,jwet]=intersect(pp3d(i,:),indC(:,6));
%just make it same dim as pp, row in this case
          i1p=i2p+1;i2p=i2p+length(jwet);
          indprof(i1p:i2p)=pp(i);
          indwet(i1p:i2p)=jwet;
          indcompact(i1p:i2p)=indC(jwet,6);
        fprintf('%i %f ',[i etime(clock,t1)]); %0.5sec per point
        if(mod(i,20)==0|i==length(pp));fprintf('\n');end
      end;%pp
        indprof=indprof(1:i2p);indwet=indwet(1:i2p);indcompact=indcompact(1:i2p);

      save(findex,'pp','indcompact','indwet','indprof');
  else;
    load(findex,'indcompact','indwet','indprof');
  end;
