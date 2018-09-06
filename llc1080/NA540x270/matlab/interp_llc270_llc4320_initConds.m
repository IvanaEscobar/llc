function []=extract_llc270aste_framSt_raw()

% 24.Oct.2016
% 
% Interpolate ASTE iteration 12, 3d fields for the domain  North Atlantic hi res
% 
% !!!!!!!!!!!!!!!!  NOTE !!!!!!!!!!!!!!!!!!!
% To void memory problems, variables are overwritten after each transformation
% !!!!!!!!!!!!!!!!  NOTE !!!!!!!!!!!!!!!!!!!
%
%indices for the North atlantic domain
%         llc270              	llc4320
%ix1  =    1:135;		   1:2160	
%iy1  =   226:294;		9377:10456
%
%ix5 =    157:225;		2505:3584
%iy5 =    136:270;		2161:4320
%
%kz  =      1:50;		   1:106;

clear all; close all;

% SET WORK DIRECTORIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dirRoot  = '/net/barents/raid16/vocana/llc1080/NA540x270/';
dirGrid  = '/net/nares/raid8/ecco-shared/llc270/aste_270x450x180/GRID/';
dirGrid1 = [dirRoot 'run_template/INIT_CONDS/']; 
dirRun   = [dirRoot 'run_template/INIT_CONDS/'];
dir270   = '/net/barents/raid16/vocana/llc270/NAdomain/run_template/INIT_CONDS/';
%dir270   = [dirRoot 'run_template/INIT_CONDS/INIT_llc270_NA/'];
%dirOut   = [dirGrid1 'interp/']; if(exist(dirOut)==0);mkdir(dirOut);end;
dirOut   = '/net/barents/raid16/vocana/llc1080/NA540x270/run_template/INIT_CONDS/';
readDir  = dir270;
 
%Values of DRF for vertical interpolation; 
strFld = 'DRF';
drf0 =  rdmds([dirGrid strFld]); % 50 levels
drf  = rdmds([dirGrid1 strFld]); % 106 levels
drf  = squeeze(drf); drf0  = squeeze(drf0);

%Choose variable to expand (T,S,U,V)
%=========================================
ivar =1;


%Read data for T,S,U,V, for each face;
%=========================================
if ivar == 1
  readfile1 = [readDir 'input_init_NAllc270_Jan2012_T1']; %T1 = readbin(readfile,[135 69 50]);
  readfile5 = [readDir 'input_init_NAllc270_Jan2012_T5']; %T5 = readbin(readfile,[69 135 50]);
elseif ivar ==2
  readfile1 = [readDir 'input_init_NAllc270_Jan2012_S1']; %T1 = readbin(readfile,[135 69 50]);
  readfile5 = [readDir 'input_init_NAllc270_Jan2012_S5']; %T5 = readbin(readfile,[69 135 50]);
elseif ivar ==3
  readfile1 = [readDir 'input_init_NAllc270_Jan2012_U1']; %T1 = readbin(readfile,[135 69 50]);
  readfile5 = [readDir 'input_init_NAllc270_Jan2012_U5']; %T5 = readbin(readfile,[69 135 50]);
elseif ivar ==4
  readfile1 = [readDir 'input_init_NAllc270_Jan2012_V1']; %T1 = readbin(readfile,[135 69 50]);
  readfile5 = [readDir 'input_init_NAllc270_Jan2012_V5']; %T5 = readbin(readfile,[69 135 50]);
end
disp(readfile1)
disp(readfile5)

temp1 = readbin(readfile1,[135 69 50]);
temp5 = readbin(readfile5,[69 135 50]);

%Prepare data for interpolation
%=========================================
for ii=[1 5];
  eval(['temp = temp' num2str(ii) ';']);
   temp(find(temp==0)) =nan;          % Substitute zeros with nans
   temp(isinf(temp)) = nan;
   tmx = minmax(temp);
   temp = inpaint_nans(temp);          %Paint nans to avoid jumps 0-1 in the coastline
   temp(find(temp <= tmx(1)))= tmx(1); %Substitute Nans with mins and maxs of the real values
   temp(find(temp >= tmx(2)))= tmx(2);
  eval(['temp' num2str(ii) '=temp;']);
end
clear temp;

%Interpolate
%=========================================
%  new_res = 4320; %llcXXXX
  new_res = 1080; %llcXXXX
  temp1 = interp_llc270toXXXX_face5_v5(temp1,1,1,0,0,new_res,drf,drf0); %Expand to XXXX grid
  tempt = temp1(:,5:end-2,:); temp1 = tempt; clear tempt; %Trim expanded matrices (there are some extra points for extraction calcultion reasons)
  temp5 = interp_llc270toXXXX_face5_v5(temp5,1,1,0,0,new_res,drf,drf0); 
  tempt = temp5(5:end-2,:,:); temp5 = tempt; clear tempt;

%Plot to check
%=========================================
strName ={'T' 'S' 'U' 'V'};

figure(1);clf;

ilev = 1;
for ii =1:9
  if((ii/3)<=1); 
     if (ii==1);ilev = 1; elseif(ii==2);ilev=50;elseif(ii==3);ilev=100;end;
     temp = temp1(:,:,ilev);
     titlStr = [strName{ivar} '1 - Level ' num2str(ilev) 'Face 1'];
  elseif ((ii/3)>1 && (ii/3)<=2);
     if (ii==4);ilev = 1; elseif(ii==5);ilev=50;elseif(ii==6);ilev=100;end;
     temp = temp5(:,:,ilev);
     titlStr = [strName{ivar} '1 - Level ' num2str(ilev) 'Face 5'];
  elseif ((ii/3)>2)
     if (ii==7);ilev = 1; elseif(ii==8);ilev=50;elseif(ii==9);ilev=100;end;
     temp = sym_g_mod(temp5(:,:,ilev),7);
     temp = [temp(:,:,1)' temp1(:,:,ilev)']';
     titlStr = [strName{ivar} '1 - Level ' num2str(ilev) 'Full Domain'];
  end

  subplot(3,3,ii)
  mypcolor(temp');thincolorbar;
  title(titlStr)

  clear temp;
end

%Put in compact form and write out
%The final mnatrix has size: 2160x2160x106
%=========================================
  sz1 = size(temp5,1);sz2 = size(temp5,2); sz3 = size(temp5,3);
  temp = [temp1 reshape(temp5,sz2,sz1,sz3)];
  disp(size(temp))

%Write out
%=========================================
if ivar ==1
   fileOut = [dirOut 'input_init_NAllc1080_Jan2012_T']
elseif ivar == 2
   fileOut = [dirOut 'input_init_NAllc1080_Jan2012_S']
elseif ivar == 3
   fileOut = [dirOut 'input_init_NAllc1080_Jan2012_U']
elseif ivar == 4
   fileOut = [dirOut 'input_init_NAllc1080_Jan2012_V']
end

writebin(fileOut,temp); clear temp1 temp5 temp;



