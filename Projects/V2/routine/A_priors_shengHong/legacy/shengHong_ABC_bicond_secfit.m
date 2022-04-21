
% Peripheral Stim
[R pc m uc] = MS_periphStim_Model_2(R);
R = setSimTime(R,26);

% Revert back
R.obs.trans.gausSm = 0;
R.obs.trans.logdetrend = 0;

% Model Inversion
R.out.dag = 'SH_model_secfit'; %
R.out.tag = '200420';
R.SimAn.rep = 512;
R.plot.flag = 1;

% Load previous fit
load([R.path.rootn 'outputs\' R.path.projectn '\'  R.out.tag  '\' R.out.dag '\initfit.mat'])
R.out.tag = '200420duel';

[p] = SimAn_ABC_250320(R,pc,m);

% Do posthoc analysis
R.comptype = 1; % i.e. dont do conf matrix style N x N
modID = modelCompMaster_021019(R,1,[]);
% Plot output
load([R.pathrootn 'outputs\' R.out.tag '\' R.out.dag '\modeProbs_' R.out.tag '_' R.out.dag '.mat'])
A = varo; %i.e. permMod
f = figure;
[hl, hp, dl, flag] = PlotFeatureConfInt_gen060818(R,A,f);
