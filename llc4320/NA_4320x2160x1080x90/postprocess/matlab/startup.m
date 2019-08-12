warning off
set(groot,'DefaultFigureColormap',jet)

% add mapping toolbox
tmp1=pwd;
addpath('/home1/03901/atnguyen/matlab/m_map/');
addpath('/home1/03901/atnguyen/matlab/atn_tools');
addpath('/home1/03901/atnguyen/matlab/ifenty_tools');
addpath('/home1/03901/atnguyen/matlab/atn_tools/gcmfaces_mod');
addpath('/home1/03901/atnguyen/matlab/tools');
addpath('/home1/03901/atnguyen/matlab/Projections');
addpath('/home1/03901/atnguyen/matlab/t_tide_v1');
addpath('/home1/03901/atnguyen/matlab/Tidal_ellipse_v2');
addpath('/home1/03901/atnguyen/matlab/addaxis5');

%test gcmfaces:
%cd /home1/03901/atnguyen/matlab_gcmfaces/gcmfaces;
%global gcmfaces_skipplottest; gcmfaces_skipplottest=1;
%global gcmfaces_verbose; gcmfaces_verbose=0;
%gcmfaces_init;

%cd /home1/03901/atnguyen/matlab_gcmfaces/MITprof;
%global MITprof_verbose; MITprof_verbose=0;

%MITprof_path;

%cd(tmp1);

%if 0;
%dirRun='/net/weddell/raid3/gforget/ecco_v4/output_files/2011jan01_solution/diags/';
%rdmds2home1/03901([dirRun 'diags_2d_set1.0000000732']);
%etan=convert2gcmfaces(ETAN);
%figure; m_map_gcmfaces(etan);
%end;

% add gcmfaces toolbox
addpath('/home1/03901/atnguyen/matlab/gcmfaces/');
%gcmfaces_global;
%addpath('/home1/03901/atnguyen/matlab_gcmfaces/gcmfaces/gcmfaces_IO/');
%addpath('/home1/03901/atnguyen/matlab_gcmfaces/gcmfaces/gcmfaces_misc/');
%addpath('/home1/03901/atnguyen/matlab_gcmfaces/gcmfaces/gcmfaces_calc/');
%addpath('/home1/03901/atnguyen/matlab_gcmfaces/gcmfaces/gcmfaces_convert/');
%addpath('/home1/03901/atnguyen/matlab_gcmfaces/gcmfaces/gcmfaces_exch/');
%addpath('/home1/03901/atnguyen/matlab_gcmfaces/gcmfaces/gcmfaces_maps/');
%addpath('/home1/03901/atnguyen/matlab_gcmfaces/gcmfaces/gcmfaces_smooth/');

% add image processing toolbox
%%%addpath(genpath('/usr/local/matlab/toolbox/images'))

% add signal processing toolbox
%%%addpath(genpath('/usr/local/matlab/toolbox/signal'))

% add seawater toolbox
addpath(['/home1/03901/atnguyen/matlab/sw']);

addpath(['/home1/03901/atnguyen/matlab/whoi']);    % add whoi matfiles to path
addpath(['/home1/03901/atnguyen/matlab/plotfun']); % plotting routines
addpath(['/home1/03901/atnguyen/matlab/mitgcm']);  % routines for mitgcm
addpath(['/home1/03901/atnguyen/matlab/mitgcm/utils']);  % routines for mitgcm
addpath(['/home1/03901/atnguyen/matlab/woce']);

%addpath(['/home1/03901/atnguyen/matlab/netcdf_toolbox/netcdf/ncutility']);
%addpath(['/home1/03901/atnguyen/matlab/netcdf_toolbox/netcdf/nctype']);
%addpath(['/home1/03901/atnguyen/matlab/netcdf_toolbox/netcdf/ncsource']);
%addpath(['/home1/03901/atnguyen/matlab/netcdf_toolbox/netcdf']);
%addpath(['/home1/03901/atnguyen/matlab/mexnc/']);
addpath(['/home1/03901/atnguyen/matlab/adcroft/bin/mitgcm_tools/']);

addpath('./');

format compact
%set(0,'DefaultTextFontName','Times News Roman');
clear
