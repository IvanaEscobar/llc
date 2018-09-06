clear all;
dirRoot='/scratch/atnguyen/aste_1080x1440x540x90/';
a=load([dirRoot 'run_obcs_prof2_ctrl_kpp_pk0000000000/advcfl_W_hf_max.txt']);ta=[1:length(a)].*30/3600;
b=load([dirRoot 'run_obcs_prof2_ctrl_kpp_it_pk0000000000_dt60unstab/advcfl_W_hf_max.txt']);tb=[1:length(b)].*60/3600;
c=load([dirRoot 'run_obcs_prof2_ctrl_kpp_pk0000000001/advcfl_W_hf_max.txt']);tc=[1:length(c)].*60/3600;
d=load([dirRoot 'run_obcs_prof2_ctrl_kpp_pk0000000002/advcfl_W_hf_max.txt']);td=[1:length(d)].*120/3600;
f=load([dirRoot 'run_obcs_prof2_ctrl_kpp_pk0000000003/advcfl_W_hf_max.txt']);tf=[1:length(f)].*240/3600;
g=load([dirRoot 'run_obcs_prof2_ctrl_kpp_pk0000000004/advcfl_W_hf_max.txt']);tg=[1:length(g)].*360/3600;

figure(1);clf;
plot(ta,a,'b-',tb,b,'r-',tc,c,'g-',td,d,'m-',tf,f,'c-',tg,g,'k-');grid;
xlabel('hours');
legend('pk0dt30','pk0dt60','pk1dt60','pk2dt120','pk3dt240','pk4dt360');
