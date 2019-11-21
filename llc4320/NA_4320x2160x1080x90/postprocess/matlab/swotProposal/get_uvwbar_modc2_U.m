%29.may.2015: modifying barotropic as JM suggested:
%first do it in original c-grid:
% Ubar=1/H sum_k u(i,j,k)*hfW(i,j,k)*drF(k)
% Vbar=1/H sum_k v(i,j,k)*hfS(i,j,k)*drF(k)
% Wbar=1/H sum_k w(i,j,k)*drF(k)
%second: centering (but calc baroclinic using above [U,V,W]_bar)
% Ubar_c(i,j,k)=(Ubar(i,j,k)+Ubar(i+1,j,k))./2
% Vbar_c(i,j,k)=(Vbar(i,j,k)+Vbar(i,j+1,k))./2
%makes no sense to "center Wbar_c" in vertical grid because it's only a 2-d field, 
%so point below is for "baroclinic" centering
%%%% Wbar_c(i,j,k)=(Wbar_c(i,j,k)+Wbar_c(i,j,k+1))./2;
%%%% Wbar_c(i,j,N)=(Wbar(i,j,N)+0)./2; where zeros represents bottom velocity for non-slip
%26.jul.2015: after rethinking: will center W, then use drF to calc W_bar, thus
% can follow exactly recipe above.
%26.aug.2019: even though JM suggested to do first in c-grid, it turns out we always
%need to center for any kind of extraction of a point.  And it's such a hassle to 
%need 2 sets of U and V just to get 1 single centered set [Uc,Vc], An is now centering
%first, then will get bar.  This bar is now already centered.

clear all;
define_indices;
addpath('~/matlab/atn_tools/gcmfaces_mod');
dirRoot='/work/03901/atnguyen/Ivana/llc4320/NA_4320x2160x1080x90/';
dirRoot1=dirRoot;
RunStr='run_c67h_tidal_bc_pk0000000001';ext='';ext1='';
dirRun=[dirRoot1 RunStr ext '/'];
if(~exist(dirRun));error('dirrun not exist');end;
dirMlb=[dirRoot 'matlab/'];
ix=1:nx;iy=1:ny;Lix=length(ix);Liy=length(iy);
iz=1:90;
Lz=length(iz);	%note need to remember how many levels we're printing out
nxy=nx*ny;nz=90;dt=90;yrStart=2002;moStart=01;dayStart=01;
vvar={'UVELMASSc','VVELMASSc'};%,'W'};

nzuv=90;	%90 for W

%dirGrid='/nobackupp5/dmenemen/llc_2160/grid/';
dirGrid=[dirRoot 'GRID/'];
drF=readbin([dirGrid 'DRF.data'],[1,nz],1,'real*4');
dz3d=zeros(nx,ny,Lz);
for k=1:Lz;%nzuv
  dz3d(:,:,iz(k))=drF(iz(k));
end;
%dz3d=dz3d.*hF;

%29.may.2015: THE KEY HERE IS **NOT** to nan out land, leave as zero
%hF=read_llc_fkij('/nobackupp5/dmenemen/llc_2160/grid/hFacC.data',nx,3,1:nzuv);hF=hF(ix,iy,:);

%read in the mask to save time, need skx-normal to have memory:
%hC=readbin([dirGrid 'hFacC.data'],[nx,ny,nz]);%
%hC(find(hC>0))=1;%need to mask out land, otherwise biased "sum" in depth average, 8.2sec
%H=nansum(dz3d.*hC,3);
%
H=readbin([dirGrid 'Depth.data'],[nx,ny]); %read in directly total depth
H=abs(H);
iH=find(H(:)==0);

fGrid=[dirGrid 'Index_wet_hfacC.mat'];			%
load(fGrid,'ind','i1','i2');%tic;toc;			%8.7sec
Lmax=size(ind,1);					%C: 111578238; W: 110767778; S: 110664810

%save just wet point for bar field:
klev=1;
ii=i1(6,klev):i2(6,klev);
ioffset=(klev-1)*nx*ny;		%0 for top layer
iwet_layer1=ind(ii,6)-ioffset;
Lwet_layer1=length(iwet_layer1);

H_wet = H(ind(ii,6)-ioffset); % This has to be here, i am calling ii for level 1

%tic;
%imap2d = [];
%for klev = 1:nz
%    ii=i1(6,klev):i2(6,klev);
%    ioffset=(klev-1)*nx*ny;
%    iwet_layer = ind(ii,6)-ioffset;
%    imap2d = [imap2d;iwet_layer];
%    Lwet_layer(klev) = length(iwet_layer);
%end
%toc;

%test method2
%tic;
imap2d=nan(Lmax,1);
Lwet_layer=zeros(1,nz);
i2p=0;
for klev=1:nz;
  ii=i1(6,klev):i2(6,klev);
  ioffset=(klev-1)*nx*ny;
  iwet_layer = ind(ii,6)-ioffset;
  i1p=i2p+1;
  i2p=i2p+length(iwet_layer);
  imap2d(i1p:i2p)=iwet_layer;
  Lwet_layer(klev) = length(iwet_layer);
end;
%toc;
Lwet_tot = sum(Lwet_layer);
[~ ,~ ,uind] = unique(imap2d); % got the repeated ind

% now rest of layers
dz_wet=dz3d(ind(:,6))';


dirOutbar=[dirRun 'diags/UVcbar_wet/'];if(exist(dirOutbar)==0);mkdir(dirOutbar);end;
dirOutpri=[dirRun 'diags/UVcpri_wet/'];if(exist(dirOutpri)==0);mkdir(dirOutpri);end;

%do a first quick loop to check size and delete inconsistent files:
  %for iloop=1:2;
  %      if(iloop==1);dirin=dirOutbar ;L=Lwet_layer1;
  %  else;            dirin=dirOutpri ;L=Lmax;end;

  %  flist=dir([dirin '*.data']);
  %  if(length(flist)>0);
  %    for j=1:length(flist);
  %      if(flist(j).bytes/L/4~=1);
  %        clear str
  %        str=['system(''rm -f ' dirin flist(i).name ''')'];
  %        eval(str);
  %        fprintf('%s\n ',str);
  %      end;
  %    end;
  %  end;
  %end;
  
for ivar=1:1;

  flist=dir([dirRun 'diags/' vvar{ivar} '_wet/' vvar{ivar} '_' num2str(Lmax) '.*.data']);L=length(flist);	%1sec
  idot=find(flist(1).name=='.');idot=[idot(1)+1:idot(2)-1];

  istart=1;iend=L;

  for it=iend:-1:istart;%:iend	, reverse so we're not accessing same files when doing in parallel U,V 

    ts=flist(it).name(idot);
    fOutbar=[dirOutbar vvar{ivar} '_' num2str(Lwet_layer1) '.' ts '.data'];
    fOutpri=[dirOutpri vvar{ivar} 'p_' num2str(Lwet_tot) '.' ts '.data'];

    if(~exist(fOutbar)|~exist(fOutpri));
      t1=clock;
      ain=readbin([dirRun 'diags/' vvar{ivar} '_wet/' flist(it).name],[1 Lmax]);%tic;toc;%3.2sec




      do_m1 = 0; do_m2 = 1;
      if do_m1 % this takes ~ 2 sec on SKX

        ftot=zeros(nx,ny,nz);ftot(ind(:,6))=ain;%tic;toc;%4.5sec
        ftotdz=ftot.*dz3d;
        fbar=sum(ftotdz,3)./H;	%2d field, [Lix,Liy]
        fbar(iH)=0;

        fbar_wet=fbar(iwet_layer1);		% save just wet point:
      

      elseif do_m2 % this takes 1 sec on SKX

          fbar_wet=accumarray(uind,ain.*dz_wet,[],@sum)./H_wet;
          fprim_wet = ain - fbar_wet(uind).';
          %             disp([' method wet sum = ' num2str(toc(tm2))]);
      end
      writebin(fOutbar,fbar_wet,1,'real*4');%0.6sec
      writebin(fOutpri,fprim_wet,1,'real*4');%0.6sec
      if(mod(it,240)==0);t2=clock;fprintf('%i %f ',[it etime(t2,t1)]);end;%4.3sec per file
    end;
  end;
  fprintf('\n');
end;
