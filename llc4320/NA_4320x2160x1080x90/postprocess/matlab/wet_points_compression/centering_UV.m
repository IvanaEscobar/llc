%% Storing velocity to center indices [Uc,Vc], to match with mooring data.
clear all;
define_indices; 

%% Setting Directories and Domain Info: Escobar's NA setup
dirWork=['/work/05427/iescobar/stampede2/llc/llc4320/NA_4320x2160x1080x90/'];
dirScratch=['/scratch/05427/iescobar/llc/llc4320/NA_4320x2160x1080x90/run_c67h_no_tidal_bc_pk0000000001/'];
dirGrid=[dirWork 'GRID/'];
dirRun=[dirScratch 'diags/'];
if(~exist(dirRun));error('dirrun not exist');end;
dirRunW=dirRun;

nx= id.n.x/2;   % 2160
ny= id.n.y;     % 2160
nz= id.n.z;     % 90
nfx= id.nf.x;   % [2160 0 0 0 1080]
nfy= id.nf.y;   % [1080 0 0 0 2160]

%% Picking Diagnostics to Compress: see *.meta for info on diags
diagVar={'UVELMASS','VVELMASS'};
varWetpt={'W','S'};		%hfac[C,W,S]
%sometimes, write file not full depth to nz, but only to nz1:

fGridU=[dirGrid 'Index_wet_hfac' varWetpt{1} '.mat'];
fGridV=[dirGrid 'Index_wet_hfac' varWetpt{2} '.mat'];
fGridC=[dirGrid 'Index_wet_hfacC.mat'];

%note: since we have to read in the [U,V]VELMASS full fields anyway, should just extract wet here to save time
  if(~exist(fGridU));error('fGrid wet pt missing, run get_wet_points.m first\n');end;
  load(fGridC,'ind'); indC=ind;LmaxC=size(indC,1); clear ind;%t1=clock;%111578238, 9.9sec, 12.4sec
  %if(read_wet);
  load(fGridU,'ind'); indU=ind;LmaxU=size(indU,1); clear ind;%t1=clock;%110767778, 9.2sec, 12.2sec
  load(fGridV,'ind'); indV=ind;LmaxV=size(indV,1); clear ind;%t1=clock;%110664810, 9.4sec, 12.1sec
  %end;

  diroutU =[dirRunW diagVar{1} '_wet/'];if(~exist(diroutU));mkdir(diroutU);end;
  diroutV =[dirRunW diagVar{2} '_wet/'];if(~exist(diroutV));mkdir(diroutV);end;
  diroutUc=[dirRunW diagVar{1} 'c_wet/'];if(~exist(diroutUc));mkdir(diroutUc);end;
  diroutVc=[dirRunW diagVar{2} 'c_wet/'];if(~exist(diroutVc));mkdir(diroutVc);end;

%do a first quick loop to check size and delete inconsistent files:
  for iloop=1:4;
        if(iloop==1);dirin=diroutU ;L=LmaxU;
    elseif(iloop==2);dirin=diroutV ;L=LmaxV;
    elseif(iloop==3);dirin=diroutUc;L=LmaxC;
    else;            dirin=diroutVc;L=LmaxC;end;

    flist=dir([dirin '*.data']);
    if(length(flist)>0);
      for j=1:length(flist);
        if(flist(j).bytes/L/4~=1);
          clear str
          str=['system(''rm -f ' dirin flist(j).name ''')'];
          eval(str);
          fprintf('%s\n ',str);
        end;
      end;
    end;
  end;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  clear flist

read_wet=0;

  if(read_wet);
    flist=dir([dirRun diagVar{1} '_wet/' diagVar{1} '*.*.data']);if(length(flist)==0);error('flist missing');end;
  else;
    extTr='';flist=dir([dirRun extTr  'trsp_3d_hourly.*.data']);
    if(length(flist)==0);extTr='trsp_3d/';flist=dir([dirRun extTr  'trsp_3d_hourly.*.data']);
      if(length(flist)==0);error('flist missing');end;
    end;
  end;
  idot=find(flist(1).name=='.');idot=idot(1)+1:idot(2)-1;
  
  % istart=1;
  %for ifile=length(flist):-1:istart;
  for ifile=1:length(flist);%:-1:istart;	
    %tic
    ts=flist(ifile).name(idot)

    fOutU =[diroutU diagVar{1} '_' sprintf('%i',LmaxU) '.' ts '.data'];
    fOutV =[diroutV diagVar{2} '_' sprintf('%i',LmaxV) '.' ts '.data'];
    fOutUc=[diroutUc diagVar{1} 'c_' sprintf('%i',LmaxC) '.' ts '.data'];
    fOutVc=[diroutVc diagVar{2} 'c_' sprintf('%i',LmaxC) '.' ts '.data'];

    if(~exist(fOutUc)|~exist(fOutVc)|~exist(fOutU)|~exist(fOutV));

      t1=clock;%47sec / file
      clear ainU aoutU aU3D aUf aUfc ainV aoutV aV3D aVf aVfc		%/*{{{*/

     if(read_wet);
      ainU=readbin([dirRun diagVar{1} '_wet/' diagVar{1} '_' num2str(LmaxU) '.' ts '.data'],[LmaxU 1]);%tic;toc;%2.6sec
      ainV=readbin([dirRun diagVar{2} '_wet/' diagVar{2} '_' num2str(LmaxV) '.' ts '.data'],[LmaxV 1]);%tic;toc;%2.4sec

      aU3D=zeros(nx,ny,nz);aU3D(indU(:,6))=ainU;%tic;toc;		%1.5sec
      aV3D=zeros(nx,ny,nz);aV3D(indV(:,6))=ainV;%tic;toc;		%1.5sec

%clear memory:
      clear ainU ainV

     else;
      aU3D=read_slice([dirRun extTr flist(ifile).name],nx,ny,1:nz);     %tic;toc;	%6.5sec
      aV3D=read_slice([dirRun extTr flist(ifile).name],nx,ny,[1:nz]+nz);%tic;toc;	%6.5sec

%extract wetpt right here:
      if(~exist(fOutU)|~exist(fOutV));
        clear tmp;tmp=aU3D(indU(:,6));writebin(fOutU,tmp,1,'real*4');clear tmp
        clear tmp;tmp=aV3D(indV(:,6));writebin(fOutV,tmp,1,'real*4');clear tmp
      end;
     end;

%split into faces to get center, what an annoyance for the llc grid, clear 3D to save mem
     if(~exist(fOutUc)|~exist(fOutVc));
      [aUfc,aVfc]=centering_llcuv_aste(aU3D,aV3D,nfx,nfy);%%tic;toc;	%8.8 -- 9.5sec

%now put back in compact format
      aUc=cat(2,aUfc{1},reshape(aUfc{5},nfy(5),nfx(5),nz));
      aVc=cat(2,aVfc{1},reshape(aVfc{5},nfy(5),nfx(5),nz));
      clear aUfc aVfc

      %aoutU=zeros(LmaxC,1);					%all 90 vertical levels
      %aoutV=zeros(LmaxC,1);					%all 90 vertical levels
      aoutU=aUc(indC(:,6));%tic;toc;				%/*}}}*/ , 1.2sec
      aoutV=aVc(indC(:,6));%tic;toc;				%/*}}}*/ , 1.2sec

      clear aUc aVc

      writebin(fOutUc,aoutU,1,'real*4');%tic;toc;			%2.1sec
      writebin(fOutVc,aoutV,1,'real*4');%tic;toc;			%2.1sec
      t2=clock;
      if(mod(ifile,12)==0);fprintf('%i %g ',[ifile etime(t2,t1)]);end;%25.7sec on stampede2, 47.4sec on ls5, per pair-of-file
     end;
    end;
    %toc   
  end;
  fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
