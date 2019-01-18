close all; clear all; clc; warning off;

define_indices;
set_directory;

dirOut=dirs.domain.obcs;
%nfx0=[nx0 0 nx0 180   450];   nfy0=[  450 0 nx0 nx0 nx0];
%nfx =[nx  0 nx  ncut2 ncut1]; nfy =[ncut1 0 nx  nx  nx];
nfx0_full=[id.n.x0 0 0 0 3*id.n.x0]; nfy0_full=[3*id.n.x0 0 0 0 id.n.x0];

%%=============== LOADING GRIDS ===============================================
% Pick which out of the 16 fields we want to write along with their indices
% Available Fields:
%           {'xC','yC','dxF','dyF','rA','xG','yG','dxV','dyU',rAz','dxC',
%           'dyC','rAz','dxC','dyC','rAw','rAs','dxG','dyG'}
fieldstr=   {'xc','yc','xg','yg','dxg','dyg'};
indfield=   [  1    2    6    7    15    16];

% Parent Grid: indices are from global llc
mygrid0=[];
for iface=[1:5]
  if(id.nf.x0(iface)>0 & id.nf.y0(iface)>0);
    if(iface<=2);
        nxa=id.n.x0;nya=3*id.n.x0;  ixa=1:nxa; iya=nya-id.nf.y0(iface)+1:nya;
    elseif(iface==3);
        nxa=id.n.x0;nya=id.n.x0;    ixa=1:id.nf.x0(iface);iya=1:nya;
    else;            
        nxa=3*id.n.x0;nya=id.n.x0;  ixa=1:id.nf.x0(iface);iya=1:nya;
    end;
    for ifld=1:size(fieldstr,2);
      temp=read_slice([ dirs.parent.grid_global 'tile00' ...
                        num2str(iface) '.mitgrid'],...
                        nxa+1,nya+1,indfield(ifld),'real*8');		%global
      eval(['mygrid0.' fieldstr{ifld} '{iface}=temp(ixa,iya);']);	%aste
    end;
  end;
end;

% Domain Grid: indices are from cut mitgrid
mygrid1=[];
for iface=[1:5]
  if(id.nf.x(iface)>0 & id.nf.y(iface)>0);
    if(iface<=2);
        nxa=id.nf.x(iface);nya=id.nf.y(iface);ixa=1:nxa;iya=1:nya;
    elseif(iface==3);
        nxa=id.nf.x(iface);nya=id.nf.y(iface);ixa=1:nxa;iya=1:nya;
    else;            
        nxa=id.nf.x(iface);nya=id.nf.y(iface);ixa=1:nxa;iya=1:nya;
    end;
    for ifld=1:size(fieldstr,2);
      temp=read_slice([ dirs.domain.bins 'tile' sprintf('%3.3i',iface) ...
                        '.mitgrid'],id.nf.x(iface)+1,id.nf.y(iface)+1, ...
                        indfield(ifld),'real*8');
      eval(['mygrid1.' fieldstr{ifld} '{iface}=temp(ixa,iya);']);	%regional
    end;
  end;
end
clear temp 

%%=============== DEFINE OPEN BOUNDARIES ======================================
% Manually define each ob.
obcstype=['NSEW'];

for iobcs=1:5;
  fieldIn0=[];fieldIn=[];
  obcs0{iobcs}=[];obcs{iobcs}=[];
%--------------- 1: Atlantic, South, Face 1 -----------------------------------
if(iobcs==1);
%26.9236 degN Atlantic
  fieldIn0.name='Face1_Atlantic26p9236degN_South';
  fieldIn0.obcsstr='S';
  fieldIn0.obcstype=find(obcstype==fieldIn0.obcsstr);
  fieldIn0.face=1;
  fieldIn0.nx=id.n.x0;						    % 270
  fieldIn0.nfx=id.nf.x0;					    % [270 0 270 180 450]
  fieldIn0.nfy=id.nf.y0;					    % [450 0 270 270 270]
  fieldIn0.sshiftx=(nfx0_full(fieldIn0.face)-id.nf.x0(fieldIn0.face));	% 0
  fieldIn0.sshifty=(nfy0_full(fieldIn0.face)-id.nf.y0(fieldIn0.face));	% 360
%move 1 pt up so that we're not at the southern edge of highres at the outer point (1st wt pt), 
  fieldIn0.pad=1;

  clear ix;eval(['ix=id.ix0{' num2str(fieldIn0.face) '};']);			%global
  clear iy;eval(['iy=id.iy0{' num2str(fieldIn0.face) '};']);			%global
% ix global [1 135]; South 1st wet pt. global [587] aste [227]
  fieldIn0 = set_edge(fieldIn0, ix, iy, 1);

%find land along obc. imask = 0 if land. Done by visual inspection.  
% tmp=rdmds(['/scratch/atnguyen/aste_270x450x180/GRID/hFacC']);tmp=reshape(tmp,270,1350,50);
% figure(2);clf;;mypcolor(tmp(:,1:450,1)');colorbar;grid;hold on;plot([1 135],[227 227],'k-');hold off;
% load in hFacC (see above 2 lines), [75 135] is Africa
  fieldIn0.imask = ones(size(fieldIn0.ix));	% [1 135], set all width to ocean
  fieldIn0.imask(75:length(fieldIn0.ix))=0;
  sz0=size(fieldIn0.imask);
  if(sz0(2)==1&sz0(1)>sz0(2));fieldIn0.imask=fieldIn0.imask';end;   % make row

  fieldIn = parent2domain_info(fieldIn0, id);
% nx = 4320; nfx = [2160 0 0 0 1080]; nfy = [1080 0 0 0 2160]

  clear ix;eval(['ix=id.ix{' num2str(fieldIn0.face) '};']);
  clear iy;eval(['iy=id.iy{' num2str(fieldIn0.face) '};']);
  fieldIn.sshiftx=ix(1)-1;						% 0
  fieldIn.sshifty=iy(1)-1;						% 9377-1=9376
% ix global [1 2160]; South 1st wet pt. global 9392  
  fieldIn = set_edge(fieldIn, fieldIn0.ix, fieldIn0.jy, 0);
  fieldIn.imask=repmat(fieldIn0.imask',[1 id.fac]);fieldIn.imask=reshape(fieldIn.imask',1,id.fac*max(sz0));
  fieldIn.flag_case=0;

%------------------ 2: Atlantic, North, Face 1 -------------------------------- 
elseif(iobcs==2);
%43.4141 degN Atlantic
  fieldIn0.name='Face1_Atlantic43p4141degN_North';
  fieldIn0.obcsstr='N';
  fieldIn0.obcstype=find(obcstype==fieldIn0.obcsstr);
  fieldIn0.face=1;
  fieldIn0.nx=id.n.x0;							% 270
  fieldIn0.nfx=id.nf.x0;						% [270 0 270 180 450]
  fieldIn0.nfy=id.nf.y0;						% [450 0 270 270 270]
  fieldIn0.sshiftx=(nfx0_full(fieldIn0.face)-id.nf.x0(fieldIn0.face));	% 0
  fieldIn0.sshifty=(nfy0_full(fieldIn0.face)-id.nf.y0(fieldIn0.face));	% 360
%move 1 pt up so that we're not at the southern edge of highres at the outer point (1st wt pt)
  fieldIn0.pad=1;

  clear ix;eval(['ix=id.ix0{' num2str(fieldIn0.face) '};']);			%global
  clear iy;eval(['iy=id.iy0{' num2str(fieldIn0.face) '};']);			%global
% ix global [1 135]; North 1st wet pt. global [653], aste [293] 
  fieldIn0 = set_edge(fieldIn0, ix, iy, 1);

% tmp=rdmds(['/scratch/atnguyen/aste_270x450x180/GRID/hFacC']);tmp=reshape(tmp,270,1350,50);
% figure(2);clf;;mypcolor(tmp(:,1:450,1)');colorbar;grid;hold on;plot([1 135],[293 293],'k-');hold off;
  fieldIn0.imask = ones(size(fieldIn0.ix));	% [1 x 135], use all width, not blanking out any grid cell
  fieldIn0.imask(90:135)=0;			% load in hFacC (see 2 lines above), 90:135: Spain
  sz0=size(fieldIn0.imask);if(sz0(2)==1&sz0(1)>sz0(2));fieldIn0.imask=fieldIn0.imask';end;      % make into row

  fieldIn = parent2domain_info(fieldIn0, id);
% nx = 4320; nfx = [2160 0 0 0 1080]; nfy = [1080 0 0 0 2160]

  clear ix;eval(['ix=id.ix{' num2str(fieldIn0.face) '};']);
  clear iy;eval(['iy=id.iy{' num2str(fieldIn0.face) '};']);
  fieldIn.sshiftx=ix(1)-1;						% 0
  fieldIn.sshifty=iy(1)-1;						% 9377-1=9376
% ix global [1 2160]; N 1st wet pt. global [10433]
  fieldIn = set_edge(fieldIn, fieldIn0.ix, fieldIn0.jy, 0);
  fieldIn.imask=repmat(fieldIn0.imask',[1 id.fac]);fieldIn.imask=reshape(fieldIn.imask',1,id.fac*max(sz0));
  fieldIn.flag_case=0;

%--------------- 3: Atlantic, East, Face 5 ------------------------------------ 
elseif(iobcs==3);
%26.9236 degN Atlantic
  fieldIn0.name='Face5_Atlantic26p9236degN_East';
  fieldIn0.obcsstr='E';
  fieldIn0.obcstype=find(obcstype==fieldIn0.obcsstr);
  fieldIn0.face=5;
  fieldIn0.nx=id.n.x0;
  fieldIn0.nfx=id.nf.x0;
  fieldIn0.nfy=id.nf.y0;
  fieldIn0.sshiftx=0;
  fieldIn0.sshifty=0;
  fieldIn0.pad=obcs0{1}.pad;   %make same as face1, but function, not hardcoded

  clear ix;eval(['ix=id.ix0{' num2str(fieldIn0.face) '};']);			%global
  clear iy;eval(['iy=id.iy0{' num2str(fieldIn0.face) '};']);			%global
% jy global [136 270]; East 1st wet pt. global [224]  
  fieldIn0 = set_edge(fieldIn0, ix, iy, 1);

% tmp=rdmds(['/scratch/atnguyen/aste_270x450x180/GRID/hFacC']);tmp=reshape(tmp,270,1350,50);
% tmp5=reshape(tmp(:,450+270+180+1:1350,:),450,270,50);
% figure(3);clf;;mypcolor(tmp5(:,:,1)');colorbar;grid;hold on;plot([224 224],[136 270],'k-');hold off;
  fieldIn0.imask=ones(size(fieldIn0.jy));ii=find(iy<=143);fieldIn0.imask(ii)=0;%florida
  sz0=size(fieldIn0.imask);if(sz0(2)==1&sz0(1)>sz0(2));fieldIn0.imask=fieldIn0.imask';end;

  fieldIn = parent2domain_info(fieldIn0, id);
% nx = 4320; nfx = [2160 0 0 0 1080]; nfy = [1080 0 0 0 2160]

  clear ix;eval(['ix=id.ix{' num2str(fieldIn0.face) '};']);
  clear iy;eval(['iy=id.iy{' num2str(fieldIn0.face) '};']);
  fieldIn.sshiftx=ix(1)-1;					% 2504
  fieldIn.sshifty=iy(1)-1;                  % 2160 
% jy global [2161 4320]; E 1st wet pt. global [3569]
  fieldIn = set_edge(fieldIn, fieldIn0.ix, fieldIn0.jy, 0);
  fieldIn.imask=repmat(fieldIn0.imask',[1 id.fac]);fieldIn.imask=reshape(fieldIn.imask',1,id.fac*max(sz0));
  fieldIn.flag_case=0;

%--------------- 4: Atlantic, West, Face 5 ------------------------------------ 
elseif(iobcs==4);
%43.4141 degN Atlantic
  fieldIn0.name='Face5_Atlantic43p4141degN_West';
  fieldIn0.obcsstr='W';
  fieldIn0.obcstype=find(obcstype==fieldIn0.obcsstr);
  fieldIn0.face=5;
  fieldIn0.nx=id.n.x0;
  fieldIn0.nfx=id.nf.x0;
  fieldIn0.nfy=id.nf.y0;
  fieldIn0.sshiftx=0;
  fieldIn0.sshifty=0;
  fieldIn0.pad=obcs0{2}.pad;   %make same as face1, but function, not hardcoded

  clear ix;eval(['ix=id.ix0{' num2str(fieldIn0.face) '};']);			%global
  clear iy;eval(['iy=id.iy0{' num2str(fieldIn0.face) '};']);			%global
% jy global [136 270]; West 1st wet pt. global [158]
  fieldIn0 = set_edge(fieldIn0, ix, iy, 1);

% tmp=rdmds(['/scratch/atnguyen/aste_270x450x180/GRID/hFacC']);tmp=reshape(tmp,270,1350,50);
% tmp5=reshape(tmp(:,450+270+180+1:1350,:),450,270,50);
% figure(3);clf;;mypcolor(tmp5(:,:,1)');colorbar;grid;hold on;plot([158 158],[136 270],'k-');hold off;
  fieldIn0.imask=ones(size(fieldIn0.jy));ii=find(iy<=173);fieldIn0.imask(ii)=0;%America
  sz0=size(fieldIn0.imask);if(sz0(2)==1&sz0(1)>sz0(2));fieldIn0.imask=fieldIn0.imask';end;

  fieldIn = parent2domain_info(fieldIn0, id);
% nx = 4320; nfx = [2160 0 0 0 1080]; nfy = [1080 0 0 0 2160]

  clear ix;eval(['ix=id.ix{' num2str(fieldIn0.face) '};']);
  clear iy;eval(['iy=id.iy{' num2str(fieldIn0.face) '};']);
  fieldIn.sshiftx=ix(1)-1;					% 2504
  fieldIn.sshifty=iy(1)-1;                  % 2160 
% jy global [2161 4320]; West 1st wet pt. global [2528]
  fieldIn = set_edge(fieldIn, fieldIn0.ix, fieldIn0.jy, 0);
  fieldIn.imask=repmat(fieldIn0.imask',[1 id.fac]);fieldIn.imask=reshape(fieldIn.imask',1,id.fac*max(sz0));
  fieldIn.flag_case=0;

%--------------- 5: Gibraltar Strait, East, Face 1 ---------------------------- 
% SPECIAL OBC
elseif(iobcs==5);
  fieldIn0.name='Face1_GibraltarStrait_East';
  fieldIn0.obcsstr='E';
  fieldIn0.obcstype=find(obcstype==fieldIn0.obcsstr);
  fieldIn0.face=1;
  fieldIn0.nx=id.n.x0;                                                  % 270
  fieldIn0.nfx=id.nf.x0;                                                % [270 0 270 0 450]
  fieldIn0.nfy=id.nf.y0;                                                % [450 0 270 0 270]
  fieldIn0.sshiftx=(nfx0_full(fieldIn0.face)-id.nf.x0(fieldIn0.face));  % 0
  fieldIn0.sshifty=(nfy0_full(fieldIn0.face)-id.nf.y0(fieldIn0.face));  % 360

  clear ix;eval(['ix=id.ix0{' num2str(fieldIn0.face) '};']);			%global
  clear iy;eval(['iy=id.iy0{' num2str(fieldIn0.face) '};']);			%global
  fieldIn0.jy=iy;                                                       %global
%  fieldIn0.jy=[261:262]+fieldIn0.sshifty;                              % [621 622] global
  fieldIn0.ix=96*ones(size(fieldIn0.jy))+fieldIn0.sshiftx;              % [96] global (1st wet pt)

  fieldIn0.imask = ones(size(fieldIn0.jy));ii=find(iy<621|iy>622);fieldIn0.imask(ii)=0; %[261:262]aste,[621:622]global
  sz0=size(fieldIn0.imask);if(sz0(2)==1&sz0(1)>sz0(2));fieldIn0.imask=fieldIn0.imask';end;

%checking:
  yg0_f1=readbin([dirs.parent.grid_global 'YG.data'],[id.n.x0 id.n.x0*3]);
  tmpj=find(fieldIn0.imask==1);			% [172 173] for 1440x540, [127 128] for 1260x540
  yg0_f1(fieldIn0.ix(1),fieldIn0.jy(tmpj));	% [35.817378997802734  36.066429138183594]
%end checking

  fieldIn = parent2domain_info(fieldIn0, id);
% nx = ncut1=2160; nfx = [2160 0 0 0 1080]; nfy = [1080 0 0 0 2160]
  fieldIn.nx=id.ncut1;

  clear ix;eval(['ix=id.ix{' num2str(fieldIn0.face) '};']);
  clear iy;eval(['iy=id.iy{' num2str(fieldIn0.face) '};']);
  fieldIn.sshiftx=ix(1)-1;             % 0
  fieldIn.sshifty=iy(1)-1;             % 9377-1=9376; 

%Gibraltar Strait:
%llc90: 1 single grid point at ix=33,iy=209(global)-120=89(aste), with dy=90km
%       upstream(inside): ix=32,iy=[208:210](global)-120=[88:90](aste)
%llc270: 3 grid points at ix=96,iy=260:262
%The question is how many grid points to take, see "verification + plotting" 
%below, for now, choose 2 grid points 261:262
%        upstream(inside): ix=95,iy=?[256:258,259:261,262:264]
%        All that is required is that hfW at depth lev 20 is 0.2.  This means
%        have to make sure hfC(95,261:262)>0.2 -> make sure depth is > 284m
%forllc4320: take iU=1549;jC_1st=[546:559]+9376=[9922:9935];
%note: step1b_interpllc270_llc4320grid.m is updated too:
% iU=1531 (1st wet pt), jC=[540:553]+9376=[9916 9929]
  fieldIn.jy=iy;
  fieldIn.ix=1531.*ones(size(fieldIn.jy))+fieldIn.sshiftx;% 1531; %1549,eyeball
%load('/scratch/atnguyen/llc4320/NA_4320x2160x1080x106/run_template/'...
%     'input_obcs/obcs_llc4320_it0012_11Nov2016.mat','Face1new'); 
%--> Face1new.iCE_1st=1531; Face1new.jCE([1,14))=[9916,9929]
  fieldIn.imask=zeros(size(fieldIn.jy));ii=find(iy>=(9916)&iy<=(9929));fieldIn.imask(ii)=1;
  fieldIn.flag_case=1;
end;
%------------------------------------------------------------------------------

[obcs{iobcs},obcs0{iobcs}]=get_obcsNSEW(fieldIn0,fieldIn,mygrid0,mygrid1,0,fieldIn.flag_case);

set(gcf,'paperunits','inches','paperposition',[0 0 14 12]);
fpr=[dirOut 'step0_obcs' sprintf('%2.2i',iobcs) '.png'];print(fpr,'-dpng');
end;%iobcs

fsave=[dirOut 'step0_obcs_' dirs.datestamp '.mat'];save(fsave,'obcs0','obcs');
fprintf('\nStep 0: Setting up indices...\n%s\n',fsave);

%% ========== CLEAR DATA ======================================================
clear tmpj

%% ========== SCRIPT FUNCTIONS ================================================
function [fldIn] = set_edge(fldIn, ix, iy, parent)
    if (parent)
      fldIn.ix=ix; fldIn.jy=iy+fldIn.sshifty;
      if(fldIn.obcsstr=='N');
        fldIn.jy=(iy(end)-fldIn.pad).*ones(size(fldIn.ix));
      elseif(fldIn.obcsstr=='S');
        fldIn.jy=(iy(1)+fldIn.pad).*ones(size(fldIn.ix));
      elseif(fldIn.obcsstr=='E');
        fldIn.ix=(ix(end)-fldIn.pad).*ones(size(fldIn.jy));
      elseif(fldIn.obcsstr=='W');
        fldIn.ix=(ix(1)+fldIn.pad).*ones(size(fldIn.jy));
      end
    else
      fldIn.ix=(ix(1)-1)*fldIn.fac+1:ix(end)*fldIn.fac; 
      fldIn.jy=(iy(1)-1)*fldIn.fac+1:iy(end)*fldIn.fac;
      if(fldIn.obcsstr=='N');
        fldIn.jy=((iy(1)-1)*fldIn.fac+1).*ones(size(fldIn.ix));
      elseif(fldIn.obcsstr=='S');
        fldIn.jy=(iy(1)*fldIn.fac).*ones(size(fldIn.ix));
      elseif(fldIn.obcsstr=='E');
        fldIn.ix=((ix(1)-1)*fldIn.fac+1).*ones(size(fldIn.jy));
      elseif(fldIn.obcsstr=='W');
        fldIn.ix=(ix(1)*fldIn.fac).*ones(size(fldIn.jy));
      end
    end
end
function [fldIn] = parent2domain_info(fldIn0, id)
    fldIn.name=fldIn0.name;
    fldIn.obcsstr=fldIn0.obcsstr;
    fldIn.face=fldIn0.face;
    fldIn.obcstype=fldIn0.obcstype;
    fldIn.nx=id.n.x;
    fldIn.nfx=id.nf.x;
    fldIn.nfy=id.nf.y;
    fldIn.fac=id.fac;
end
