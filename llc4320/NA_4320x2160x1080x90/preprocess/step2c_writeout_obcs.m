%load in step1 llc270aste output, expand and interp to 106k
clear all;

%get indices:
define_indices;

%set directory
set_directory;

dirIn  = dirOBCS;
dirOut = dirIn;

% load step2b obcs structures
extbl='';
obcs_balance=1;if(obcs_balance==1);extbl='_bl';end;
fIn  =[dirOut 'step2b_obcs_' datestamp extbl '.mat'];
load(fIn);	%obcs2

%arrange into East, West, North South
nTpad=2;
nfx=obcs2{1}.nfx;
nfy=obcs2{1}.nfy;
sz=size(obcs2{1}.T);
LEast=sum(nfy);
LWest=LEast;
LNorth=sum(nfx);
LSouth=sum(nfx);

obcsstr={'N','S','E','W'};
obcsstrlong={'North','South','East','West'};
yshift=cumsum([0 nfy]);
xshift=cumsum([0 nfx]);
varstr={'T','S','U','V'};

get_field=1; %<-- make 0 to get indices for data.obcs
%initialize
for iloop=1:size(obcsstr,2);
  if(get_field==1);
  for ivar=1:size(varstr,2);
    eval([obcsstrlong{iloop} '.' varstr{ivar} '=zeros(L' obcsstrlong{iloop} ',sz(2),sz(3)+nTpad);']);
  end;
  end;
  eval([obcsstrlong{iloop} '.ind=zeros(L' obcsstrlong{iloop} ',1);']);		%keep track of indices for data.obcs
end;

for iloop=1:size(obcsstr,2);		%NSEW
  for iobcs=1:size(obcs2,2);		%1-3
    if(obcs2{iobcs}.obcsstr==obcsstr{iloop});
      iface=obcs2{iobcs}.face;
      ix=unique(obcs2{iobcs}.iC1(2,:));
      jy=unique(obcs2{iobcs}.jC1(2,:));
      for ivar=1:size(varstr,2);	%TSUV
        clear inan tmp
        if(obcs2{iobcs}.obcsstr=='N'|obcs2{iobcs}.obcsstr=='S');	%N,S
          if(get_field==1);
            eval(['sz=size(obcs2{iobcs}.' varstr{ivar} ');']);
            tmp=zeros(sz(1),sz(2),sz(3)+nTpad);				%add padding +2
            eval(['tmp(:,:,2:end-1)=obcs2{iobcs}.' varstr{ivar} ';']);
            tmp(:,:,1)=tmp(:,:,2);tmp(:,:,end)=tmp(:,:,end-1);
            inan=find(isnan(tmp(:))==1);if(length(inan)>0);tmp(inan)=0;end;		%get rid of nan
            eval([obcsstrlong{iloop} '.' varstr{ivar} '(ix+xshift(iface),:,:)=tmp;']);
          end;
          if(ivar==1);eval([obcsstrlong{iloop} '.ind(ix+xshift(iface))=jy;']);end;
        else;
          if(get_field==1);
            eval(['sz=size(obcs2{iobcs}.' varstr{ivar} ');']);
            tmp=zeros(sz(1),sz(2),sz(3)+nTpad);
            eval(['tmp(:,:,2:end-1)=obcs2{iobcs}.' varstr{ivar} ';']);
            tmp(:,:,1)=tmp(:,:,2);tmp(:,:,end)=tmp(:,:,end-1);
            inan=find(isnan(tmp(:))==1);if(length(inan)>0);tmp(inan)=0;end;               %get rid of nan
            eval([obcsstrlong{iloop} '.' varstr{ivar} '(jy+yshift(iface),:,:)=tmp;']);
          end;
          if(ivar==1);eval([obcsstrlong{iloop} '.ind(jy+yshift(iface))=ix;']);end;
        end;
      end;	%ivar
    end		%
  end;		%iobcs
end;		%iloop

%write out
write_files=1;
if(write_files==1);
nzstr=num2str(sz(2));
ntstr=num2str(sz(3)+nTpad);
for iloop=1:size(obcsstr,2);	%NSEW
  eval(['L=L' obcsstrlong{iloop} ';']);
  str=[sprintf('%4.4i',L) 'x' nzstr 'x' ntstr];
  for ivar=1:size(varstr,2);
    clear tmp fOut
    fOut=[dirOut 'OB' obcsstr{iloop} lower(varstr{ivar}) '_' str '_' datestamp extbl '.bin'];
    eval(['tmp=' obcsstrlong{iloop} '.' varstr{ivar} ';']);
    writebin(fOut,tmp,1,'real*4');fprintf('%s\n',fOut);
  end;
end;
end;

%getting indices for data.obcs
%South
iy=unique(South.ind);iy=iy(find(iy>0));
for i=1:length(iy);
  ix=find(South.ind==iy(i));
  fprintf('[ix_start ix_end length(ix) iy]=%i %i %i %i\n',...
           [ix(1) ix(end) ix(end)-ix(1)+1 iy(i)]);
end;

%getting indices for data.obcs
%South
ii=find(diff(South.ind)~=0);ii=[0;ii;length(South.ind)];
fprintf('OB_Jsouth: \n');
fprintf('%4i %4i ; %4i at %4i\n',[ii(1:end-1)+1 ii(2:end) ii(2:end)-ii(1:end-1) South.ind(ii(1:end-1)+1)]');
%OB_Jsouth
%[ix_start ix_end length(ix) iy]=1 2160 2160 16
%    1 2160 ; 2160 at  16
% 2161 3240 ; 1080 at   0

%North
iy=unique(North.ind);iy=iy(find(iy>0));
for i=1:length(iy);
  ix=find(North.ind==iy(i));
  fprintf('[ix_start ix_end length(ix) iy]=%i %i %i %i\n',...
           [ix(1) ix(end) ix(end)-ix(1)+1 iy(i)]);
end;
fprintf('OB_Jnorth = %i*%i, %i*%i,\n',[length(ix) iy LNorth-length(ix) 0]);
ii=find(diff(North.ind)~=0);ii=[0;ii;length(North.ind)];
fprintf('OB_JNorth: \n');
fprintf('%4i %4i ; %4i at %4i\n',[ii(1:end-1)+1 ii(2:end) ii(2:end)-ii(1:end-1) North.ind(ii(1:end-1)+1)]');
%[ix_start ix_end length(ix) iy]=1 2160 2160 1057
%OB_JNorth: 
%   1 2160 ; 2160 at 1057
%2161 3240 ; 1080 at    0

%East
ii=find(diff(East.ind)~=0);ii=[0;ii;length(East.ind)];
fprintf('OB_Jeast: \n');
fprintf('%4i %4i ; %4i at %4i\n',[ii(1:end-1)+1 ii(2:end) ii(2:end)-ii(1:end-1) East.ind(ii(1:end-1)+1)]');
%OB_Jeast: 
%   1  539 ;  539 at    0
% 540  553 ;   14 at 1531
% 554 1080 ;  527 at    0
%1081 3240 ; 2160 at 1065

%West
ix=unique(West.ind);ix=ix(find(ix>0));
for i=1:length(ix);
  iy=find(West.ind==ix(i));
  fprintf('[iy_start iy_end length(iy) ix]=%i %i %i %i\n',...
           [iy(1) iy(end) iy(end)-iy(1)+1 ix(i)]);
end;
ii=find(diff(West.ind)~=0);ii=[0;ii;length(West.ind)];
fprintf('OB_JWest: \n');
fprintf('%4i %4i ; %4i at %4i\n',[ii(1:end-1)+1 ii(2:end) ii(2:end)-ii(1:end-1) West.ind(ii(1:end-1)+1)]');
%OB_JWest: 
%   1 1080 ; 1080 at    0
%1081 3240 ; 2160 at   24
