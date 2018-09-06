clear all;
warning off

%----- define size, grid ---------
define_indices;

%-- define input and output dir
set_directory;
dirOut=dirOBCS;

%nfx0=[nx0 0 nx0 180   450];   nfy0=[  450 0 nx0 nx0 nx0];
%nfx =[nx  0 nx  ncut2 ncut1]; nfy =[ncut1 0 nx  nx  nx];

nfx0_full=[nx0 0 nx0 0 3*nx0]; nfy0_full=[3*nx0 0 nx0 0 nx0];
nfx_full =[nx 0 nx 0 3*nx];    nfy_full =[3*nx 0 nx 0 nx];

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
      %temp=read_slice([dirGrid0_global 'llc_00' num2str(iface) '_' num2str(nxa) '_' num2str(nya) '.bin'],...
      temp=read_slice([dirGrid0_global 'tile00' num2str(iface) '.mitgrid'],...
                       nxa+1,nya+1,indfield(ifld),'real*8');		%global
      eval(['mygrid0.' fieldstr{ifld} '{iface}=temp(ixa,iya);']);		%aste
    end;
  end;
end;

mygrid1=[];
for iface=[1:5]
  if(nfx(iface)>0 & nfy(iface)>0);
        if(iface==1);nxa=nfx(iface);nya=nfy(iface);ixa=1:nxa;iya=1:nya;           %these indices are from cut mitgrid
    elseif(iface==3);nxa=nfx(iface);nya=nfy(iface);ixa=1:nxa;iya=1:nya;
    else;            nxa=nfx(iface);nya=nfy(iface);ixa=1:nxa;iya=1:nya;end;

    for ifld=1:size(fieldstr,2);
      temp=read_slice([dirGrid1 'tile' sprintf('%3.3i',iface) '.mitgrid'],...
                       nfx(iface)+1,nfy(iface)+1,indfield(ifld),'real*8');
      eval(['mygrid1.' fieldstr{ifld} '{iface}=temp(ixa,iya);']);		%regional
    end;
  end;
end

%-------- MANUAL PART: define for EACH ob ------------------
obcstype=['NSEW'];

fieldIn0=[];
fieldIn =[];

for iobcs=1:4;
  fieldIn0=[];fieldIn=[];
  fieldOut0=[];fieldOut=[];
  obcs0{iobcs}=[];obcs{iobcs}=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%% 1: Atlantic, South, Face 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(iobcs==1);
%5deg Atlantic
  fieldIn0.name='Face1_Atlantic_South';
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
  fieldIn0.ix=ix;							% [1:270] global (eyeballing)
  fieldIn0.imask = ones(size(fieldIn0.ix));                             % [1 x 270], use all width, not blanking out any grid cell
  %fieldIn0.imask(175:270)=0;
  fieldIn0.imask(87:270)=0;
  sz0=size(fieldIn0.imask);if(sz0(2)==1&sz0(1)>sz0(2));fieldIn0.imask=fieldIn0.imask';end;      % make into row

  %fieldIn0.pad=30;							%add 29 to bring the obcs to 5degS
  fieldIn0.pad=30+34;							%add 64 [5.708538953235559N   6.015298779933335N]
  if(fieldIn0.obcsstr=='N');
    fieldIn0.jy=(iy(end)-fieldIn0.pad).*ones(size(fieldIn0.ix));	%already global
  elseif(fieldIn0.obcsstr=='S');
    fieldIn0.jy=(iy(1)+fieldIn0.pad).*ones(size(fieldIn0.ix));       % [338] aste, [698] global 
  end;

  fieldIn.name=fieldIn0.name;
  clear ix;eval(['ix=ix' num2str(fieldIn0.face) ';']);
  clear iy;eval(['iy=iy' num2str(fieldIn0.face) ';']);
  fieldIn.obcsstr=fieldIn0.obcsstr;
  fieldIn.obcstype=fieldIn0.obcstype;
  fieldIn.face=fieldIn0.face;
  fieldIn.nx=nx;							% 1080
  fieldIn.nfx=nfx;							% [1080 0 1080  360  450]
  fieldIn.nfy=nfy;							% [ 450 0 1080 1080 1080]
  fieldIn.sshiftx=ix(1)-1;						% 0
  fieldIn.sshifty=iy(1)-1;						% 3*1080-1200=2040, or 2041-1=2040
  fieldIn.ix=(fieldIn0.ix(1)-1)*fac+1:fieldIn0.ix(end)*fac;		% global [1 1080]
  if(fieldIn0.obcsstr=='N');
    fieldIn.jy=((fieldIn0.jy(1)-1)*fac+1).*ones(size(fieldIn.ix));
  elseif(fieldIn0.obcsstr=='S');
    fieldIn.jy=(fieldIn0.jy(1)*fac).*ones(size(fieldIn.ix));		% global 2792, (1st wet pt)
  end
  fieldIn.imask=repmat(fieldIn0.imask',[1 fac]);fieldIn.imask=reshape(fieldIn.imask',1,fac*max(sz0));
  fieldIn.flag_case=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%% 2: Pacific, South, Face 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif(iobcs==2);
% Pacific
  fieldIn0.name='Face4_Pacific_South';
  fieldIn0.obcsstr='E';
  fieldIn0.obcstype=find(obcstype==fieldIn0.obcsstr);
  fieldIn0.face=4;
  fieldIn0.nx=nx0;
  fieldIn0.nfx=nfx0;
  fieldIn0.nfy=nfy0;
  fieldIn0.sshiftx=0;
  fieldIn0.sshifty=0;

  clear ix;eval(['ix=ix' num2str(fieldIn0.face) '_0;']);
  clear iy;eval(['iy=iy' num2str(fieldIn0.face) '_0;']);
  fieldIn0.jy=iy+fieldIn0.sshifty;            					%global

  fieldIn0.pad=10;%55; %135-10=125
  if(fieldIn0.obcsstr=='E');
    fieldIn0.ix=(ix(end)-fieldIn0.pad).*ones(size(fieldIn0.jy));		%90
  elseif(fieldIn0.obcsstr=='W');
    fieldIn0.ix=(ix(1)+fieldIn0.pad).*ones(size(fieldIn0.jy));
  end;

  fieldIn0.imask = ones(size(fieldIn0.jy));% [1 x 270], use all width, not blanking out any grid cell
%  fieldIn0.imask(181:270)=0;	%Pacific side
  fieldIn0.imask(1:45)=0;	%Sea Okhost
  sz0=size(fieldIn0.imask);if(sz0(2)==1&sz0(1)>sz0(2));fieldIn0.imask=fieldIn0.imask';end;      % make into row

  fieldIn.name=fieldIn0.name;
  clear ix;eval(['ix=ix' num2str(fieldIn0.face) ';']);
  clear iy;eval(['iy=iy' num2str(fieldIn0.face) ';']);
  fieldIn.obcsstr=fieldIn0.obcsstr;
  fieldIn.face=fieldIn0.face;
  fieldIn.obcstype=fieldIn0.obcstype;
  fieldIn.nx=nx;
  fieldIn.nfx=nfx;
  fieldIn.nfy=nfy;
  fieldIn.sshiftx=ix(1)-1;
  fieldIn.sshifty=iy(1)-1;                                      % 1080-1080=0, or 361-361=0
  fieldIn.jy=(fieldIn0.jy(1)-1)*fac+1:fieldIn0.jy(end)*fac;     % [  1 1080] global
  fieldIn.pad=-3;%to make 494
  if(fieldIn0.obcsstr=='E');
    fieldIn.ix=((fieldIn0.ix(1)-1)*fac+1+fieldIn.pad).*ones(size(fieldIn.jy)); % [494], global (1st wet pt)
  elseif(fieldIn0.obcsstr=='W');
    fieldIn.ix=(fieldIn0.ix(1)*fac).*ones(size(fieldIn.jy));
  end;
  fieldIn.imask=repmat(fieldIn0.imask',[1 fac]);fieldIn.imask=reshape(fieldIn.imask',1,fac*max(sz0));
  fieldIn.flag_case=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%% 3: Atlantic, East, Face 5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif(iobcs==3);
%5deg in Atlantic
  fieldIn0.name='Face5_Atlantic6degN_East';
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
  fieldIn0.jy=iy+fieldIn0.sshifty;                              %global
%  fieldIn0.ix=300*ones(size(fieldIn0.jy))+fieldIn0.sshiftx;    %global (1st wet pt)

  fieldIn0.pad=30+34;
  if(fieldIn0.obcsstr=='E');
    fieldIn0.ix=(ix(end)-fieldIn0.pad).*ones(size(fieldIn0.jy));%ix already in global
  elseif(fieldIn0.obcsstr=='W');
    fieldIn0.ix=(ix(1)+fieldIn0.pad).*ones(size(fieldIn0.jy));
  end;
  fieldIn0.imask=ones(size(fieldIn0.jy));ii=find(iy<215);fieldIn0.imask(ii)=0;
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
  fieldIn.sshiftx=ix(1)-1;
  fieldIn.sshifty=iy(1)-1;                                      % 1080-720=360, or 361-1=360
  fieldIn.jy=(fieldIn0.jy(1)-1)*fac+1:fieldIn0.jy(end)*fac;     % [361 1080] global
  if(fieldIn0.obcsstr=='E');
    fieldIn.ix=((fieldIn0.ix(1)-1)*fac+1).*ones(size(fieldIn.jy)); % [1197], global (1st wet pt)
  elseif(fieldIn0.obcsstr=='W');
    fieldIn.ix=(fieldIn0.ix(1)*fac).*ones(size(fieldIn.jy));
  end;
  fieldIn.imask=repmat(fieldIn0.imask',[1 fac]);fieldIn.imask=reshape(fieldIn.imask',1,fac*max(sz0));
  fieldIn.flag_case=0;

%============= 3: Gibraltar Strait , East, Face 1 ==========================
elseif(iobcs==4);

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

  sz0=size(fieldIn0.imask);if(sz0(2)==1&sz0(1)>sz0(2));fieldIn0.imask=fieldIn0.imask';end;      % make into row

  fieldIn.name=fieldIn0.name;
  clear ix;eval(['ix=ix' num2str(fieldIn0.face) ';']);
  clear iy;eval(['iy=iy' num2str(fieldIn0.face) ';']);
  fieldIn.obcsstr=fieldIn0.obcsstr;
  fieldIn.obcstype=fieldIn0.obcstype;
  fieldIn.face=fieldIn0.face;
  fieldIn.nx=nx;                                                        % 1080
  fieldIn.nfx=nfx;                                                      % [ 720 0 720 0 1200]
  fieldIn.nfy=nfy;                                                      % [1200 0 720 0  720]
  fieldIn.sshiftx=ix(1)-1;                                              % 0
  fieldIn.sshifty=iy(1)-1;                                              % 2041-1=2040; (1080-720=360?)

  fieldIn.jy=iy;
  fieldIn.imask=zeros(size(fieldIn.jy));
%eyeballing: either [2480:2483] or [2481:2484] (seems 2nd set is what used for 1440x540
  fieldIn.imask=zeros(size(fieldIn.jy));
  ii=find(iy>=(2481)&iy<=(2484));fieldIn.imask(ii)=1;
% ii=find(iy>=(681+fieldIn.sshifty)&iy<=(684+fieldIn.sshifty));fieldIn.imask(ii)=1; <-- only true for 1440x540
%  fieldIn.jy=[440:443]+fieldIn.sshifty;                                % [2480:2483], eyeballing
%  fieldIn.ix=383.*ones(size(fieldIn.jy))+fieldIn.sshiftx;              % 383 , eyeballing
  fieldIn.ix=387.*ones(size(fieldIn.jy))+fieldIn.sshiftx;               % 387 , eyeballing
  fieldIn.flag_case=1;
end;

[fieldOut,fieldOut0]=get_obcsNSEW(fieldIn0,fieldIn,mygrid0,mygrid1,0,fieldIn.flag_case);

  obcs0{iobcs}=fieldOut0;
  obcs{iobcs} =fieldOut;

  set(gcf,'paperunits','inches','paperposition',[0 0 14 12]);
  fpr=[dirOut 'step0_obcs' sprintf('%2.2i',iobcs) '.png'];print(fpr,'-dpng');
keyboard
end;

%fsave=[dirOut 'step0_obcs_' datestamp '.mat'];save(fsave,'obcs0','obcs');fprintf('%s\n',fsave);
