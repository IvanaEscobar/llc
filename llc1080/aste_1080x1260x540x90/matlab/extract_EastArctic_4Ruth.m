clear all;
addpath('~/matlab/gcmfaces/gcmfaces_IO/');
nx=1080;ny=1260*2+nx+540;nz=90;nfx=[nx 0 nx 540 1260];nfy=[1260 0 nx nx nx];

i3=1:nfx(3);
j3=nfy(1)+1:nfy(1)+nfy(3);
nz1=80;				%printed out only 80 vertical lev

ix=116:515;Lx=length(ix);	%400
jy=171:600;Ly=length(jy);	%430
nz2=76;				%just need 76 vert lev to 3500m for now

use_method=0;			%0=read slice 1= full file

%dirScratch='/scratch/03901/atnguyen/aste_1080x1260x540x90/';
dirScratch='/scratch/atnguyen/aste_1080x1260x540x90/';
RunStr='run_tides_it0000_pk0001270800';
dirRun=[dirScratch RunStr '/diags/'];

varsin={'state_3d_set1','trsp_3d_set1','trsp_3d_set1','state_2d_set1'};
varsout={'RHOAnoma','UVELMASS','VVELMASS','SIarea'};
ext   ={'STATE/','TRSP/','TRSP/','STATE/'};

for ivar=size(varsin,2):size(varsin,2);

  fprintf('%s ',varsout{ivar});

  flist=dir([dirRun ext{ivar} varsin{ivar} '.*.data']);
  idot=find(flist(1).name=='.');idot=idot(1)+1:idot(2)-1;

  dirOut=[dirRun varsout{ivar} '_EastArctic/'];
  if(~exist(dirOut));mkdir(dirOut);end;
  
  meta=rdmds_meta([dirRun ext{ivar} flist(1).name(1:end-5)]);
  for j=1:meta.nFlds
    if(strcmp(strtrim(meta.fldList{j}),varsout{ivar}));
      varind=j;
    end;
  end;
  if(strcmp(meta.dataprec,'float32')); preclength=4;
  elseif(strcmp(meta.dataprec,'float64'));preclength=8;
  else;error('can not determine precision');
  end
  %if(meta.nDims~=3);error('wrong dim for input files, need to be 3');end;
  if(meta.nDims==2);		%the 3rd dimension is 1
    meta.dimList=[meta.dimList 1];	%add 3rd dim
  end;
  zoff=(varind-1)*meta.dimList(7);
  izv=[1:meta.dimList(7)];%+zoff;

  for ifile=1:length(flist);

    clear a aout tmp

    ts=flist(ifile).name(idot);
    fOut=[dirOut varsout{ivar} '.' ts '.data'];

    aout=zeros(Lx,Ly,meta.dimList(7));
    %t1=clock;
    if(~exist(fOut));

      if(use_method==1);
        %tic;
        tmp=read_slice([dirRun ext{ivar} flist(ifile).name],nx,ny,izv+zoff);
        %toc;	%30sec
        tmp=tmp(i3,j3,1:nz2);
        aout=tmp(ix,jy,:);

      elseif(use_method==0);

        fid=fopen([dirRun ext{ivar} flist(ifile).name],'r','b');

        skip = (zoff)*nx*ny;
        if(fseek(fid,skip*preclength,'bof')<0), error('past end of file'); end;	%0.0014 sec

        %tic;
        for iz=1:min(nz2,length(izv));

          tmp=fread(fid,nx*ny,meta.dataprec);tmp=reshape(tmp,nx,ny);
          tmp=tmp(i3,j3);
          tmp=tmp(ix,jy);
          aout(:,:,iz)=tmp;
        end;									%27sec
        %toc;
        fclose(fid);
      end;
      %tic;
      writebin(fOut,aout,1,'real*4');
      %toc;					%1.2sec

    end;%exist(fOut)
    %t2=clock;

    %if(ifile==1|mod(ifile,24)==0|ifile==length(flist));
    %  fprintf('%i %f ',[ifile etime(t2,t1)]);
    %end;

  end;%ifile
 
end;%ivar

