clear all;
define_indices;

%% Setting Directories and Domain Info: Escobar's NA setup
dirWork=['/work/05427/iescobar/stampede2/llc/llc4320/NA_4320x2160x1080x90/'];
dirScratch=['/scratch/05427/iescobar/llc/llc4320/NA_4320x2160x1080x90/run_c67h_no_tidal_bc_pk0000000001/'];
dirGrid=[dirWork 'GRID/'];
dirRun=[dirScratch 'diags/'];
if(~exist(dirRun));error('dirrun not exist');end;

nx= id.n.x/2;   % 2160
ny= id.n.y;     % 2160
nz= id.n.z;     % 90
nfx= id.nf.x;   % [2160 0 0 0 1080]
nfy= id.nf.y;   % [1080 0 0 0 2160]

fGrid=[dirGrid 'Index_wet_hfacC_2D.mat'];
  load(fGrid,'ind','i1','i2');%tic;toc;                   %8.7sec
  indC=ind;i1C=i1;i2C=i2;
  LmaxC=size(indC,1);                                     %W: 1942766

fGrid=[dirGrid 'Index_wet_hfacW_2D.mat'];
  load(fGrid,'ind','i1','i2');%tic;toc;                   %8.7sec
  indW=ind;i1W=i1;i2W=i2;
  LmaxW=size(indW,1);                                     %W: 1942766

fGrid=[dirGrid 'Index_wet_hfacS_2D.mat'];                  %
  load(fGrid,'ind','i1','i2');%tic;toc;                   %8.7sec
  indS=ind;i1S=i1;i2S=i2;
  LmaxS=size(indS,1);                                     %S: 1940781

  clear ind i1 i2

for iloop=1:2;
  if(iloop==1);
    str='state_2d_hourly';
  else;
    str='exf_zflux_hourly';
  end;

  dirout=[dirRun  str '_UVcwet/'];if(~exist(dirout));mkdir(dirout);end;

  flist=dir([dirRun  str '_Wwet/*.data']);

  nf=flist(1).bytes/LmaxW/4;
  idot=find(flist(1).name=='.');idot=idot(1)+1:idot(2)-1;

  for ifile=1:length(flist);
    ts=flist(ifile).name(idot)

    fout=[dirout str '_c' num2str(LmaxC) '.' ts '.data'];	%add a "c" to distinguish from true "C" fields

    if(~exist(fout));
      tmpu=readbin([dirRun str '_Wwet/' str '_' num2str(LmaxW) '.' ts '.data'],[LmaxW nf]);
      tmpv=readbin([dirRun str '_Swet/' str '_' num2str(LmaxS) '.' ts '.data'],[LmaxS nf]);
      u=zeros(nx*ny,nf);u(indW(:,6),:)=tmpu;u=reshape(u,nx,ny,nf);
      v=zeros(nx*ny,nf);v(indS(:,6),:)=tmpv;v=reshape(v,nx,ny,nf);

      [aUfc,aVfc]=centering_llcuv_aste(u,v,nfx,nfy);%%tic;toc;    %8.8 -- 9.5sec

%now put back in compact format
      aUc=cat(2,aUfc{1},reshape(aUfc{5},nfy(5),nfx(5),nf));
      aVc=cat(2,aVfc{1},reshape(aVfc{5},nfy(5),nfx(5),nf));
      clear aUfc aVfc

      aUc=reshape(aUc,nx*ny,nf);
      aVc=reshape(aVc,nx*ny,nf);

      aoutU=aUc(indC(:,6),:);%tic;toc;                            %/*}}}*/ , 1.2sec
      aoutV=aVc(indC(:,6),:);%tic;toc;                            %/*}}}*/ , 1.2sec

      clear aUc aVc

      fid=fopen(fout,'w','b');
      for j=1:nf;
        fwrite(fid,aoutU(:,j),'float32');%tic;toc;		%2.1sec
        fwrite(fid,aoutV(:,j),'float32');%tic;toc;		%2.1sec
      end;
      fclose(fid);

      if(mod(ifile,48)==0);fprintf('%i ',ifile);end;
    end;

  end;
  fprintf('\n');
end;
