% This script extracts the TPXO tidal predictions at the OBC locations using
% TMD, converts them into the format used by the MITgcm, and saves the
% information to input files.

addpath(genpath('/net/barents/raid16/vocana/llc4320/NA2160x1080/run_template/joernc/tides/tmd_mar_203/TMD2.03'));
addpath(genpath('/data4/joernc/MITgcm/utils/matlab'))

% model start time
time = datenum(2011,12,15);
%time = datenum(2012,01,01);

% pad for other face
pad = 1080;

% load OBC locations
load(['NA2160x1080_latlon_fortides.mat'],'Face1','Face5');

% face 1: v at S, save as v at S
[vam,vph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face1.latS,Face1.lonS,'v');
[vam,vph] = conv_corr(time,vam,vph,cl);
vam(isnan(vam)) = 0;
vph(isnan(vph)) = 0;
vam = [vam,zeros(13,pad)]; % pad for face 5
vph = [vph,zeros(13,pad)]; % pad for face 5
writebin('OBSam.bin',vam',1,'real*4'); % write amplitude
writebin('OBSph.bin',vph',1,'real*4'); % write phase

% face 1: v at N, save as v at N
[vam,vph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face1.latN,Face1.lonN,'v');
[vam,vph] = conv_corr(time,vam,vph,cl);
vam(isnan(vam)) = 0;
vph(isnan(vph)) = 0;
vam = [vam,zeros(13,pad)]; % pad for face 5
vph = [vph,zeros(13,pad)]; % pad for face 5
writebin('OBNam.bin',vam',1,'real*4'); % write amplitude
writebin('OBNph.bin',vph',1,'real*4'); % write phase

% face 5: v at S, save as -u at E
[vam,vph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face5.latE,Face5.lonE,'v');
[vam,vph] = conv_corr(time,vam,vph,cl);
vam(isnan(vam)) = 0;
vph(isnan(vph)) = 0;
vam = [zeros(13,pad),vam]; % pad for face 1
vph = [zeros(13,pad),vph]; % pad for face 1
writebin('OBEam.bin',-vam',1,'real*4'); % write amplitude
writebin('OBEph.bin',vph',1,'real*4'); % write phase

% face 5: v at N, save as -u at W
[vam,vph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face5.latW,Face5.lonW,'v');
[vam,vph] = conv_corr(time,vam,vph,cl);
vam(isnan(vam)) = 0;
vph(isnan(vph)) = 0;
vam = [zeros(13,pad),vam]; % pad for face 1
vph = [zeros(13,pad),vph]; % pad for face 1
writebin('OBWam.bin',-vam',1,'real*4'); % write amplitude
writebin('OBWph.bin',vph',1,'real*4'); % write phase

% save constituent periods to periods.txt
periods = zeros(length(cl),1);
for i = 1:length(cl)
  [ispec,am,ph,omega,alpha,constitNum] = constit(cl(i,:));
  periods(i) = 2*pi/omega;
end
fileID = fopen('periods.txt','w');
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
