% This script extracts the TPXO tidal predictions at the OBC locations using
% TMD, converts them into the format used by the MITgcm, and saves the
% information to input files.

addpath(genpath('/home1/05427/iescobar/matlab/JCcode_tides_obcs/');
dirIn='/work/05427/iescobar/stampede2/llc/llc90/aste_90x150x60/root/run_template/input_obcs/';
dirOut=dirIn;

% model start time
time = datenum(2002,01,01);

% pad for other face
%pad = 1080;
nz=90;
nx=1080;ncut1=1260;ncut2=540;
padS = nx+ncut2+ncut1;	%2880
padE1_1 = 500;
padE1_2 = 756;
padE3 = nx;

% load OBC locations
load([dirIn 'latlon_for_obcs_tides.mat'],'Face1S','Face4E','Face5E','Face1E');

%******** WARNING *********
% Need to be careful here as uE,vN only works where llc_grid
% is pure E/N, for example at some latitude it's transitioning
% into projection, in which case will need to rotate to model
% u/v using Angle[CS,SN].
% Luckily, for this set up, 
% face4: yc4(495,181:1080) are identical, 50.708789825439453 degN
% face1: yc1(1:360,61) are identical,      4.671571254730225 degN
%**************************

% 2*1080+540+1260 = 3960
% face 1: normal component: vN at S, save as v at S
% face 1: tangential component: uE at S, save as u at S
for iloop=1:2;
  clear am ph type
  if(iloop==1);type='v';str='';else;type='u';str='t';end;
  [am,ph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face1S.yg,Face1S.xc,type);%am: m, ph: deg [0-360]
  [am,ph] = conv_corr(time,am,ph,cl);						%am: m, ph: phase in sec 
  am(isnan(am)) = 0;		% 13 x 1080
  ph(isnan(ph)) = 0;		% 13 x 1080
  am = [am,zeros(length(cl),padS)]; % pad for face 3+4+5, 13 x 3960
  ph = [ph,zeros(length(cl),padS)]; % pad for face 3+4+5, 13 x 3960
  writebin([dirOut 'OBS' str 'am_' num2str(3960) 'x' num2str(size(cl,1)) '.bin'],am',1,'real*4'); %  amplitude
  writebin([dirOut 'OBS' str 'ph_' num2str(3960) 'x' num2str(size(cl,1)) '.bin'],ph',1,'real*4'); %  phase
  clear am ph
end;

%East
%Gibraltar Strait:
% face 1: normal: uE at E, save as u at E
% face 1: tangential: vN at E, save as v at E
clear am ph type uam uph vam vph
str='1E';
for iloop=1:2;
  if (iloop==1);type='u';else;type='v';end;
  [am,ph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face1E.yc,Face1E.xg,type);
  [am,ph] = conv_corr(time,am,ph,cl);
  eval([type 'am' str '=am;']);eval([type 'ph' str '=ph;']);
  clear am ph type
end;

% face 4: normal:     vN at S, save as -u at E
% face 4: tangential: uE at S, save as +v at E
str='4E';
for iloop=1:2;
  if(iloop==1);type='v';ss='-1.0';else;type='u';ss='1.0';end;
  [am,ph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face4E.yg,Face4E.xc,type);
  [am,ph] = conv_corr(time,am,ph,cl);
  eval([type 'am' str '=' ss '.*am;']);eval([type 'ph' str '=ph;']);
  clear am ph
end;

% face 5: normal    : vN at S, save as -u at E
% face 5: tangential: uE at S, save as +v at E
str='5E';
for iloop=1:2;
  if(iloop==1);type='v';ss='-1.0';else;type='u';ss='1.0';end;
  [am,ph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face5E.yg,Face5E.xc,type);
  [am,ph] = conv_corr(time,am,ph,cl);
  eval([type 'am' str '=' ss '.*am;']);eval([type 'ph' str '=ph;']);
  clear am ph
end;

%now putting together: note take away -1 to vam4E and vam5E because already applied above
% 1260+3*1080=4500
str='';
uam = cat(2,uam1E,zeros(length(cl),padE3), vam4E, vam5E); uam(isnan(uam)) = 0;% pad for face 3
uph = cat(2,uph1E,zeros(length(cl),padE3), vph4E, vph5E); uph(isnan(uph)) = 0;% pad for face 3

writebin([dirOut 'OBE' str 'am_' num2str(4500) 'x' num2str(size(cl,1)) '.bin'],uam',1,'real*4'); % amplitude
writebin([dirOut 'OBE' str 'ph_' num2str(4500) 'x' num2str(size(cl,1)) '.bin'],uph',1,'real*4'); % phase

str='t';
vam = cat(2,vam1E,zeros(length(cl),padE3), uam4E, uam5E); vam(isnan(vam)) = 0;% pad for face 3
vph = cat(2,vph1E,zeros(length(cl),padE3), uph4E, uph5E); vph(isnan(vph)) = 0;% pad for face 3

writebin([dirOut 'OBE' str 'am_' num2str(4500) 'x' num2str(size(cl,1)) '.bin'],vam',1,'real*4'); % amplitude
writebin([dirOut 'OBE' str 'ph_' num2str(4500) 'x' num2str(size(cl,1)) '.bin'],vph',1,'real*4'); % phase


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
