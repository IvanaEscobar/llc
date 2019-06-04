clear all;
dirGrid=['/work/03901/atnguyen/llc1080/aste_1080x1260x540x90/GRID/'];
nx=1080;ny=1260*2+nx+540;nz=90;nfx=[nx 0 nx 540 1260];nfy=[1260 0 nx nx nx];

dirWork='/work/03901/atnguyen/MITgcm_c67/mysetups/aste_1080x1260x540x90/';
dirScratch='/scratch/03901/atnguyen/aste_1080x1260x540x90/';
%RunStr='run_tides_it0000_pk0001270800';%RunStr='run_tides_it0000_pk0001166400';
%RunStr='run_tides_run2b_it0000_pk0001544760';%RunStr='run_tides_it0000_pk0001166400';
%dirRun=[dirScratch RunStr '/diags/'];
RunStr='run_tides_run2_hourly_it0000_pk0001577880';
dirRun=[dirWork RunStr '/diags/'];
if(~exist(dirRun));error('dirrun not exist');end;

%varstrin={'state_3d_set1','state_3d_set1','trsp_3d_set1','trsp_3d_set1'};%'state_3d_set1',
%varstrin={'state_3d_daily','state_3d_daily','trsp_3d_daily','trsp_3d_daily'};
varstrin={'state_3d_hourly','state_3d_hourly','trsp_3d_hourly','trsp_3d_hourly'};
ext     ={'STATE/','STATE/','TRSP/','TRSP/'};%'STATE/',
varstrout={'THETA','SALT','UVELMASS','VVELMASS'};%'RHOAnoma',
varstr_wetpt={'C','C','W','S'};		%hfac[C,W,S], %,'C'
%sometimes, write file not full depth to nz, but only to nz1:
nzoffset=[0 1 0 1].*nz;%2 


%use_method=1;		%split iz
use_method=0;		%read the whole file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for ivar=1:size(varstrin,2);
for ivar=2:2;%size(varstrin,2);

  clear flist

  flist=dir([dirRun ext{ivar} varstrin{ivar} '.*.data']);if(length(flist)==0);error('flist missing');end;
  idot=find(flist(1).name=='.');idot=idot(1)+1:idot(2)-1;

%determining nz1 from meta file:
  meta=rdmds_meta([dirRun ext{ivar} flist(1).name(1:end-5)]);
  if(meta.nDims==2);nz1=1;else;nz1=meta.dimList(7);end;			%83 or 80

  dirOut=[dirRun varstrout{ivar} '_wet/'];if(~exist(dirOut));mkdir(dirOut);end;
  fGrid=[dirGrid 'Index_wet_hfac' varstr_wetpt{ivar} '.mat'];
  if(~exist(fGrid));error('fGrid wet pt missing, run get_wet_points.m first\n');end;
  fprintf('%s ',varstrout{ivar});
  t1=clock;load(fGrid,'ind','i1','i2'); fprintf('%g ',etime(clock,t1));	%40sec to load
  Lmax=size(ind,1);

  izv=[1:nz1]+nzoffset(ivar);

  istart=1;%if(ivar==1);istart=83;else;istart=1;end;
  for ifile=istart:length(flist);					%89sec / file
    %tic
    ts=flist(ifile).name(idot);

    fOut=[dirOut varstrout{ivar} '_' sprintf('%i',Lmax) '.' ts '.data'];%10sec to write

    if(~exist(fOut));

      t1=clock;
      if(use_method==1);
        aout=zeros(Lmax,1);	%memory for just wet point, note this is to all 90 vertical lev %/*{{{*/
        for iz=1:nz1;
          clear a ii ioffset
          a=read_slice([dirRun ext{ivar} flist(ifile).name],nx,ny,izv(iz));
          ii=i1(6,iz):i2(6,iz);
          ioffset=(iz-1)*nx*ny;
          aout(ii,1)=a(ind(ii,6)-ioffset);
        end;								%23 sec to read 90 lev  %/*}}}*/
      elseif(use_method==0);						%47sec / file
        clear ain aout							%/*{{{*/
        aout=zeros(Lmax,1);						%all 90 vertical levels
        ain=read_slice([dirRun ext{ivar} flist(ifile).name],nx,ny,izv);	%21sec to read all 90
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
    dirIn=[dirRun varstrout{ivar} '_wet/'];
    dirOut=dirIn;
    flist1=dir([dirIn varstrout{ivar} '_' sprintf('%i',Lmax) '.*.data']);
    idot1=find(flist1(1).name=='.');idot1=idot1(1)+1:idot1(2)-1;
    for ifile1=1:5;
      ts=flist1(ifile1).name(idot1);
      tic;ain=readbin([dirIn flist1(ifile1).name],[1 Lmax]);toc;	%8.5sec to read
      tic;aout=zeros(nx,ny,nz);toc;					%0.02sec
      tic;aout(ind(:,6))=ain;toc;					%6.2sec
      tic;writebin([dirOut varstrout{ivar} '.' ts '.data'],aout,1,'real*4');toc;%35sec
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
    dirIn=[dirRun varstrout{ivar} '/'];
    dirOut=dirIn;
    flist1=dir([dirIn varstrout{ivar} '_' sprintf('%i',Lmax) '.*.data']);
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

