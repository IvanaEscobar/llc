%% SETTING DIRECTORY PATHS FOR ASTE MITGCM PREPROCESSING
% Call AFTER defining indices (ie: define_indices.m)

if ~exist('id','var')
    error("Need to call define_indices.m beforehand.");
end

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
%dirs.datestamp = date; 
dirs.datestamp = '11Jan2019';

dirs.datestamp(find(dirs.datestamp=='-'))='';
fprintf('\nSetting directories...\nUsing datestamp: %s\n',dirs.datestamp);

%% ================ DOMAIN GLOBAL ==============================================
% Specifiying path system of global domain based on hostname and resolution. 
% Legacy code has global paths hardcoded and are NOT checked as of 10Aug2018. 

if(strcmp(hostname,'glacier0')>0)
    dirs.domain = glacier0_paths(user, id);
elseif(strcmp(hostname,'pfe')>0)
    dirs.domain = pfe_paths(user, id);
elseif(strcmp(hostname,'sverdrup.ices.utexas.edu')>0)
    dirs.domain = sverdrup_paths(user, id);
else
  error('Check for proper login and hostname to define directory for grid');
end

fprintf('Domain grid_global: %s\n',dirs.domain.grid_global);
fprintf('Domain grid_out: %s\n',dirs.domain.grid);

%% =================== DOMAIN (fine) ===========================================
% Specifiying paths for the regional cut of the domain based on indices and 
% OBCs of interest (see define_indices.m for customizations of regional domain)
%directory for outputing new obcs:
dirs.domain.obcs=[dirs.domain.root 'run_template/input_obcs/'];
if(exist(dirs.domain.obcs)==0)
    mkdir(dirs.domain.obcs);fprintf('mkdir: %s\n',dirs.domain.obcs);
end

%directory of MATLab scripts:
dirs.matlab=[dirs.domain.root '../preprocess/'];cd(dirs.matlab);

%directory of the original vertical rF: (hardcoded)
%dirGrid_rF =['/nobackupp2/atnguye4/llc1080/NA1080x1200/GRID_real8_v3/'];

%define bathymetry binary files for modification during extraction of obcs:
dirs.domain.bins =[dirs.domain.root 'run_template/input_binaries/'];
dirs.bathy.fIn =[dirs.domain.bins 'SandSv18p1_NA' id.n.x 'x' id.ncut{1} 'x' ...
            id.ncut{2} '.bin'];
dirs.bathy.fOut=[dirs.domain.bins 'SandSv18p1_NA' id.n.x 'x' id.ncut{1} 'x' ...
            id.ncut{2} '_obcs' dirs.datestamp '.bin'];

%% =================== PARENT (coarse) ========================================
% set parent global domain paths based on the user and resolution of domain
% we do not write to the parent directories

if (strcmp(hostname,'sverdrup.ices.utexas.edu')>0)
    %directory of global parent llcXXXX
    dirs.parent.grid_global = ['/scratch/' user '/llc/llc' id.n.x0 ...
                                '/global/GRID/'];
    dirs.parent.data_grid_global = 'real4';

    %directory of ASTE llc270
    if id.n.x0 == '270'
        astedim = [id.n.x0 'x450x180']; % (hardcoded)
        dirs.parent.root=['/scratch/' user '/aste_' astedim '/'];
        % Latest bathy: 3Feb2017
        dirs.parent.grid=[dirs.parent.root 'GRID_real8/']; 
        dirs.parent.data_grid = 'real8'; % (harcoded: check w. An)
    end
end

%solution where we extract the parent obcs (hardcoded):
dirs.runStr='run_BE2_dthetadr_it0047_pk0000000003';
dirs.runStrShort='jra55i47';%2002-2015
dirs.parent.run=[dirs.parent.root dirs.runStr '/'];
dirs.yr_obcs=2002:2015;		

%directory for domain grid vertical rF (same as parent):
% These are both already saved in dirs.domain.grid_global
%dirs.parent.Grid_rF = dirs.domain.grid_global;
%dirs.domain.Grid_rF = dirs.parent.Grid_rF;

% PROGESS PAUSE: using blend on JOERN's path only. goal is to generalize
% To use Joern's patch, set to 1 (default is 0)
dirs.bathy.blend=1;

%% =============== CLEAR DATA =================================================
clear astedim hostname user

%% =============== FILE PATH FUNCTIONS ========================================
function [dirs] = glacier0_paths(user,s)
    dirs.Grid=['/net/weddell/raid3/gforget/grids/gridCompleted/' ...
            'llcRegLatLon/llc_dec09_270/'];
    dirs.grid= '/net/nares/raid8/ecco-shared/llc270/aste/GRID/';
    check_paths(dirs);
return
end

function[dirs] = pfe_paths(user,s)
    dirs.grid_global= ['/nobackupp8/dmenemen/tarballs/llc_' s.n.x ...
            '/run_template/'];
    dirs.root=['/nobackupp2/atnguye4/llc' s.n.x '/aste_' s.n.x 'x' ...
             s.ncut{1} 'x' s.ncut{2} 'x' s.n.z '/'];
    dirs.grid=[root  '/run_template/'];
    check_paths(dirs);
return
end

function [dirs] = sverdrup_paths(user,s)
    if (strcmp(user,'atnguyen')>0)
        dirs.grid_global=['/scratch/' user '/llc' s.n.x '/global/GRID/'];
        dirs.data_grid_global = 'real8';

        dirs.root=['/home/' user '/llc' s.n.x '/NA_' s.n.x 'x' ...
                s.ncut{1} 'x' s.ncut{2} 'x' s.n.z '/'];        
        dirs.grid=[dirs.root  '/run_template/'];
    elseif (strcmp(user, 'ivana')>0)
        dirs.grid_global=['/scratch/' user '/llc/llc' s.n.x ...
                '/global/GRID/'];
        dirs.data_grid_global = 'real8'; % assuming based on hardcoded version

        dirs.root=['/home/' user '/llc/llc' s.n.x '/NA_' s.n.x 'x' ...
                s.ncut{1} 'x' s.ncut{2} 'x' s.n.z '/root/'];        
        dirs.grid=[dirs.root  'run_template/'];
    end
    check_paths(dirs);
return
end

function check_paths(dirs)
    if(~isfield(dirs, 'root'));error('root does not exist');end
    if(~isfield(dirs, 'grid'));error('grid does not exist');end
    if(~isfield(dirs, 'grid_global'))
        error('dirs.domain.grid_global does not exist');
    end
return
end
