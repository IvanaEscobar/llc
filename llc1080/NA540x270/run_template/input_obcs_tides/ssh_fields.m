addpath(genpath('/net/barents/raid16/vocana/llc4320/NA2160x1080/run_template/joernc/tides/tmd_mar_203/TMD2.03'));
addpath(genpath('/data4/joernc/MITgcm/utils/matlab'))

% model start time
time = datenum(2012,01,01);

% model lat/lon
load('coords.mat')

for i = 1:(366+365)*24
  z = tmd_tide_pred('DATA/Model_tpxo7.2', time, lat, lon, 'z');
  filename = sprintf('ssh/ssh_%010d.mat', i*3600/240)
  save(filename, 'z')
end
