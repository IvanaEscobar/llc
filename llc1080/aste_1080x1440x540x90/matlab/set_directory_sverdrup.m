
%this must comes after define_NA540x270_indices.m

%defind datestamp once here: (either hardcoded if want to repeat old datestamp outputs or set new here)
datestamp='13Jan2018';%'20Dec2017';%date;datestamp(find(datestamp=='-'))='';%'24Feb2017';%
fprintf('datestamp: %s\n',datestamp);
%datestamp='06Feb2017';%'05Feb2017';%'02Feb2017';

%================ CHILD GLOBAL =========================================================
machine='sverdrup';%'pfe';
if(strcmp(machine,'glacier0')>0);
  %dirGrid='/net/weddell/raid3/gforget/grids/gridCompleted/llcRegLatLon/llc_dec09_270/';
  %dirGridOut='/net/nares/raid8/ecco-shared/llc270/aste/GRID/';
elseif(strcmp(machine,'pfe')>0);
  dirGrid_global_real8=['/nobackupp8/dmenemen/tarballs/llc_' nxstr '/run_template/'];
  dirRoot=['/nobackupp2/atnguye4/llc' nxstr '/aste_' nxstr 'x' num2str(ncut1) 'x' num2str(ncut2) 'x' num2str(nz) '/'];
  dirGridOut=[dirRoot  '/run_template/'];
elseif(strcmp(machine,'sverdrup')>0);
  dirGrid_global_real8=['/scratch/atnguyen/llc' nxstr '/global/GRID/'];
  dirRoot=['/home/atnguyen/llc' nxstr '/aste_' nxstr 'x' num2str(ncut1) 'x' num2str(ncut2) 'x' num2str(nz) '/'];
  dirGridOut=[dirRoot  '/run_template/'];
else;
  error('need to define directory for grid');
end;

if(~exist(dirGrid_global_real8));error('dirGrid_global_real8 does not exist');end;
fprintf('dirGrid_global_real8: %s\n',dirGrid_global_real8);
fprintf('dirGridOut: %s\n',dirGridOut);

%=================== CHILD ========================================================
%Root directory
%-- define input and output dir
%ncut1=450;ncut2=360;

%directory for outputing new obcs:
dirOBCS=[dirRoot 'run_template/input_obcs/'];
    if(exist(dirOBCS)==0);mkdir(dirOBCS);fprintf('mkdir %s\n',dirOBCS);end;

%directory where matlab scripts are stored and run:
dirMatlab=[dirRoot 'matlab/'];cd(dirMatlab);

%directory where grids live
dirGrid1=dirGridOut;%[dirRoot 'run_template/'];

%directory where we designed the original vertical rF: (hardcoded)
%dirGrid_rF =['/nobackupp2/atnguye4/llc1080/NA1080x1200/GRID_real8_v3/'];

%define the bathymetry file for which we will modify during extracting obcs:
dirBathy =[dirRoot 'run_template/'];
%fBathy=[dirRoot 'run_template/bathy_aste' nxstr 'x' num2str(ncut1) 'x' num2str(ncut2) '_fix1obcs02Oct2016_0m.bin'];
fBathyIn =[dirBathy 'bathy_aste' nxstr 'x' num2str(ncut1) 'x' num2str(ncut2) '_v2.bin'];
fBathyOut=[dirBathy 'bathy_aste' nxstr 'x' num2str(ncut1) 'x' num2str(ncut2) '_obcs' datestamp '_v2.bin'];

%=================== PARENT ========================================================
%directory of global llc270 
dirGrid0_global='/scratch/atnguyen/llc270/global/GRID/';

%directory of ASTE llc270
dirRoot0=['/scratch/atnguyen/aste_270x450x180/'];
dirGrid0=[dirRoot0 'GRID_real8/'];           %<-- use this for most up-to-date bathy, 3.feb.2017
%dirGrid0='/nobackupp2/atnguye4/llc270/aste_270x450x180/GRID_real8_fill9iU42Eb/';%<-- use this for reproduction of old (iter12) results

%particular solution where we will extract the parent OBCS:
%RunStr='run_c65q_20022013noRstar_mp08latp20_v7imdimSnow_A2v3coast08_it0012_pk0000000002';RunStrShort='iter12';%2002:2013
RunStr='run_c65q_jra55_it0011_pk0000000002';RunStrShort='jra55i11';%2002-2015
dirRun=[dirRoot0 RunStr '/'];
yr_obcs=[2002:2015];		

%directory for child grid dz, moved here b/c using same as parent:
%dirGrid_rF = dirGrid0;
dirGrid_rF = dirGrid_global_real8;

%this is a function I want to generalize but have NOT managed. at the moment it only works for Joern's patch.
blend_bathy=0;	%set to 0 for default, for Joern's patch, set to 1


