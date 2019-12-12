%29.may.2015: modifying barotropic as JM suggested:
%first do it in original c-grid:
% Ubar=1/H sum_k u(i,j,k)*hfW(i,j,k)*drF(k)
% Vbar=1/H sum_k v(i,j,k)*hfS(i,j,k)*drF(k)
% Wbar=1/H sum_k w(i,j,k)*drF(k)
%second: centering (but calc baroclinic using above [U,V,W]_bar)
% Ubar_c(i,j,k)=(Ubar(i,j,k)+Ubar(i+1,j,k))./2
% Vbar_c(i,j,k)=(Vbar(i,j,k)+Vbar(i,j+1,k))./2
%26.aug.2019: even though JM suggested to do first in c-grid, it turns out we always
%need to center for any kind of extraction of a point.  And it's such a hassle to 
%need 2 sets of U and V just to get 1 single centered set [Uc,Vc], An is now centering
%first, then will get bar.  This bar is now already centered.
clear all;
define_indices;
addpath('~/matlab/atn_tools/gcmfaces_mod');

%% Setting Directories and Domain Info: Escobar's NA setup
dirWork='/work/05427/iescobar/stampede2/llc/llc4320/NA_4320x2160x1080x90/';
dirScratch='/scratch/05427/iescobar/llc/llc4320/NA_4320x2160x1080x90/run_c67h_no_tidal_bc_pk0000000001/';
dirGrid=[dirWork 'GRID/'];
dirRun=[dirScratch];
if(~exist(dirRun));error('dirrun not exist');end;

nx=id.n.x;
ny=id.n.y;
nz=id.n.z;
ix=1:nx;iy=1:ny;    Lix=length(ix);Liy=length(iy);
iz=1:id.n.z;        Lz=length(iz);	%how many levels printed out 
nxy=nx*ny;
vvar={'UVELMASSc','VVELMASSc'};

drF=readbin([dirGrid 'DRF.data'],[1,nz],1,'real*4');
dz3d=zeros(nx,ny,Lz);
for k=1:Lz;
  dz3d(:,:,iz(k))=drF(iz(k));
end;

%% Read in total depth
H=readbin([dirGrid 'Depth.data'],[nx,ny]); 
H=abs(H);
iH=find(H(:)==0); % find land

fGrid=[dirGrid 'Index_wet_hfacC.mat'];
load(fGrid,'ind','i1','i2');%tic;toc;			%8.7sec
Lmax=size(ind,1);

% Saving wet points for bar field:
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
  
for ivar=2:2;

  flist=dir([dirRun 'diags/' vvar{ivar} '_wet/' vvar{ivar} '_' num2str(Lmax) '.*.data']);L=length(flist);	%1sec
  idot=find(flist(1).name=='.');idot=[idot(1)+1:idot(2)-1];

  istart=1;iend=L;
  for it=iend:-1:istart; %:iend	, reverse so we're not accessing same files when doing in parallel U,V 

    ts=flist(it).name(idot)
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
