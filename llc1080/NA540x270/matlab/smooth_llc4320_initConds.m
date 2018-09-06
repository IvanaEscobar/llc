
clear all; close all;

%Read initial conditions
%datDir = '/net/barents/raid16/vocana/llc4320/NA2160x1080/run_template/INIT_CONDS/';
datDir = '/net/barents/raid16/vocana/llc1080/NA540x270/run_template/INIT_CONDS/';
outDir = datDir;

nx = 540; ny = 540; nz = 106;
nx2 = 2*nx; 

exp_factor = nx2/270;                %Factor by which the grid has been expanded; i.e. from llc270 to llc 4320 exp_factor=16;
smooth_factor  = exp_factor/2 - 1;    %Number of points for the smoothing

iStr = 'input_init_NAllc1080_Jan2012_';
oStr = 'input_initSmooth_NAllc1080_Jan2012_';

strL = {'T' 'S' 'U' 'V' };
for ii = 2:size(strL,2);
   fout = [outDir oStr strL{ii}];
   fid  = fopen(fout,'a+','b');
   disp(strL{ii})
   disp('Level')
   for jj = 1:nz;
%   temp = readbin([datStr 'input_init_NAllc4320_Jan2012_' strL{ii}],[2160 2160 106]);
      temp  = read_slice([datDir iStr strL{ii}],nx,ny,jj, 'real*4');
      temp1 = temp(:,1:ny/2); temp5 = temp(:,ny/2+1:end);
      temp5 = reshape(temp5,size(temp5,2),size(temp5,1)); temp5 = sym_g_mod(temp5,7);
      temm  = [temp5' temp1']'; clear temp temp1 temp5;
      temm  = smooth2a(temm,smooth_factor);
      
      temp5 = temm(1:nx,:); temp1 = temm(nx+1:end,:);
      temp5 = sym_g_mod(temp5,5); temp5 = reshape(temp5,size(temp5,2),size(temp5,1));
      temm  = [temp1 temp5]; clear temp temp1 temp5; 
      fwrite(fid,temm,'real*4');
      clear temm
      disp(jj)
   end
   fclose(fid);
end
%





