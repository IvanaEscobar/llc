
dirout=[dirin '../../'];
fsave=[dirout 'Eta_sixpoints.mat'];
save(fsave,'eta','ind','dirin');
   tt=zeros(L,6);
   idot=find(flist(1).name=='.');idot=idot(1)+1:idot(2)-1;
   for i=1:L
      ts=str2num(flist(i).name(idot));
      tmp=datevec(ts2dte(ts,90,2002,1,1));
      tt(i,1:4)=tmp(1:4);
      tt(i,5)=ts;
      tt(i,6)=datenum(tmp);
   end;
save(fsave,'eta','ind','tt','dirin');
