%% SETTING LOCAL PATHS FOR READING AND WRITING OF ASTE MITGCM PREPROCESSING
% Call this code AFTER defining indices (ie: define_NA540x270_indices.m)

% Set user information:
if isunix()
    user = getenv('USER');
    hostname = getenv('HOSTNAME');
else
    user = getenv('username');
    hostname = getenv('computername');
end

% Record date: (hardcoded if repeating old datestamp outputs or set new here)
% PAST DATES: 
%           - '13Jul2018'
%           - '13Jan2018'
%           - '20Dec2017'
%           - '24Feb2017'
%           - '06Feb2017'
%           - '02Feb2017'

datestamp = date; datestamp(find(datestamp=='-'))='';
fprintf('Using datestamp: %s\n',datestamp);

%% ================ CHILD GLOBAL ==============================================
% Specifiying path system of global domain based on hostname and resolution. 
% Legacy code has global paths hardcoded and are NOT checked as of 10Aug2018. 

if(strcmp(hostname,'glacier0')>0)
    dirs.child = glacier0_paths(user, opt);
elseif(strcmp(hostname,'pfe')>0)
    dirs.child = pfe_paths(user, opt);
elseif(strcmp(hostname,'sverdrup.ices.utexas.edu')>0)
    dirs.child = sverdrup_paths(user, opt);
else
  error('Check for proper login and hostname to define directory for grid');
end

fprintf('dirGrid_global_real8: %s\n',dirs.child.Grid_global_real8);
fprintf('dirGridOut: %s\n',dirs.child.GridOut);

%% =================== CHILD (fine) ===========================================
% Specifiying paths for the regional cut of the domain based on indices and 
% OBCs of interest (see define_indices.m for customizations of regional domain)
%directory for outputing new obcs:
dirs.child.OBCS=[dirs.child.Root 'run_template/input_obcs/'];
if(exist(dirs.child.OBCS)==0)
    mkdir(dirs.child.OBCS);fprintf('mkdir: %s\n',dirs.child.OBCS);
end

%directory of MATLab scripts:
dirs.matlab=[dirs.child.Root 'matlab/'];cd(dirs.matlab);

%directory of Grids:
dirs.Grid1=dirs.child.GridOut;

%directory of the original vertical rF: (hardcoded)
%dirGrid_rF =['/nobackupp2/atnguye4/llc1080/NA1080x1200/GRID_real8_v3/'];

%define bathymetry binary files for modification during extraction of obcs:
dirs.child.Bathy =[dirs.child.Root 'run_template/'];
fBathyIn =[dirs.child.Bathy 'SandSv18p1_NA' opt.nx 'x' opt.ncut1 'x' ...
            opt.ncut2 '.bin'];
fBathyOut=[dirs.child.Bathy 'SandSv18p1_NA' opt.nx 'x' opt.ncut1 'x' ...
            opt.ncut2 '_obcs' datestamp '.bin'];

%% =================== PARENT (coarse) ========================================
% set parent global domain paths based on the user and resolution of domain
% we do not write to the parent directories

if (strcmp(hostname,'sverdrup.ices.utexas.edu')>0)
    %directory of global parent llcXXXX
    dirs.parent.Grid0_global=['/scratch/' user '/llc' opt.nx0 '/global/GRID/'];

    %directory of ASTE llc270
    if opt.nx0 == '270'
        astedim = [opt.nx0 'x450x180']; % (hardcoded)
        dirs.parent.Root0=['/scratch/' user '/aste_' astedim '/'];
        % Latest bathy: 3Feb2017
        dirs.parent.Grid0=[dirs.parent.Root0 'GRID_real8/']; 
    end
end

%solution where we extract the parent OBCS (hardcoded):
RunStr='run_BE2_dthetadr_it0047_pk0000000003';
RunStrShort='jra55i47';%2002-2015
dirs.parent.Run=[dirs.parent.Root0 RunStr '/'];
yr_obcs=2002:2015;		

%directory for child grid dz (same as parent, else use dirGrid0):
dirs.parent.Grid_rF = dirs.child.Grid_global_real8;
dirs.child.Grid_rF = dirs.parent.Grid_rF;

% PROGESS PAUSE: using blend on JOERN's path only. goal is to generalize
% To use Joern's patch, set to 1 (default is 0)
blend_bathy=1;

%% =============== FILE PATH FUNCTIONS ========================================
function [dirs] = glacier0_paths(user,s)
    dirs.Grid=['/net/weddell/raid3/gforget/grids/gridCompleted/' ...
            'llcRegLatLon/llc_dec09_270/'];
    dirs.GridOut= '/net/nares/raid8/ecco-shared/llc270/aste/GRID/';
    check_paths(dirs);
return
end

function[dirs] = pfe_paths(user,s)
    dirs.Grid_global_real8= ['/nobackupp8/dmenemen/tarballs/llc_' s.nx ...
            '/run_template/'];
    dirs.Root=['/nobackupp2/atnguye4/llc' s.nx '/aste_' nx 'x' ...
             s.ncut1 'x' s.ncut2 'x' s.nz '/'];
    dirs.GridOut=[Root  '/run_template/'];
    check_paths(dirs);
return
end

function [dirs] = sverdrup_paths(user,s)
    if (strcmp(user,'atnguyen')>0)
        dirs.Grid_global_real8=['/scratch/' user '/llc' s.nx '/global/GRID/'];
        dirs.Root=['/home/' user '/llc' s.nx '/NA_' s.nx 'x' ...
                s.ncut1 'x' s.ncut2 'x' s.nz '/'];        
        dirs.GridOut=[dirs.Root  '/run_template/'];
    elseif (strcmp(user, 'ivana')>0)
        dirs.Grid_global_real8=['/scratch/' user '/scott/llc/llc' s.nx ...
                '/global/GRID/'];
        dirs.Root=['/home/' user '/scott/llc/llc' s.nx '/NA_' s.nx 'x' ...
                s.ncut1 'x' s.ncut2 'x' s.nz '/'];        
        dirs.GridOut=[dirs.Root  'run_template/'];
    end
    check_paths(dirs);
return
end

function check_paths(dirs)
    if(~isfield(dirs, 'Root'));error('dirRoot does not exist');end
    if(~isfield(dirs, 'GridOut'));error('dirGridOut does not exist');end
    if(~isfield(dirs, 'Grid_global_real8'))
        error('dirGrid_global_real8 does not exist');
    end
return
end
