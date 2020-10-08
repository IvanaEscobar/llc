clear all;
define_indices; 
%% Setting Directories and Domain Info: Escobar's NA setup
dirWork='/work/05427/iescobar/stampede2/llc/llc4320/NA_4320x2160x1080x90/';
dirScratch='/scratch/05427/iescobar/llc/llc4320/NA_4320x2160x1080x90/run_c67h_no_tidal_bc_pk0000000001/';
dirGrid=[dirWork 'GRID/'];
dirRun=[dirScratch 'diags/'];
if(~exist(dirRun));error('dirrun not exist');end;

nx= id.n.x;     % 2160
ny= id.n.y;     % 2160
nz= id.n.z;     % 90
nfx= id.nf.x;   % [2160 0 0 0 1080]
nfy= id.nf.y;   % [1080 0 0 0 2160]

%% Picking Diagnostics to Compress: see *.meta for info on diags
diagIn  ={'state_3d_hourly','state_3d_hourly','trsp_3d_hourly','trsp_3d_hourly'};
subDir  ={'state_3d/','state_3d/','trsp_3d/','trsp_3d/'};
diagVar ={'THETA','SALT','UVELMASS','VVELMASS'};
varWetpt={'C','C','W','S'};		%hfac[C,W,S]
%nzoffset: the index of the diagVar Can be found in *.meta fldList
nzoffset=[0 1 0 1].*nz;

%use_method=1;		%split iz
use_method=0;		%read the whole file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for ivar=1:size(diagIn,2);
for ivar=2:2;
  clear flist

  flist=dir([dirRun subDir{ivar} diagIn{ivar} '.*.data']);if(length(flist)==0);error('flist missing');end;
  idot=find(flist(1).name=='.');idot=idot(1)+1:idot(2)-1;

%determining nz1 from meta file:
  meta=rdmds_meta([dirRun subDir{ivar} flist(1).name(1:end-5)]);
  if(meta.nDims==2);nz1=1;else;nz1=meta.dimList(7);end;			%83 or 80

  dirOut=[dirRun diagVar{ivar} '_wet/'];if(~exist(dirOut));mkdir(dirOut);end;
  fGrid=[dirGrid 'Index_wet_hfac' varWetpt{ivar} '.mat'];
  if(~exist(fGrid));error('fGrid wet pt missing, run get_wet_points.m first\n');end;
  fprintf('%s ',diagVar{ivar});
  t1=clock;load(fGrid,'ind','i1','i2'); fprintf('%g ',etime(clock,t1));	%40sec to load
  Lmax=size(ind,1);

  izv=[1:nz1]+nzoffset(ivar);

  istart=1;
  for ifile=istart:length(flist);					%89sec / file
    %tic
    ts=flist(ifile).name(idot)

    fOut=[dirOut diagVar{ivar} '_' sprintf('%i',Lmax) '.' ts '.data'];%10sec to write

    if(~exist(fOut));

      t1=clock;
      if(use_method==1);
        aout=zeros(Lmax,1);	%memory for just wet point, note this is to all 90 vertical lev %/*{{{*/
        for iz=1:nz1;
          clear a ii ioffset
          a=read_slice([dirRun subDir{ivar} flist(ifile).name],nx,ny,izv(iz));
          ii=i1(6,iz):i2(6,iz);
          ioffset=(iz-1)*nx*ny;
          aout(ii,1)=a(ind(ii,6)-ioffset);
        end;								%23 sec to read 90 lev  %/*}}}*/
      elseif(use_method==0);						%47sec / file
        clear ain aout							%/*{{{*/
        aout=zeros(Lmax,1);						%all 90 vertical levels
        ain=read_slice([dirRun subDir{ivar} flist(ifile).name],nx,ny,izv);	%21sec to read all 90
        ii=1:i2(6,nz1);							%need to obtain indices for up to only nz1:
        aout(ii,1)=ain(ind(ii,6));					%/*}}}*/
      end;

      writebin(fOut,aout,1,'real*4');
      t2=clock;
      if(mod(ifile,12)==0);fprintf('%i %g ',[ifile etime(t2,t1)]);end;
    end;
    %toc   
  end;
  fprintf('\n');
end;									%ivar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
expanding_field=0;
if(expanding_field==1);							%/*{{{*/

  %now expanding:
  for ivar=1:1;
    dirIn=[dirRun diagVar{ivar} '_wet/'];
    dirOut=dirIn;
    flist1=dir([dirIn diagVar{ivar} '_' sprintf('%i',Lmax) '.*.data']);
    idot1=find(flist1(1).name=='.');idot1=idot1(1)+1:idot1(2)-1;
    for ifile1=1:5;
      ts=flist1(ifile1).name(idot1);
      tic;ain=readbin([dirIn flist1(ifile1).name],[1 Lmax]);toc;	%8.5sec to read
      tic;aout=zeros(nx,ny,nz);toc;					%0.02sec
      tic;aout(ind(:,6))=ain;toc;					%6.2sec
      tic;writebin([dirOut diagVar{ivar} '.' ts '.data'],aout,1,'real*4');toc;%35sec
    end;
  end;
end;									%/*}}}*/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
expanding_field_layer=0;
if(expanding_field_layer==1);						%/*{{{*/
%expanding 1 layer:
  klev=11;
  
  ii=i1(6,klev):i2(6,klev);
  iwet=ind(ii,6)-(klev-1)*nx*ny;
  sz=size(iwet);if(sz(1)==1&sz(1)<sz(2));iwet=iwet';end;
  fld=zeros(length(ii),1);
  
  for ivar=1:1;
    dirIn=[dirRun diagVar{ivar} '/'];
    dirOut=dirIn;
    flist1=dir([dirIn diagVar{ivar} '_' sprintf('%i',Lmax) '.*.data']);
    idot1=find(flist1(1).name=='.');idot1=idot1(1)+1:idot1(2)-1;

    ifile1=5;
    fnam=[dirIn flist1(ifile1).name];
    
    prec='real*4';preclength=4;
    temp=dir(fnam);
    fid=fopen(fnam,'r','ieee-be');
    skip = ii(1)-1;
    if(fseek(fid,skip*preclength,'bof')<0), error('past end of file'); end
    fld(:,1)=fread(fid,length(ii),prec);
    fclose(fid);
    
    tmp=zeros(nx*ny,1);tmp(iwet)=fld;tmp=reshape(tmp,nx,ny);
  end;

end;									%/*}}}*/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_duplicate=0;
if(test_duplicate);
%test expand: note that a tracer field will have more non-zero points than in hFacC along
%obcs points that do not contribute to the solution (for example THETA~=0 where hFacC are zeros).
%thus when compared expanded to orgiinal, will have points exactly along obcs in N.Ameirica, N.Pacific,
%and 2 lelvs 33-34 at Gibraltar strait.  ignore them for now, and will compress data to save space
for k=1:90;
  nx=1080;ncut1=1260;ncut2=540;ny=2*ncut1+nx+ncut2;nfx=[nx 0 nx ncut2 ncut1];nfy=[ncut1 0 nx nx nx];
  tmp=readbin(fOut,[111578238 1]);
  tic;aout=zeros(nx,ny,nz);toc;         %.000442 sec
  tic;aout(ind(:,6))=tmp;toc;           %1.94176 sec
  tmp=get_aste_tracer(aout(:,:,k)-ain_0(:,:,k),nfx,nfy);tmp(1:nx,nfy(1)+nfy(3)+1:end)=0;
  figure(1);clf;colormap(bbmap);
  mypcolor(tmp');title([num2str(sum(tmp(:))) ', ' num2str(k)]);mycaxis(.001);mythincolorbar;grid;
  clear ijk jx jy;ijk=find(tmp(:)~=0);
  if(length(ijk)>0);jy=floor(ijk/(1080*2))+1;jx=ijk-(jy-1)*(1080*2);hold on;plot(jx,jy,'ks');hold off;end;
  pause;
end;
end;