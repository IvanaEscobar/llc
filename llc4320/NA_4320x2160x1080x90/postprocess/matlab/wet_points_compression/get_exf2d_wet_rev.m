clear all;
define_indices; 
rmpath('/home1/03901/atnguyen/matlab/gcmfaces/gcmfaces_IO/');
warning off

%% Set Directories and Domain Info: Escobar's NA setup
dirWork='/work/05427/iescobar/stampede2/llc/llc4320/NA_4320x2160x1080x90/';
dirScratch='/scratch/05427/iescobar/llc/llc4320/NA_4320x2160x1080x90/run_c67h_no_tidal_bc_pk0000000001/';
dirGrid=[dirWork 'GRID/'];
dirRun=[dirScratch 'diags/exf_zflux/'];
if(~exist(dirRun));error('dirrun not exist');end;
dirRunW=[dirRun '../']; %An put this dir in a $WORK path

nx= id.n.x;     % 2160
ny= id.n.y;     % 2160
nz= id.n.z;     % 90
nfx= id.nf.x;   % [2160 0 0 0 1080]
nfy= id.nf.y;   % [1080 0 0 0 2160]

%% Pick Diagnostics to Compress: see *.meta for info on diags
diagIn  ={'exf_zflux_hourly'};
diagVarC={'EXFpreci','EXFevap','EXFroff','EXFempmr','EXFswdn','EXFlwdn',...
          'EXFswnet','EXFlwnet','EXFqnet','EXFatemp',...
          'EXFaqh','EXFpress','EXFhs','EXFhl','EXFsnow','EXFtidep'};
diagVarW={'EXFtaux','EXFuwind'};
diagVarS={'EXFtauy','EXFvwind'};
varWetpt={'C','W','S'};		%hfac[C,W,S]
%diagId*: index of the diagVar Can be found in *.meta fldList
diagIdC =[1:11 16:20];
diagIdW =[12 14];
diagIdS =[13 15];

%% Load 2D wet grid info
fIndGrid=[dirGrid 'Index_wet_hfacC_2D.mat'];
tic;load(fIndGrid,'ind');toc;indC=ind;LmaxC=length(indC);clear ind;
fIndGrid=[dirGrid 'Index_wet_hfacW_2D.mat'];
tic;load(fIndGrid,'ind');toc;indW=ind;LmaxW=length(indW);clear ind;
fIndGrid=[dirGrid 'Index_wet_hfacS_2D.mat'];
tic;load(fIndGrid,'ind');toc;indS=ind;LmaxS=length(indS);clear ind;

for ii=1:3;
  dirOutW{ii}=[dirRunW diagIn{1} '_' varWetpt{ii} 'wet/'];if(~exist(dirOutW{ii}));mkdir(dirOutW{ii});end;
end;
clear varWetpt;

% Check size and delete inconsistent files:
for ii=1:3;
      if(ii==1);dirin=dirOutW{ii} ;L=LmaxC;Lid=length(diagIdC)+1;
  elseif(ii==2);dirin=dirOutW{ii} ;L=LmaxW;Lid=length(diagIdW);
  elseif(ii==3);dirin=dirOutW{ii} ;L=LmaxS;Lid=length(diagIdS);end;

  flistp=dir([dirin '*.data']);
  if(length(flistp)>0);
    for j=1:length(flistp);
      if(flistp(j).bytes/L/Lid/4~=1);
        clear str
        str=['system(''rm -f ' dirin flistp(j).name ''')'];
        eval(str);
        fprintf('%s\n ',str);
      end;
    end;
  end;
end;
  
%% Save only wet point 2D State diagnostics
flist=dir([dirRun diagIn{1} '.*.data']);%tic;toc;
idot=find(flist(1).name=='.');idot=idot(1)+1:idot(2)-1;

% Determine nz1 from meta file:
meta=rdmds_meta([dirRun flist(1).name(1:end-5)]);

istart=1;
for ifile=length(flist):-1:istart;
  ts=flist(ifile).name(idot)

% use the last file to make sure all other fields have to exist:
  fOutW0=[dirOutW{3} diagIn{1} '_' num2str(LmaxS) '.' ts '.data'];
  if(~exist(fOutW0));

    clear tmp
    tmp=readbin([dirRun flist(ifile).name],[nx,ny,meta.nFlds]);%toc;%read in everything, 3sec
    tmp=reshape(tmp,nx*ny,meta.nFlds);

    for ii=1:3;
      clear diagVar varWetpt id ind
          if(ii==1);diagVar=diagVarC;ind=indC;varWetpt='C';id=diagIdC;
      elseif(ii==2);diagVar=diagVarW;ind=indW;varWetpt='W';id=diagIdW;
      elseif(ii==3);diagVar=diagVarS;ind=indS;varWetpt='S';id=diagIdS;end;
      Lmax=length(ind);

      clear tmp1 aout
      tmp1=tmp(:,id);

      clear aout;aout=tmp1(ind(:,6),:);

      fOutW=[dirOutW{ii} diagIn{1} '_' num2str(length(ind)) '.' ts '.data'];
      writebin(fOutW,aout,1,'real*4');%tic;toc;
    end;
    if(ifile==1|mod(ifile,60)==0|ifile==length(flist));fprintf('%i ',ifile);end;
  end;
end;
