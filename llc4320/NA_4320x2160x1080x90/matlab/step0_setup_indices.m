clear all;
warning off

%----- define size, grid ---------
define_indices;

%-- define input and output dir
set_directory;
dirOut=dirs.child.OBCS;

%nfx0=[nx0 0 nx0 180   450];   nfy0=[  450 0 nx0 nx0 nx0];
%nfx =[nx  0 nx  ncut2 ncut1]; nfy =[ncut1 0 nx  nx  nx];

nfx0_full=[nx0 0 0 0 3*nx0]; nfy0_full=[3*nx0 0 0 0 nx0];

%------ load grid -------------
fieldstr={'xc','yc','xg','yg','dxg','dyg'};
indfield=[  1    2    6    7    15    16];

for iface=[1:5]
  if(nfx0(iface)>0 & nfy0(iface)>0);
        if(iface==1);nxa=nx0;nya=3*nx0;ixa=1:nxa;iya=nya-nfy0(iface)+1:nya;%these indices are from global llc
    elseif(iface==3);nxa=nx0;nya=nx0;  ixa=1:nfx0(iface);iya=1:nya;
    else;            nxa=3*nx0;nya=nx0;ixa=1:nfx0(iface);iya=1:nya;end;
    for ifld=1:size(fieldstr,2);
      clear temp tmp1
      temp=read_slice([dirs.parent.Grid0_global 'tile00' num2str(iface) '.mitgrid'],...
                       nxa+1,nya+1,indfield(ifld),'real*8');			%global
      eval(['mygrid0.' fieldstr{ifld} '{iface}=temp(ixa,iya);']);		%aste
    end;
  end;
end;

mygrid1=[];
for iface=[1:5]
  if(nfx(iface)>0 & nfy(iface)>0);
        if(iface==1);nxa=nfx(iface);nya=nfy(iface);ixa=1:nxa;iya=1:nya;		%these indices are from cut mitgrid
    elseif(iface==3);nxa=nfx(iface);nya=nfy(iface);ixa=1:nxa;iya=1:nya;
    else;            nxa=nfx(iface);nya=nfy(iface);ixa=1:nxa;iya=1:nya;end;

    for ifld=1:size(fieldstr,2);
      temp=read_slice([dirs.Grid1 'tile' sprintf('%3.3i',iface) '.mitgrid'],...
                       nfx(iface)+1,nfy(iface)+1,indfield(ifld),'real*8');
      eval(['mygrid1.' fieldstr{ifld} '{iface}=temp(ixa,iya);']);		%regional
    end;
  end;
end

%-------- MANUAL PART: define for EACH ob ------------------
obcstype=['NSEW'];

fieldIn0=[];
fieldIn =[];

for iobcs=1:5;
  fieldIn0=[];fieldIn=[];
  fieldOut0=[];fieldOut=[];
  obcs0{iobcs}=[];obcs{iobcs}=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%% 1: Atlantic, South, Face 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(iobcs==1);
%26.9236 degN Atlantic
  fieldIn0.name='Face1_Atlantic26p9236degN_South';
  fieldIn0.obcsstr='S';
  fieldIn0.obcstype=find(obcstype==fieldIn0.obcsstr);
  fieldIn0.face=1;
  fieldIn0.nx=nx0;							% 270
  fieldIn0.nfx=nfx0;							% [270 0 270 180 450]
  fieldIn0.nfy=nfy0;							% [450 0 270 270 270]
  fieldIn0.sshiftx=(nfx0_full(fieldIn0.face)-nfx0(fieldIn0.face));	% 0
  fieldIn0.sshifty=(nfy0_full(fieldIn0.face)-nfy0(fieldIn0.face));	% 360

  clear ix;eval(['ix=ix' num2str(fieldIn0.face) '_0;']);				%global
  clear iy;eval(['iy=iy' num2str(fieldIn0.face) '_0;']);				%global
  fieldIn0.ix=ix;				% [1:135] global 

%move 1 pt up so that we're not at the southern edge of highres at the outer point (1st wt pt), 
  fieldIn0.pad=1;
  if(fieldIn0.obcsstr=='N');
    fieldIn0.jy=(iy(end)-fieldIn0.pad).*ones(size(fieldIn0.ix));
  elseif(fieldIn0.obcsstr=='S');
    fieldIn0.jy=(iy(1)+fieldIn0.pad).*ones(size(fieldIn0.ix));		% [227] aste, [587] global , 1st wtpt
  end;

  fieldIn0.imask = ones(size(fieldIn0.ix));	% [1 x 135], use all width, not blanking out any grid cell
% tmp=rdmds(['/scratch/atnguyen/aste_270x450x180/GRID/hFacC']);tmp=reshape(tmp,270,1350,50);
% figure(2);clf;;mypcolor(tmp(:,1:450,1)');colorbar;grid;hold on;plot([1 135],[227 227],'k-');hold off;
  fieldIn0.imask(75:length(fieldIn0.ix))=0;	% load in hFacC (see above 2 lines), from 75to135: Africa
  sz0=size(fieldIn0.imask);if(sz0(2)==1&sz0(1)>sz0(2));fieldIn0.imask=fieldIn0.imask';end;     %make into row

  fieldIn.name=fieldIn0.name;
  clear ix;eval(['ix=ix' num2str(fieldIn0.face) ';']);
  clear iy;eval(['iy=iy' num2str(fieldIn0.face) ';']);
  fieldIn.obcsstr=fieldIn0.obcsstr;
  fieldIn.obcstype=fieldIn0.obcstype;
  fieldIn.face=fieldIn0.face;
  fieldIn.nx=nx;							% 4320
  fieldIn.nfx=nfx;							% [2160 0 0 0 1080]
  fieldIn.nfy=nfy;							% [1080 0 0 0 2160]
  fieldIn.sshiftx=ix(1)-1;						% 0
  fieldIn.sshifty=iy(1)-1;						% 9377-1=9376
  fieldIn.ix=(fieldIn0.ix(1)-1)*fac+1:fieldIn0.ix(end)*fac;		% global [1 2160]

  if(fieldIn0.obcsstr=='N');
    fieldIn.jy=((fieldIn0.jy(1)-1)*fac+1).*ones(size(fieldIn.ix));
  elseif(fieldIn0.obcsstr=='S');
    fieldIn.jy=(fieldIn0.jy(1)*fac).*ones(size(fieldIn.ix));		% global 9392, (1st wet pt)
  end
  fieldIn.imask=repmat(fieldIn0.imask',[1 fac]);fieldIn.imask=reshape(fieldIn.imask',1,fac*max(sz0));
  fieldIn.flag_case=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%% 2: Atlantic, North, Face 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif(iobcs==2);
%43.4141 degN Atlantic
  fieldIn0.name='Face1_Atlantic43p4141degN_North';
  fieldIn0.obcsstr='N';
  fieldIn0.obcstype=find(obcstype==fieldIn0.obcsstr);
  fieldIn0.face=1;
  fieldIn0.nx=nx0;							% 270
  fieldIn0.nfx=nfx0;							% [270 0 270 180 450]
  fieldIn0.nfy=nfy0;							% [450 0 270 270 270]
  fieldIn0.sshiftx=(nfx0_full(fieldIn0.face)-nfx0(fieldIn0.face));	% 0
  fieldIn0.sshifty=(nfy0_full(fieldIn0.face)-nfy0(fieldIn0.face));	% 360

  clear ix;eval(['ix=ix' num2str(fieldIn0.face) '_0;']);				%global
  clear iy;eval(['iy=iy' num2str(fieldIn0.face) '_0;']);				%global
  fieldIn0.ix=ix;				% [1:135] global 

%move 1 pt up so that we're not at the southern edge of highres at the outer point (1st wt pt)
  fieldIn0.pad=1;
  if(fieldIn0.obcsstr=='N');
    fieldIn0.jy=(iy(end)-fieldIn0.pad).*ones(size(fieldIn0.ix));	%[293] aste [653] global, 1st wet pt
  elseif(fieldIn0.obcsstr=='S');
    fieldIn0.jy=(iy(1)+fieldIn0.pad).*ones(size(fieldIn0.ix));
  end;

  fieldIn0.imask = ones(size(fieldIn0.ix));	% [1 x 135], use all width, not blanking out any grid cell
% tmp=rdmds(['/scratch/atnguyen/aste_270x450x180/GRID/hFacC']);tmp=reshape(tmp,270,1350,50);
% figure(2);clf;;mypcolor(tmp(:,1:450,1)');colorbar;grid;hold on;plot([1 135],[293 293],'k-');hold off;
  fieldIn0.imask(90:135)=0;			% load in hFacC (see 2 lines above), 90:135: Spain
  sz0=size(fieldIn0.imask);if(sz0(2)==1&sz0(1)>sz0(2));fieldIn0.imask=fieldIn0.imask';end;      % make into row

  fieldIn.name=fieldIn0.name;
  clear ix;eval(['ix=ix' num2str(fieldIn0.face) ';']);
  clear iy;eval(['iy=iy' num2str(fieldIn0.face) ';']);
  fieldIn.obcsstr=fieldIn0.obcsstr;
  fieldIn.obcstype=fieldIn0.obcstype;
  fieldIn.face=fieldIn0.face;
  fieldIn.nx=nx;							% 4320
  fieldIn.nfx=nfx;							% [2160 0 0 0 1080]
  fieldIn.nfy=nfy;							% [1080 0 0 0 2160]
  fieldIn.sshiftx=ix(1)-1;						% 0
  fieldIn.sshifty=iy(1)-1;						% 9377-1=9376
  fieldIn.ix=(fieldIn0.ix(1)-1)*fac+1:fieldIn0.ix(end)*fac;		% global [1 2160]

  if(fieldIn0.obcsstr=='N');
    fieldIn.jy=((fieldIn0.jy(1)-1)*fac+1).*ones(size(fieldIn.ix));	%global 10433 (1st wet pt)
  elseif(fieldIn0.obcsstr=='S');
    fieldIn.jy=(fieldIn0.jy(1)*fac).*ones(size(fieldIn.ix));		%
  end
  fieldIn.imask=repmat(fieldIn0.imask',[1 fac]);fieldIn.imask=reshape(fieldIn.imask',1,fac*max(sz0));
  fieldIn.flag_case=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%% Atlantic, East, Face 5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif(iobcs==3);
%26.9236 degN Atlantic
  fieldIn0.name='Face5_Atlantic26p9236degN_East';
  fieldIn0.obcsstr='E';
  fieldIn0.obcstype=find(obcstype==fieldIn0.obcsstr);
  fieldIn0.face=5;
  fieldIn0.nx=nx0;
  fieldIn0.nfx=nfx0;
  fieldIn0.nfy=nfy0;
  fieldIn0.sshiftx=0;
  fieldIn0.sshifty=0;

  clear ix;eval(['ix=ix' num2str(fieldIn0.face) '_0;']);
  clear iy;eval(['iy=iy' num2str(fieldIn0.face) '_0;']);
  fieldIn0.jy=iy+fieldIn0.sshifty;			%[136 270], global,

  fieldIn0.pad=obcs0{1}.pad;				%make same as face1, but function, not hardcoded
  if(fieldIn0.obcsstr=='E');
    fieldIn0.ix=(ix(end)-fieldIn0.pad).*ones(size(fieldIn0.jy));%[224] global, 1st wet pt
  elseif(fieldIn0.obcsstr=='W');
    fieldIn0.ix=(ix(1)+fieldIn0.pad).*ones(size(fieldIn0.jy));
  end;

% tmp=rdmds(['/scratch/atnguyen/aste_270x450x180/GRID/hFacC']);tmp=reshape(tmp,270,1350,50);
% tmp5=reshape(tmp(:,450+270+180+1:1350,:),450,270,50);
% figure(3);clf;;mypcolor(tmp5(:,:,1)');colorbar;grid;hold on;plot([224 224],[136 270],'k-');hold off;
  fieldIn0.imask=ones(size(fieldIn0.jy));ii=find(iy<=143);fieldIn0.imask(ii)=0;%florida
  sz0=size(fieldIn0.imask);if(sz0(2)==1&sz0(1)>sz0(2));fieldIn0.imask=fieldIn0.imask';end;

  fieldIn.name=fieldIn0.name;
  clear ix;eval(['ix=ix' num2str(fieldIn0.face) ';']);
  clear iy;eval(['iy=iy' num2str(fieldIn0.face) ';']);
  fieldIn.obcsstr=fieldIn0.obcsstr;
  fieldIn.face=fieldIn0.face;
  fieldIn.obcstype=fieldIn0.obcstype;
  fieldIn.nx=nx;
  fieldIn.nfx=nfx;
  fieldIn.nfy=nfy;
  fieldIn.sshiftx=ix(1)-1;					% 2504
  fieldIn.sshifty=iy(1)-1;                                      % 2160 
  fieldIn.jy=(fieldIn0.jy(1)-1)*fac+1:fieldIn0.jy(end)*fac;     % [2161 4320] global
  if(fieldIn0.obcsstr=='E');
    fieldIn.ix=((fieldIn0.ix(1)-1)*fac+1).*ones(size(fieldIn.jy)); % [3569], global (1st wet pt)
  elseif(fieldIn0.obcsstr=='W');
    fieldIn.ix=(fieldIn0.ix(1)*fac).*ones(size(fieldIn.jy));
  end;
  fieldIn.imask=repmat(fieldIn0.imask',[1 fac]);fieldIn.imask=reshape(fieldIn.imask',1,fac*max(sz0));
  fieldIn.flag_case=0;

elseif(iobcs==4);
%43.4141 degN Atlantic
  fieldIn0.name='Face5_Atlantic43p4141degN_West';
  fieldIn0.obcsstr='W';
  fieldIn0.obcstype=find(obcstype==fieldIn0.obcsstr);
  fieldIn0.face=5;
  fieldIn0.nx=nx0;
  fieldIn0.nfx=nfx0;
  fieldIn0.nfy=nfy0;
  fieldIn0.sshiftx=0;
  fieldIn0.sshifty=0;

  clear ix;eval(['ix=ix' num2str(fieldIn0.face) '_0;']);
  clear iy;eval(['iy=iy' num2str(fieldIn0.face) '_0;']);
  fieldIn0.jy=iy+fieldIn0.sshifty;			%[136 270]

  fieldIn0.pad=obcs0{2}.pad;				%make same as face1, but function, not hardcoded
  if(fieldIn0.obcsstr=='E');
    fieldIn0.ix=(ix(end)-fieldIn0.pad).*ones(size(fieldIn0.jy));%[158] global, 1st wet pt
  elseif(fieldIn0.obcsstr=='W');
    fieldIn0.ix=(ix(1)+fieldIn0.pad).*ones(size(fieldIn0.jy));
  end;

% tmp=rdmds(['/scratch/atnguyen/aste_270x450x180/GRID/hFacC']);tmp=reshape(tmp,270,1350,50);
% tmp5=reshape(tmp(:,450+270+180+1:1350,:),450,270,50);
% figure(3);clf;;mypcolor(tmp5(:,:,1)');colorbar;grid;hold on;plot([158 158],[136 270],'k-');hold off;
  fieldIn0.imask=ones(size(fieldIn0.jy));ii=find(iy<=173);fieldIn0.imask(ii)=0;%America
  sz0=size(fieldIn0.imask);if(sz0(2)==1&sz0(1)>sz0(2));fieldIn0.imask=fieldIn0.imask';end;

  fieldIn.name=fieldIn0.name;
  clear ix;eval(['ix=ix' num2str(fieldIn0.face) ';']);
  clear iy;eval(['iy=iy' num2str(fieldIn0.face) ';']);
  fieldIn.obcsstr=fieldIn0.obcsstr;
  fieldIn.face=fieldIn0.face;
  fieldIn.obcstype=fieldIn0.obcstype;
  fieldIn.nx=nx;
  fieldIn.nfx=nfx;
  fieldIn.nfy=nfy;
  fieldIn.sshiftx=ix(1)-1;					% 2504
  fieldIn.sshifty=iy(1)-1;                                      % 2160 
  fieldIn.jy=(fieldIn0.jy(1)-1)*fac+1:fieldIn0.jy(end)*fac;     % [2161 4320] global
  if(fieldIn0.obcsstr=='E');
    fieldIn.ix=((fieldIn0.ix(1)-1)*fac+1).*ones(size(fieldIn.jy));
  elseif(fieldIn0.obcsstr=='W');
    fieldIn.ix=(fieldIn0.ix(1)*fac).*ones(size(fieldIn.jy));	%[2528], global, 1st wet pt
  end;
  fieldIn.imask=repmat(fieldIn0.imask',[1 fac]);fieldIn.imask=reshape(fieldIn.imask',1,fac*max(sz0));
  fieldIn.flag_case=0;

%============= 1: Gibraltar Strait , East, Face 1 ==========================
elseif(iobcs==5);

  fieldIn0.name='Face1_GibraltarStrait_East';
  fieldIn0.obcsstr='E';
  fieldIn0.obcstype=find(obcstype==fieldIn0.obcsstr);
  fieldIn0.face=1;
  fieldIn0.nx=nx0;                                                      % 270
  fieldIn0.nfx=nfx0;                                                    % [270 0 270 0 450]
  fieldIn0.nfy=nfy0;                                                    % [450 0 270 0 270]
  fieldIn0.sshiftx=(nfx0_full(fieldIn0.face)-nfx0(fieldIn0.face));      % 0
  fieldIn0.sshifty=(nfy0_full(fieldIn0.face)-nfy0(fieldIn0.face));      % 360

  clear ix;eval(['ix=ix' num2str(fieldIn0.face) '_0;']);
  clear iy;eval(['iy=iy' num2str(fieldIn0.face) '_0;']);
  fieldIn0.jy=iy;                                                               %global
  fieldIn0.imask = ones(size(fieldIn0.jy));ii=find(iy<621|iy>622);fieldIn0.imask(ii)=0; %[261:262]aste,[621:622]global
%  fieldIn0.jy=[261:262]+fieldIn0.sshifty;                              % [621 622] global
  fieldIn0.ix=96*ones(size(fieldIn0.jy))+fieldIn0.sshiftx;              % [96] global (1st wet pt)

  sz0=size(fieldIn0.imask);if(sz0(2)==1&sz0(1)>sz0(2));fieldIn0.imask=fieldIn0.imask';end;% make into row
%checking:
  yg0_f1=readbin([dirs.parent.Grid0_global 'YG.data'],[nx0 nx0*3]);
  tmpj=find(fieldIn0.imask==1);			% [172 173] for 1440x540, [127 128] for 1260x540
  yg0_f1(fieldIn0.ix(1),fieldIn0.jy(tmpj))	% [35.817378997802734  36.066429138183594]
%end checking

  fieldIn.name=fieldIn0.name;
  clear ix;eval(['ix=ix' num2str(fieldIn0.face) ';']);
  clear iy;eval(['iy=iy' num2str(fieldIn0.face) ';']);
  fieldIn.obcsstr=fieldIn0.obcsstr;
  fieldIn.obcstype=fieldIn0.obcstype;
  fieldIn.face=fieldIn0.face;
  fieldIn.nx=ncut1;                    % 2160
  fieldIn.nfx=nfx;                     % [2160 0 0 0 1080]
  fieldIn.nfy=nfy;                     % [1080 0 0 0 2160]
  fieldIn.sshiftx=ix(1)-1;             % 0
  fieldIn.sshifty=iy(1)-1;             % 9377-1=9376; 

%Gibraltar Strait:
%llc90: 1 single grid point at ix=33,iy=209(global)-120=89(aste), with dy=90km
%       upstream(inside): ix=32,iy=[208:210](global)-120=[88:90](aste)
%llc270: 3 grid points at ix=96,iy=260:262
%The question is how many grid points to take, see "verification + plotting" below,
% for now, choose 2 grid points 261:262
%        upstream(inside): ix=95,iy=?[256:258,259:261,262:264]
%        All that is required is that hfW at depth lev 20 is 0.2.  This means
%        just have to make sure hfC(95,261:262)>0.2 -> make sure depth is > 284m
%forllc4320: take iU=1549;jC_1st=[546:559]+9376=[9922:9935];
%note: in step1b_interpllc270_llc4320grid.m, looks like I updated it to:
% iU=1531 (1st wet pt), jC=[540:553]+9376=[9916 9929]
  fieldIn.jy=iy;
  fieldIn.imask=zeros(size(fieldIn.jy));
%load('/scratch/atnguyen/llc4320/NA_4320x2160x1080x106/run_template/input_obcs/obcs_llc4320_it0012_11Nov2016.mat',...
%     'Face1new'); %--> Face1new.iCE_1st=1531; Face1new.jCE([1,14))=[9916,9929]
  ii=find(iy>=(9916)&iy<=(9929));fieldIn.imask(ii)=1;	%13.jul.2018: verified by An that these are correct
  fieldIn.ix=1531.*ones(size(fieldIn.jy))+fieldIn.sshiftx;% 1531; %%%%1549,eyeballing
  fieldIn.flag_case=1;
end;

[fieldOut,fieldOut0]=get_obcsNSEW(fieldIn0,fieldIn,mygrid0,mygrid1,0,fieldIn.flag_case);

  obcs0{iobcs}=fieldOut0;
  obcs{iobcs} =fieldOut;

  set(gcf,'paperunits','inches','paperposition',[0 0 14 12]);
  fpr=[dirOut 'step0_obcs' sprintf('%2.2i',iobcs) '.png'];print(fpr,'-dpng');
%keyboard
end;%iobcs

fsave=[dirOut 'step0_obcs_' datestamp '.mat'];save(fsave,'obcs0','obcs');fprintf('%s\n',fsave);
