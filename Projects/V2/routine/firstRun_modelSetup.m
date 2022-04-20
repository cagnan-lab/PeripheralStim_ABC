clear; close all
R = ABCAddPaths('PeripheralStim','firstRun');
R = simannealsetup_periphStim(R);

[R pc m uc] = MS_periphStim_Model1(R);
R = setSimTime(R,100);

uc = innovate_timeseries(R,m);
tx = makeTremorSignal(R,8,0.3);
tx = 10.*tx.*sqrt(R.IntP.dt);
uc{1}(:,2) = tx;

R.data.datatype = 'none';
R.obs.gainmeth = {'unitvar'};
[r2,pnew,feat_sim,xsims,xsims_gl,wflag] = computeSimData120319(R,m,uc,pc,0,0);

figure
plot(R.IntP.tvec,uc{1}(:,2)); hold on;
plot(R.IntP.tvec_obs,xsims_gl{1}');
legend({'TremorIn','Endplate','Spindle','AMN','IIN'})
figure
R.plot.outFeatFx({},{feat_sim},R.frqz,R,1,[])
% % Pertubation analysis
% uc{1}(:,1) = tx;
%
% R.data.datatype = 'none';
% [r2,pnew,feat_sim,xsims,xsims_gl,wflag] = computeSimData120319(R,m,uc,pc,0,0);
%
% plot(R.IntP.tvec_obs,xsims_gl{1}');
% legend({'Endplate','Spindle','AMN','IIN'})
