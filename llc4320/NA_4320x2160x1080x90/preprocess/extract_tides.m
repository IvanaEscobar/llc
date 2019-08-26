%% EXTRACTING TIDES
% This script extracts the TPXO7.2 tidal predictions at the OBC locations using
% TMD, converts them into the format used by the MITgcm, and saves the
% information to input files.

addpath('/home/atnguyen/nansen/tides/JCcode_tides_obcs/tmd_mar_203/TMD2.03');
addpath('/home/atnguyen/nansen/tides/JCcode_tides_obcs/tmd_mar_203/TMD2.03/FUNCTIONS/');
addpath('/home/atnguyen/nansen/tides/JCcode_tides_obcs/tmd_mar_203/TMD2.03/DATA/');
addpath('/home/atnguyen/nansen/tides/JCcode_tides_obcs/tmd_mar_203/TMD2.03/LAT_LON/');
addpath('/home/atnguyen/nansen/tides/JCcode_tides_obcs')
dirIn='/scratch/ivana/llc/llc4320/NA_4320x2160x1080x90/run_template/input_obcs/';
dirOut=dirIn;

% model start time
time = datenum(2002,01,01);

% pad lengths for other faces
nz=90;
nx = 2160; ncut2 = 1080;
padN = ncut2;
padS = ncut2;
padW = ncut2;
padE1_1 = 527; % ncut2-553
padE1_2 = 540;

% load OBC locations
load([dirIn 'latlon_for_obcs_tides.mat'],'Face1N','Face1S','Face5E','Face5W','Face1E');

%******** WARNING *********
% Need to be careful here as uE,vN only works where llc_grid
% is pure E/N, for example at some latitude it's transitioning
% into projection, in which case will need to rotate to model
% u/v using Angle[CS,SN].
%**************************

% NORTH
% face 1: normal component: vN at N, save as v at N
% face 1: tangential component: uE at N, save as u at N
n1N = nx+ncut2; %2160+1080 = 3240 (whole length)
for iloop=1:2
  clear am ph type
  if(iloop==1);type='v';str='';else;type='u';str='t';end
  [am,ph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face1N.yg,Face1N.xc,type); %am: m, ph: deg [0-360]
  [am,ph] = conv_corr(time,am,ph,cl);   %am: m, ph: phase in sec 
  am(isnan(am)) = 0;		% 13 tidal constituents x 2160 face 1 indices
  ph(isnan(ph)) = 0;		% 13 x 2160
  am = [am,zeros(length(cl),padN)]; % add pad for face 5, 13 x 3240
  ph = [ph,zeros(length(cl),padN)]; 
  writebin([dirOut 'OBN' str 'am_' num2str(n1N) 'x' num2str(size(cl,1)) '.bin'],am',1,'real*4'); %  amplitude
  writebin([dirOut 'OBN' str 'ph_' num2str(n1N) 'x' num2str(size(cl,1)) '.bin'],ph',1,'real*4'); %  phase
  clear am ph
end

% SOUTH
% face 1: normal component: vN at S, save as v at S
% face 1: tangential component: uE at S, save as u at S
n1S = nx+ncut2; %2160+1080 = 3240 (whole length)
for iloop=1:2
  clear am ph type
  if(iloop==1);type='v';str='';else;type='u';str='t';end
  [am,ph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face1S.yg,Face1S.xc,type); %am: m, ph: deg [0-360]
  [am,ph] = conv_corr(time,am,ph,cl);   %am: m, ph: phase in sec 
  am(isnan(am)) = 0;		% 13 x 2160
  ph(isnan(ph)) = 0;		
  am = [am,zeros(length(cl),padS)]; % add pad for face 5, 13 x 3240
  ph = [ph,zeros(length(cl),padS)]; 
  writebin([dirOut 'OBS' str 'am_' num2str(n1S) 'x' num2str(size(cl,1)) '.bin'],am',1,'real*4'); %  amplitude
  writebin([dirOut 'OBS' str 'ph_' num2str(n1S) 'x' num2str(size(cl,1)) '.bin'],ph',1,'real*4'); %  phase
  clear am ph
end

% WEST: check
% face 5: normal    : vN at N, save as -u at W
% face 5: tangential: uE at N, save as +v at W
n5W = nx+ncut2; %2160+1080 = 3240 (whole length)
bc = 'n5W';
for iloop=1:2
  clear am ph type
  if(iloop==1);type='v';str='';ss=-1.;else;type='u';str='t';ss=1.;end
  [am,ph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face5W.yg,Face5W.xc,type); %am: m, ph: deg [0-360]
  [am,ph] = conv_corr(time,am,ph,cl);   %am: m, ph: phase in sec 
  am(isnan(am)) = 0;		% 13 x 2160
  ph(isnan(ph)) = 0;		% 13 x 2160
  am = [am,zeros(length(cl),padW)]; am=ss.*am;   % pad for face 5, 13 x 3240
  ph = [ph,zeros(length(cl),padW)];             
  writebin([dirOut 'OBW' str 'am_' num2str(n1S) 'x' num2str(size(cl,1)) '.bin'],am',1,'real*4'); %  amplitude
  writebin([dirOut 'OBW' str 'ph_' num2str(n1S) 'x' num2str(size(cl,1)) '.bin'],ph',1,'real*4'); %  phase
  clear am ph
end

% EAST
%Gibraltar Strait:
% face 1: normal: uE at E, save as u at E
% face 1: tangential: vN at E, save as v at E
clear am ph type uam uph vam vph
str='1E';
for iloop=1:2
  if (iloop==1);type='u';else;type='v';end
  [am,ph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face1E.yc,Face1E.xg,type);
  [am,ph] = conv_corr(time,am,ph,cl);
  eval([type 'am' str '=am;']);eval([type 'ph' str '=ph;']);
  clear am ph type
end

% face 5: normal    : vN at S, save as -u at E
% face 5: tangential: uE at S, save as +v at E
str='5E';
for iloop=1:2
  if(iloop==1);type='v';ss='-1.0';else;type='u';ss='1.0';end
  [am,ph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face5E.yg,Face5E.xc,type);
  [am,ph] = conv_corr(time,am,ph,cl);
  eval([type 'am' str '=' ss '.*am;']);eval([type 'ph' str '=ph;']);
  clear am ph
end

% Putting all East together:
nE = nx+ncut2;% 2160 + 1080 = 3240
str='';
uam = cat(2,uam1E, vam5E); uam(isnan(uam)) = 0;
uph = cat(2,uph1E, vph5E); uph(isnan(uph)) = 0;

writebin([dirOut 'OBE' str 'am_' num2str(4500) 'x' num2str(size(cl,1)) '.bin'],uam',1,'real*4'); % amplitude
writebin([dirOut 'OBE' str 'ph_' num2str(4500) 'x' num2str(size(cl,1)) '.bin'],uph',1,'real*4'); % phase

str='t';
vam = cat(2,vam1E, uam5E); vam(isnan(vam)) = 0;
vph = cat(2,vph1E, uph5E); vph(isnan(vph)) = 0;

writebin([dirOut 'OBE' str 'am_' num2str(nE) 'x' num2str(size(cl,1)) '.bin'],vam',1,'real*4'); % amplitude
writebin([dirOut 'OBE' str 'ph_' num2str(nE) 'x' num2str(size(cl,1)) '.bin'],vph',1,'real*4'); % phase

% save constituent periods to periods.txt
periods = zeros(length(cl),1);
for i = 1:length(cl)
  [ispec,am,ph,omega,alpha,constitNum] = constit(cl(i,:));
  periods(i) = 2*pi/omega;
end
fileID = fopen([dirOut 'periods.txt'],'w');
fprintf(fileID,'name:        ');
for i = 1:length(cl)
  fprintf(fileID,'%4s         ',cl(i,:));
end
fprintf(fileID,'\n');
fprintf(fileID,'period (hr): ');
fprintf(fileID,'%12.6f ',periods'/3600);
fprintf(fileID,'\n');
fprintf(fileID,'period (s):  ');
fprintf(fileID,'%12.6f ',periods');
fclose(fileID);
