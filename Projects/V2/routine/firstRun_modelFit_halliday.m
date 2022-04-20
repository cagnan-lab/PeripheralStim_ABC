clear; close all
addpath('C:\Users\Tim West\Documents\GitHub\ABC_Inference_Neural_Paper')

R = ABCAddPaths('C:\Users\Tim West\Documents\GitHub\PeripheralStim_ABC','firstRun');
% R.root = 'C:\Users\Tim West\Documents\GitHub\PeripheralStim_ABC\';
R = simannealsetup_periphStim(R);

% get data
R.obs.obsstates = [1 2];
load([R.path.datapath  '\mv_20a.mat'])
dat = dat(:,[2 1]); % make sure EMG is first
dat(:,2) = abs(dat(:,2));
% Take epochs of contraction
ppdata = [];
for i = 1:numel(st1)
xl =  [st1(i)'+200:(st1(i)'+200)+dur1(i)'-100];
xl = dat(xl,:).*hanning(size(xl,2));
ppdata = [ppdata; xl];
end

% ppdata = ft_preproc_bandstopfilter(ppdata',1000,[52 48]);

data{1}([1 2],:) = ppdata';

R.obs.trans.norm = 1;
R.obs.trans.logdetrend = 1;
R.obs.trans.gauss3 = 0;
R.obs.trans.gausSm = 10; % 10 hz smooth window
[R.data.feat_xscale, R.data.feat_emp] = R.obs.transFx(data,R.chloc_name,R.chsim_name,1000,R.obs.SimOrd,R);
npdplotter_110717({R.data.feat_emp},[],R.data.feat_xscale,R,[],[]);
clear data dat

% Peripheral Stim
[R pc m uc] = MS_periphStim_Model_2(R);
R = setSimTime(R,32);

% Revert back
R.obs.trans.gausSm = 0;
R.obs.trans.logdetrend = 0;

% Model Inversion
R.out.dag = 'DH_model1'; % 
R.out.tag = '011019';
R.SimAn.rep = 256;
R.Bcond = 0;
R.plot.flag = 1;
% R.obs.gainmeth = {R.obs.gainmeth{1}};
[p] = SimAn_ABC_250320(R,pc,m);

% Do posthoc analysis
R.comptype = 1; % i.e. dont do conf matrix style N x N
modID = modelCompMaster_021019(R,1,[]);
% Plot output
load([R.rootn 'outputs\' R.out.tag '\' R.out.dag '\modeProbs_' R.out.tag '_' R.out.dag '.mat'])
A = varo; %i.e. permMod
f = figure;
            [hl, hp, dl, flag] = PlotFeatureConfInt_gen060818(R,A,f);
