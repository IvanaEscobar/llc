%read the mygrid from the input (not mds) mygrid file
%this routine is an adaptation of 
%/net/ross/raid2/gforget/mygrids/gael_code_v2/faces2mitgcm/mitgcmmygrid_read.m
%examples of dirGrid:
%dirGrid='/raid3/gforget/grids/gridCompleted/llcRegLatLon/llc_540/';
%grid_load_native(dirGrid,'llc');

useNativeFormat=1;

nx=270;ncut1=480;ncut2=ncut1/4;%120
niout = [   nx    nx nx ncut2 ncut1];
njout = [ncut1 ncut2 nx nx    nx   ];

dirGrid='/net/weddell/raid3/gforget/grids/gridCompleted/llcRegLatLon/llc_dec09_270/';
dirGridOut='/net/nares/raid8/ecco-shared/llc270/aste/GRID/';

files=dir([dirGrid '*bin']);
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
    if strfind(dirGrid,'cs32_tutorial_held_suarez_cs');
        ni=32; nj=32;
    else;
        tmp2=strfind(tmp1,'_');
        ni=str2num(tmp1(tmp2(2)+1:tmp2(3)-1));
        nj=str2num(tmp1(tmp2(3)+1:end-4));
    end;
    if iFile==1; MM=ni; end;
    outfile = [dirGridOut 'redllc_00' int2str(iFile) '_' ...
              int2str(niout(iFile)) '_' int2str(njout(iFile)) '.bin' ]
    fid=fopen([dirGrid files(iFile).name],'r','b');
    fidout=fopen(outfile,'w','b');
    for iFld=1:length(list_fields);
        eval(['nni=' list_ni{iFld} ';']);
        eval(['nnj=' list_nj{iFld} ';']);
%ph(
[iFile iFld ni nj nni nnj]
%pause(2)
%
%ph)
        tmp1=fread(fid,[ni+1 nj+1],'float64');
        tmpout=zeros([niout(iFile)+1 njout(iFile)+1]);
whos tmp1
%
        if iFile==1
          tmpout=tmp1(1:niout(iFile)+1,nx*3-njout(iFile)+1:nx*3+1);
        elseif iFile==2
          tmpout=tmp1(1:niout(iFile)+1,nx*3-njout(iFile)+1:nx*3+1);
        elseif iFile==3
          tmpout=tmp1(1:niout(iFile)+1,1:njout(iFile)+1);
        elseif iFile==4
          tmpout=tmp1(1:niout(iFile)+1,1:njout(iFile)+1);
        elseif iFile==5
          tmpout=tmp1(1:niout(iFile)+1,1:njout(iFile)+1);
        end
%
        fwrite(fidout,tmpout,'float64');
%
        eval([list_fields{iFld} '{' num2str(iFile) '}.vals=tmp1(1:nni,1:nnj);']);
        eval([list_fields{iFld} '{' num2str(iFile) '}.x=''' list_x{iFld} ''';']);
    end;
    fclose(fidout);
    fclose(fid);
    xS{iFile}.vals=(xG{iFile}.vals(2:end,:)+xG{iFile}.vals(1:end-1,:))/2;
    yS{iFile}.vals=(yG{iFile}.vals(2:end,:)+yG{iFile}.vals(1:end-1,:))/2;
    xW{iFile}.vals=(xG{iFile}.vals(:,2:end)+xG{iFile}.vals(:,1:end-1))/2;
    yW{iFile}.vals=(yG{iFile}.vals(:,2:end)+yG{iFile}.vals(:,1:end-1))/2;
end;

%%%%%%%%%%%%%%%
test_plot=0;
if(test_plot==1);
  dirGrid='/net/weddell/raid3/gforget/grids/gridCompleted/llcRegLatLon/llc_dec09_270/';
  dirRGrid='net/nares/raid8/ecco-shared/llc270/aste/GRID/';
  list_fields2={'XC','YC','DXF','DYF','RAC','XG','YG','DXV','DYU','RAZ',...
                'DXC','DYC','RAW','RAS','DXG','DYG'};

% face1
  ffo=readbin([dirGrid 'llc_001_270_810.bin'],[271 270*3+1 16],1,'float64');
  ff =readbin([dirRGrid 'redllc_001_270_480.bin'],[271 481 16],1,'float64');
  for k=1:16;
    clf;subplot(121);mypcolor(ffo(:,:,k)');aa=caxis;caxis(aa);thincolorbar;
        subplot(122);mypcolor(ff(:,:,k)');caxis(aa);thincolorbar;title(list_fields2{k});
    pause;
  end;

% face2
  ffo=readbin([dirGrid 'llc_002_270_810.bin'],[271 270*3+1 16],1,'float64');
  ff =readbin([dirRGrid 'redllc_002_270_120.bin'],[271 121 16],1,'float64');

  for k=1:16;
    clf;subplot(121);mypcolor(ffo(:,:,k)');aa=caxis;caxis(aa);thincolorbar;
        subplot(122);mypcolor(ff(:,:,k)');caxis(aa);thincolorbar;title(list_fields2{k});
    pause;
  end;

end;
