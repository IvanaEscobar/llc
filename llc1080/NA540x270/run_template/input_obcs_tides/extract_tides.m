% This script extracts the TPXO tidal predictions at the OBC locations using
% TMD, converts them into the format used by the MITgcm, and saves the
% information to input files.

% NOTE ON NODAL CORRECTIONS
% The prescription of tides in the MITgcm using the OBCS package requires a
% fixed frequency and amplitude for each tidal constituent. That way of
% prescribing the tides thus precludes the possibility of nodal corrections. The
% way this is implemented for now is that the nodal corrections are applied at a
% reference time, and held constant over the period of the run. If the run time
%  is comparable to the 18.6-yr cycle, this becomes problematic. Another, and
% possibly preferable, way of prescibing the tides would be through time series
% of tidal velocities at the boundary instead of through amplitudes and phases.

addpath(genpath('/net/barents/raid16/vocana/llc4320/NA2160x1080/run_template/joernc/tides/tmd_mar_203/TMD2.03'));
addpath(genpath('/data4/joernc/MITgcm/utils/matlab'))

% model start time
%time = datenum(2011,12,15);
time = datenum(2012,01,01);

% pad for other face
pad = 270;

% load OBC locations
load(['NA540x270_latlon_fortides.mat'],'Face1','Face5');

fprintf('--- testing ---\n');
t = 60+3/24;
c = 4;
lat = 27*ones(1,81);
lon = -80:0;
[vam,vph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',lat,lon,'v');
[vamc,vphc] = conv_corr(datenum(1992,1,1),vam,vph,cl);
% predict K1 tide at 35N/60W at 6am on 2012-01-01 using TMD
v_tmd = tmd_tide_pred('DATA/Model_tpxo7.2',datenum(1992,1,1)+t,lat,lon,'v',[c])
% predict tide as in MITgcm
[ispec,am,ph,omega,alpha,constitNum] = constit(cl(c,:));
v_mod = vamc(c,:).*cos(omega*(t*86400-vphc(c,:)))*100

pause

% face 1: v at S, save as v at S
[vam,vph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face1.latS,Face1.lonS,'v');
[vam,vph] = conv_corr(time,vam,vph,cl);
vam(isnan(vam)) = 0;
vph(isnan(vph)) = 0;
vam = [vam,zeros(13,pad)]; % pad for face 5
vph = [vph,zeros(13,pad)]; % pad for face 5
writebin('OBSam.bin',vam',1,'real*4'); % write amplitude
writebin('OBSph.bin',vph',1,'real*4'); % write phase
%vam(1:3,:,:) = 0;
%vam(5:end,:,:) = 0;
%writebin('OBSam_K2only.bin',vam',1,'real*4'); % write amplitude
%writebin('OBSph_K2only.bin',vph',1,'real*4'); % write phase

% face 1: v at N, save as v at N
[vam,vph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face1.latN,Face1.lonN,'v');
[vam,vph] = conv_corr(time,vam,vph,cl);
vam(isnan(vam)) = 0;
vph(isnan(vph)) = 0;
vam = [vam,zeros(13,pad)]; % pad for face 5
vph = [vph,zeros(13,pad)]; % pad for face 5
writebin('OBNam.bin',vam',1,'real*4'); % write amplitude
writebin('OBNph.bin',vph',1,'real*4'); % write phase
%vam(1:3,:,:) = 0;
%vam(5:end,:,:) = 0;
%writebin('OBNam_K2only.bin',vam',1,'real*4'); % write amplitude
%writebin('OBNph_K2only.bin',vph',1,'real*4'); % write phase

% face 5: v at S, save as -u at E
[vam,vph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face5.latE,Face5.lonE,'v');
[vam,vph] = conv_corr(time,vam,vph,cl);
vam(isnan(vam)) = 0;
vph(isnan(vph)) = 0;
vam = [zeros(13,pad),vam]; % pad for face 1
vph = [zeros(13,pad),vph]; % pad for face 1
writebin('OBEam.bin',-vam',1,'real*4'); % write amplitude
writebin('OBEph.bin',vph',1,'real*4'); % write phase
%vam(1:3,:,:) = 0;
%vam(5:end,:,:) = 0;
%writebin('OBEam_K2only.bin',-vam',1,'real*4'); % write amplitude
%writebin('OBEph_K2only.bin',vph',1,'real*4'); % write phase

% face 5: v at N, save as -u at W
[vam,vph,h,cl] = tmd_extract_HC('DATA/Model_tpxo7.2',Face5.latW,Face5.lonW,'v');
[vam,vph] = conv_corr(time,vam,vph,cl);
vam(isnan(vam)) = 0;
vph(isnan(vph)) = 0;
vam = [zeros(13,pad),vam]; % pad for face 1
vph = [zeros(13,pad),vph]; % pad for face 1
writebin('OBWam.bin',-vam',1,'real*4'); % write amplitude
writebin('OBWph.bin',vph',1,'real*4'); % write phase
%vam(1:3,:,:) = 0;
%vam(5:end,:,:) = 0;
%writebin('OBWam_K2only.bin',-vam',1,'real*4'); % write amplitude
%writebin('OBWph_K2only.bin',vph',1,'real*4'); % write phase

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
