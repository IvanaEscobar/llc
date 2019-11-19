clear all;
define_indices; 
rmpath('/home1/03901/atnguyen/matlab/gcmfaces/gcmfaces_IO/');
warning off

%% Setting Directories and Domain Info: Escobar's NA setup
dirWork='/work/05427/iescobar/stampede2/llc/llc4320/NA_4320x2160x1080x90/';
dirScratch='/scratch/05427/iescobar/llc/llc4320/NA_4320x2160x1080x90/run_c67h_tidal_bc_pk0000000001/';
dirGrid=[dirWork 'GRID/'];
dirRun=[dirScratch 'diags/state_2d/'];
if(~exist(dirRun));error('dirrun not exist');end;
dirRunW=[dirRun '../']; %An put this dir in a $WORK path

nx= id.n.x/2;   % 2160
ny= id.n.y;     % 2160
nz= id.n.z;     % 90
nfx= id.nf.x;   % [2160 0 0 0 1080]
nfy= id.nf.y;   % [1080 0 0 0 2160]

%% Picking Diagnostics to Compress: see *.meta for info on diags
diagIn  ={'state_2d_hourly'};
diagVarC={'ETAN','ETANSQ','DETADT2','PHIBOT','sIceLoad','MXLDEPTH',...
            'RSURF','oceQnet','oceFWflx'};
diagVarW={'oceTAUX'};
diagVarS={'oceTAUY'};
varWetpt={'C','W','S'};		%hfac[C,W,S]
%diagId*: index of the diagVar Can be found in *.meta fldList
diagIdC =[1:9];
diagIdW =[10];
diagIdS =[11];

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

%do a first quick loop to check size and delete inconsistent files:
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

%determining nz1 from meta file:
meta=rdmds_meta([dirRun flist(1).name(1:end-5)]);

for ifile=1:length(flist);
  ts=flist(ifile).name(idot)

%use the last file to make sure all other fields have to exist:
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

      if(ii==1);aout=nan(Lmax,length(id)+1);else;aout=nan(Lmax,length(id));end;
      aout(:,1:length(id))=tmp1(ind(:,6),:);

%%make ETANcor
%   ietan=1;iheff=3;ihsnow=4;
%      if(ii==1);
%        aout(:,length(id)+1)=aout(:,ietan)+aout(:,iheff).*ice2wtr+aout(:,ihsnow).*snow2wtr;
%%fix bogus points:
%        a=zeros(nx,ny);a(ind(:,6))=aout(:,length(id)+1);			%/*{{{*/
%
%        %face1
%        ix=208;jy=1086;a(ix,jy)=0;%this should be 0, but have some crazy value
%        %face3
%        ix=[853,868,870,869,868,869,870,870,869,869,547 ,205,205,209,327,205,879,205,327, 92];
%        jy=[213,220,220,219,218,218,218,217,217,216,1042,164,165,166,339,513,925,513,339,827];
%        yshift=ncut1;
%        for ijk=1:length(ix);a(ix(ijk),jy(ijk)+yshift)=0;end;
%        a(92,327+yshift)=0;a(91,826+yshift)=0;%these 2 points should be open water, but ssh very large 
%        %f4
%        f4a=reshape(a(:,ncut1+nx+1:ncut1+nx+ncut2),ncut2,nx);
%        ix=[313,431,327];
%        jy=[253,620,788];
%        for ijk=1:length(ix);f4a(ix(ijk),jy(ijk))=0;end;
%        a(:,ncut1+nx+1:ncut1+nx+ncut2)=reshape(f4a,nx,ncut2);
%        %f5
%        f5a=reshape(a(:,ncut1+nx+ncut2+1:ncut1+nx+ncut2+ncut1),ncut1,nx);
%        ix=[ 31  30 664 614 614 327 402 402   94 674 733 1018 1019 1016 1016 1017 1017 1017 1017 1021];
%        jy=[669 670 680 717 718 784 824 827 1080 668 628  481  481  676  677  677  678  679  680  651];
%        for ijk=1:length(ix);f5a(ix(ijk),jy(ijk))=0;end;
%        a(:,ncut1+nx+ncut2+1:ncut1+nx+ncut2+ncut1)=reshape(f5a,nx,ncut1);	%%/*}}}*/
%        aout(:,length(id)+1)=a(ind(:,6));
%      end;

      fOutW=[dirOutW{ii} diagIn{1} '_' num2str(length(ind)) '.' ts '.data'];
      writebin(fOutW,aout,1,'real*4');%tic;toc;
    end;
    if(ifile==1|mod(ifile,60)==0|ifile==length(flist));fprintf('%i ',ifile);end;
  end;
end;
