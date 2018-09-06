%read the mygrid from the input (not mds) mygrid file
%this routine is an adaptation of 
%/net/ross/raid2/gforget/mygrids/gael_code_v2/faces2mitgcm/mitgcmmygrid_read.m
%examples of dirGrid:
%dirGrid='/raid3/gforget/grids/gridCompleted/llcRegLatLon/llc_540/';
%grid_load_native(dirGrid,'llc');

clear all;
warning off;

define_indices;

set_directory;

useNativeFormat=1;

%actual indices on the faces:
for i=1:6;
  str=num2str(i);
  eval(['tmp=exist(''ix' str ''',''var'');']);
  if(tmp>0);
    eval(['Lx' str '=length(ix' str ');']);
    eval(['Ly' str '=length(iy' str ');']);
  else;
    eval(['Lx' str '=0;']);
    eval(['Ly' str '=0;']);
  end;
end
%1%same as [ncut1 ncut2] = [2160 1080]
%5%        [ncut2 ncut1] = [1080 2160]

[Lx1 Ly1 Lx5 Ly5]			%2160 1080 1080 2160

niout = [  Lx1     0  0 0     Lx5    0];
njout = [  Ly1     0  0 0     Ly5    0];
niin  = [   nx    nx nx nx*3  nx*3  nx];
njin  = [ nx*3  nx*3 nx nx    nx    nx];

%dirGrid='/net/weddell/raid3/gforget/grids/gridCompleted/llcRegLatLon/llc_dec09_270/';
%dirGridOut='/net/nares/raid8/ecco-shared/llc270/aste/GRID/';

files=dir([dirGrid_global_real8 'tile00*.mitgrid']);
if(length(files)==0);error('missing tile00*.mitgrid for fine resolution grid');end;
tmp1=[]; 
for ii=1:length(files); 
    if isempty(strfind(files(ii).name,'FM')); tmp1=[tmp1;ii]; end; 
end;
files=files(tmp1);

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

Nfaces=length(files);

for iFile=1:Nfaces;
    tmp1=files(iFile).name
    if strfind(dirGrid_global_real8,'cs32_tutorial_held_suarez_cs');
        ni=32; nj=32;
    else;
         ni = niin(iFile);
         nj = njin(iFile);
    end;
    outfile = [dirGridOut 'tile00' int2str(iFile) '.mitgrid'];
    fidout=fopen(outfile,'w','b');

    fid=fopen([dirGrid_global_real8 files(iFile).name],'r','b');
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
%whos tmp1
%

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
