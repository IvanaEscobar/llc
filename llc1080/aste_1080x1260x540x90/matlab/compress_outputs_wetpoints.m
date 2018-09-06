clear all;
dirGrid=['/work/03901/atnguyen/llc1080/aste_1080x1260x540x90/GRID/'];
nx=1080;ny=1260*2+nx+540;nz=90;nfx=[nx 0 nx 540 1260];nfy=[1260 0 nx nx nx];

dirScratch='/scratch/03901/atnguyen/aste_1080x1260x540x90/';
RunStr='run_tides_it0000_pk0001270800';%RunStr='run_tides_it0000_pk0001166400';
dirRun=[dirScratch RunStr '/diags/'];

varstrin={'state_3d_set1','state_3d_set1','state_3d_set1','trsp_3d_set1','trsp_3d_set1'};
ext     ={'STATE/','STATE/','STATE/','TRSP/','TRSP/'};
varstrout={'THETA','SALT','RHOAnoma','UVELMASS','VVELMASS'};
varstr_wetpt={'C','C','C','W','S'};		%hfac[C,W,S]
%%%% IMPORTANT %%%%%%%
%sometimes, write file not full depth to nz, but only to nz1:
nzoffset=[0 1 2 0 1].*nz;


%use_method=1;		%split iz
use_method=0;		%read the whole file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ivar=1:size(varstrin,2);

  clear flist

  flist=dir([dirRun ext{ivar} varstrin{ivar} '.*.data']);
  idot=find(flist(1).name=='.');idot=idot(1)+1:idot(2)-1;

%determining nz1 from meta file:
  meta=rdmds_meta([dirRun ext{ivar} flist(1).name(1:end-5)]);
  if(meta.nDims==2);nz1=1;else;nz1=meta.dimList(7);end;			%83 or 80

  dirOut=[dirRun varstrout{ivar} '/'];if(~exist(dirOut));mkdir(dirOut);end;
  fGrid=[dirGrid 'Index_wet_hfac' varstr_wetpt{ivar} '.mat'];
  fprintf('%s ',varstrout{ivar});
  t1=clock;load(fGrid,'ind','i1','i2'); fprintf('%g ',etime(clock,t1));	%40sec to load
  Lmax=size(ind,1);

  izv=[1:nz1]+nzoffset(ivar);

  if(ivar==1);istart=83;else;istart=1;end;
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
    dirIn=[dirRun varstrout{ivar} '/'];
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
