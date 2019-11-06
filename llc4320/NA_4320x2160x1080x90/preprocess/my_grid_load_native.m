%% Read the mygrid from the input (not mds) mygrid file
% this routine is an adaptation of 
% /net/ross/raid2/gforget/mygrids/gael_code_v2/faces2mitgcm/mitgcmmygrid_read.m
% examples of dirGrid:
% dirGrid='/raid3/gforget/grids/gridCompleted/llcRegLatLon/llc_540/';
% grid_load_native(dirGrid,'llc');

%dirGrid='/net/weddell/raid3/gforget/grids/gridCompleted/llcRegLatLon/llc_dec09_270/';
%dirGridOut='/net/nares/raid8/ecco-shared/llc270/aste/GRID/';

clear all;
warning off;

define_indices;
%set_directory;
useNativeFormat=1;

%actual indices on the faces:
for i=1:6;
  face=num2str(i);
  if(exist(['ix' face],'var') == 1);
    eval(['Lx' face '=length(ix' face ');']);
    eval(['Ly' face '=length(iy' face ');']);
  else;
    eval(['Lx' face '=0;']);
    eval(['Ly' face '=0;']);
  end;
end
%1:same as [ncut1 ncut2] = [2160 1080]
%5:        [ncut2 ncut1] = [1080 2160]

[Lx1 Ly1 Lx5 Ly5];			%2160 1080 1080 2160

nx=2160; %!
niout = [  Lx1     0  0 0     Lx5    0];
njout = [  Ly1     0  0 0     Ly5    0];
niin  = [   nx    nx nx nx*3  nx*3  nx];
njin  = [ nx*3  nx*3 nx nx    nx    nx];

% fine resolution grid = child grid
%files=dir([dirs.child.Grid_global_real8 'tile00*.mitgrid']);
files=dir(['/work/05427/iescobar/stampede2/llc/llc4320/NA_4320x2160x1080x90/root/run_template/input_binaries/tile00*.mitgrid']); %!
numFaces = length(files); % same as the number of *.mitgrid files
if(numFaces==0);error('missing tile00*.mitgrid for child grid');end;

tmp1=[]; 
for ii=1:numFaces; 
    if isempty(strfind(files(ii).name,'FM')); tmp1=[tmp1;ii]; end; 
end;
files=files(tmp1); numFaces = length(files);


list_fields2={'XC','YC','DXF','DYF','RAC','XG','YG','DXV','DYU','RAZ',...
    'DXC','DYC','RAW','RAS','DXG','DYG'};
list_fields={'xC','yC','dxF','dyF','rA','xG','yG','dxV','dyU','rAz',...
    'dxC','dyC','rAw','rAs','dxG','dyG'};
list_x={'xC','xC','xC','xC','xC','xG','xG','xG','xG','xG',...
    'xW','xS','xW','xS','xS','xW'};
list_y={'yC','yC','yC','yC','yC','yG','yG','yG','yG','yG',...
    'yW','yS','yW','yS','yS','yW'};
list_ni={'ni','ni','ni','ni','ni','ni+1','ni+1','ni+1','ni+1','ni+1',...
    'ni+1','ni','ni+1','ni','ni','ni+1'};
list_nj={'nj','nj','nj','nj','nj','nj+1','nj+1','nj+1','nj+1','nj+1',...
    'nj','nj+1','nj','nj+1','nj+1','nj'};

for iFile=1:numFaces;
    tmp1=files(iFile).name
    if strfind(dirs.child.Grid_global_real8,'cs32_tutorial_held_suarez_cs');
        ni=32; nj=32;
    else;
         ni = niin(iFile);
         nj = njin(iFile);
    end;
    
    % If you want to write out to a different location specify dirGridOut
    % Ex: 
    % outfile = dirGridOut;
    % else
    outfile = files
    fidout=fopen(outfile,'w','b');

    fid=fopen([dirs.child.Grid_global_real8 files(iFile).name],'r','b');
    for iFld=1:length(list_fields);
        eval(['nni=' list_ni{iFld} ';']);
        eval(['nnj=' list_nj{iFld} ';']);

% pre-define size of output array:
        tmpout=zeros([niout(iFile)+1 njout(iFile)+1]);

%only read in the face that has non-zeros dimension, otherwise, write out only 1 grid point (+1)
  if(niout(iFile)>0 & njout(iFile)>0);
%ph(
    fprintf('[iFile iFld ni nj nni nnj]: %i %i %i %i %i %i  ',[iFile iFld ni nj nni nnj]);
%ph)
        tmp1=fread(fid,[ni+1 nj+1],'float64');
        fprintf('size(input_tile): %i %i  ',size(tmp1));

%defining indices:
        clear ix iy
        iFile_str=num2str(iFile);
        eval(['ix=ix' iFile_str ';']);
        eval(['iy=iy' iFile_str ';']);
        eval(['Lx=Lx' iFile_str ';']);
        eval(['Ly=Ly' iFile_str ';']);

        tmpout=tmp1(ix(1):(ix(1)+niout(iFile)-1)+1,iy(1):(iy(1)+njout(iFile)-1)+1);
        fprintf('size(output_tile): %i %i\n',size(tmpout));
    end;
%
        fwrite(fidout,tmpout,'float64');
%
    end;
    fclose(fidout);
    fclose(fid);
end;
