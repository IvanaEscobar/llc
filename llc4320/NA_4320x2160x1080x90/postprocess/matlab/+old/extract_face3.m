clear all;

nx=1080;ncut1=1260;ncut2=540;ny=2*ncut1+nx+ncut2;nz0=90;nz=90;%80;
ix0=1:nx;iy0=1:ny;iz0=1:nz;Lx=length(ix0);Ly=length(iy0);Lz=length(iz0);
nfx=[nx 0 nx ncut2 ncut1];nfy=[ncut1 0 nx nx nx];
str=[num2str(nx) 'x' num2str(ncut1) 'x' num2str(ncut2) 'x' num2str(nz0)];
i3=1:nx;j3=nfy(1)+1:nfy(1)+nx;

dirRoot=['/work/03901/atnguyen/MITgcm_c67/mysetups/aste_' str '/'];
dirscratch=['/scratch/03901/atnguyen/aste_' str '/'];
%RunStr='run_tides_it0000_pk0001544760_done';%1270800';
RunStr='run_tides_run2_it0000_pk0001544760';
%dirRun=[dirscratch RunStr '/'];%
dirRun=[dirRoot RunStr '/'];
if(~exist(dirRun));error('dirRun not exist');end;
dirOut=[dirRun 'Mean/'];if(~exist(dirOut));mkdir(dirOut);end;


vstr={'THETA','SALT','UVELMASS','VVELMASS','ETANcor'};
%ext ={'STATE','STATE','TRSP','TRSP','STATE'};
ext ={'','','','',''};
hstr={'','','hFacW','hFacS',''};
ddim=[3 3 3 3 2];

%tsstr='0001270815_0001282320';

for ivar=1:size(vstr,2);
%for ivar=size(vstr,2):size(vstr,2);

  fprintf('%s ',vstr{ivar});

  %fIn=[dirRun 'Mean/' vstr{ivar} '_' tsstr '.data'];
  if(~isempty(hstr{ivar}));
    fhf=[dirRun 'GRID/' hstr{ivar} '.data'];
  else;
    fhf='';
  end;

  %fOut=[dirRun 'Mean/' vstr{ivar} '_f3' '_' tsstr '.data'];

  %flist=dir([dirRun 'diags/' ext{ivar} '/' vstr{ivar} '.*.data']);
  flist=dir([dirOut ext{ivar} '/' vstr{ivar} '.*.data']);
  if(length(flist)>0);
    for ifile=1:length(flist);
      %fIn=[dirRun 'diags/' ext{ivar} '/' flist(ifile).name];
      fIn=[dirOut ext{ivar} '/' flist(ifile).name];
      idot=find(flist(ifile).name=='.');idot=idot(1)+1:idot(2)-1;
      tsstr=flist(ifile).name(idot);

      fOut=[dirOut flist(ifile).name(1:idot(1)-2) '_f3' '.' tsstr '.data'];
      if(~exist(fOut));

        fidin =fopen(fIn,'r','b');
        if(~isempty(fhf));fidhf =fopen(fhf,'r','b');end;
        fidout=fopen(fOut,'w','b');
 
        %hf=ones(nx,nx);

        if(ddim(ivar)==3);
          for iz=1:Lz;
    
            if(~isempty(fhf));
              hf=fread(fidhf,[nx,ny],'float32');hf=hf(i3,j3);
              clear ii;ii=find(hf==0);
              hf=1./hf;if(length(ii)>0);hf(ii)=0;end;
            else;
              hf=1;
            end;
    
            a=fread(fidin,[nx,ny],'float32');a=a(i3,j3).*hf;		%if vel, div out hf[W,S] to get abs vel
            fwrite(fidout,a,'float32');
    
            fprintf('%i ',iz);
    
          end;
    
          fclose(fidin);
          fclose(fidout);
          if(~isempty(fhf));fclose(fidhf);end;
          fprintf('%s\n',fOut);

        else;
          a=readbin(fIn,[nx ny]);
          a=a(i3,j3);
%fix bogus points:
          ix=[853,868,870,869,868,869,870,870,869,869,547 ,205,205,209,327,205,879,205,327, 92];
          jy=[213,220,220,219,218,218,218,217,217,216,1042,164,165,166,339,513,925,513,339,827];
          for ijk=1:length(ix);a(ix(ijk),jy(ijk))=0;end;
          a(92,327)=0;a(91,826)=0;	%these 2 points should be open water, but ssh very large 
          figure(1);clf;mypcolor(a');title(ifile);colorbar;grid;pause;
          writebin(fOut,a,1,'real*4');
        end;
      end;%exist(fOut);
    end;%ifile
  end;%lenght(flist)>0
end;%ivar

