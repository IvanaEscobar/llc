%this is identical to the beginning of extract_exf_profiles_wet.m
function [indwet,indcompact,indprof]=get_wet_index_function(pp,flag_section);
%----
%function [indwet,indcompact,indprof]=get_wet_index_function(pp,flag_section);
%--
%input: 
%  pp: aste 1080x1260x540 compact prof_point
%  flag_section: [1] for using section extraction, [0] for indiv prof extraction
%                reccommend [1]
%output:
%  indwet    : the wet indices in full 3D
%  indcompact: aste compact in full 3D
%  indprof   : the profile index , from 1:length(pp)
%---

addpath('~atnguyen/matlab/MITprof_toolbox/');
addpath('~atnguyen/matlab/MITprof_toolbox_extra/');

dirWork=['/work/05427/iescobar/stampede2/llc/llc4320/NA_4320x2160x1080x90/'];
dirGrid=[dirWork 'GRID/'];

nx=2160;ny=nx;nz=90;nfx=[2160 0 0 0 1080]; nfy=[1080 0 0 0 2160];
deltaT=90;yrstart=2002;mostart=1;dastart=1;

%=================================================

flag_single_profile=~flag_section;

Lprofpoint=length(pp);

%=== wet points =======
%load indices
  fGrid=[dirGrid 'Index_wet_hfacC_2D.mat'];                  %
  load(fGrid,'ind');ind2d=ind;clear ind

  fGrid=[dirGrid 'Index_wet_hfacC.mat'];                  %
  load(fGrid,'ind','i1','i2');%tic;toc;                   %8.7sec
  indC=ind;i1C=i1;i2C=i2;
  LmaxC=size(indC,1);                                       %C: 111578238; W: 110767778; S: 110664810
  clear ind i1 i2

%note here we're still looping over the number of points pp in order to facilitate single-pt
%extraction.  FOR massive amount of point, we can simply generate another matrix of indices
%pointing to which pp, and do in 1 go all the indwet and ind_compact, then later do 1 last
%loop over pp to split all the valid values(indwet) into indiv profile.

use_intersect_method=1;

    if(~use_intersect_method);	%original method, EXTREMELLY SLOW
   % /*{{{*/
      klev=1;
      ii=i1C(6,klev):i2C(6,klev);
      ioffset=(klev-1)*nx*ny;        		%0 for top layer
      iwet_layer1=indC(ii,6)-ioffset;
      Lwet_layer1=length(iwet_layer1);		%1952025
      for klev = 1:nz
          iw=i1C(6,klev):i2C(6,klev);
          ioffset=(klev-1)*nx*ny;                 %0 for top layer
          iwet_layer{klev}=indC(iw,6)-ioffset;
          Lwet_layerk(klev)=length(iwet_layer{klev});
          ind_map_k{klev} = ismember(iwet_layer1,iwet_layer{klev});  %These are the ind that repeat in layerk and exist in layer1
      end

      tmp=nan(nx*ny*nz,1);tmp(indC(:,6))=1;tmp=reshape(tmp,nx,ny,nz);
      for j=1:nz; ioffset=(j-1)*nx*ny; pp1(:,j)=pp+ioffset; end;

      for j=1:length(pp);
        ij=pp1(j,:);
        [~,il]=find(isnan(tmp(ij))==0);
        indcompact{j}=ij(il);			%compact indices

        indwet{j}=nan.*indcompact{j};
        fprintf('%i ',j);
        for k=1:length(indcompact{j});
          ik=find(indC(:,6)==indcompact{j}(k));
          indwet{j}(k)=ik;			%wet indices
          fprintf('%i ',[k]);
        end;
        fprintf('\n'); 
      end;
	%/*}}}*/
    else;
%%first, we get the indices of pp in the wet domain, called indwet, 
%%so that for any 2d field, field_wet(indwet) = field_compact(pp)
%     [icompact,~,jwet]=intersect(pp,ind2d(:,6));indwet=ind2d(jwet,6);%icompact=pp, as expected.

%for the same syntax, instead of getting all pp (2d), we can also split and get 3d as follows:
%first, make pp a [L x 1] vector
      if(size(pp,1)==1);pp=pp';end;
      pp3d=repmat(pp,[1 nz]);			%[length(pp) nz]
      for i=1:nz;pp3d(:,i)=pp+(i-1)*nx*ny;end;	%the vertical shift

%ind_compact is a reduced version of pp3d, now with only valid depths
      if(flag_single_profile)
        indwet=[];indcompact=[];indprof=[];
      elseif(flag_section);
        indwet=nan.*ones(length(pp3d(:)),1);indcompact=indwet;indprof=indcompact;
      end;

      i2p=0;i1p=[];
      for i=1:length(pp);
        clear icompact jwet 
        t1=clock;
        [icompact,~,jwet]=intersect(pp3d(i,:),indC(:,6));
%just make it same dim as pp, row in this case
        if(flag_single_profile);
          indwet{i}=jwet;indcompact{i}=indC(jwet,6);
        elseif(flag_section);
          i1p=i2p+1;i2p=i2p+length(jwet);
          indprof(i1p:i2p)=pp(i);
          indwet(i1p:i2p)=jwet;
          indcompact(i1p:i2p)=indC(jwet,6);
        end;
        fprintf('%i %f ',[i etime(clock,t1)]); %0.5sec per point
        if(mod(i,20)==0|i==length(pp));fprintf('\n');end;
      end;%pp
      if(flag_section);
        indprof=indprof(1:i2p);indwet=indwet(1:i2p);indcompact=indcompact(1:i2p);
      end;
    end; %use intersect method

return
