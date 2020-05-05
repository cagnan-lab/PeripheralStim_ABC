clear; close all
addpath('C:\Users\Tim West\Documents\GitHub\ABC_Inference_Neural_Paper')
% addpath('C:\Users\timot\Documents\GitHub\ABC_Inference_Neural_Paper')

R = ABCAddPaths('C:\Users\Tim West\Documents\GitHub\PeripheralStim_ABC','firstRun');
% R = ABCAddPaths('C:\Users\timot\Documents\GitHub\PeripheralStim_ABC','firstRun');

R = simannealsetup_periphStim(R);

% Bi condition Settings!
R.condnames = {'Tremor','Rest'};
R.Bcond = 2; % Which condition is the modulating?
R.SimAn.pOptList = {'.int{src}.T','.int{src}.G','.int{src}.S','.C','.A','.D','.obs.Cnoise','.B'}; %
R.SimAn.scoreweight = [1 1/1e8];
R.obs.gainmeth{2} = 'unitvarConcat';


mkdir([R.path.rootn 'outputs\' R.path.projectn '\data\Shenghong\'])
if ~exist([R.path.rootn 'outputs\' R.path.projectn '\data\Shenghong\data.mat'])
    dataOut = shenghongTremorData(R);
    save([R.path.rootn 'outputs\' R.path.projectn '\data\Shenghong\data.mat'],'dataOut')
else
    load([R.path.rootn 'outputs\' R.path.projectn '\data\Shenghong\data.mat'],'dataOut')
end

% Juse use condition (1) for now (tremor); (2) is rest
for C = 1:2
    dataInd = [find(startsWith(dataOut(C).label,'ACCR'));
        find(startsWith(dataOut(C).label,'C3'));
        find(startsWith(dataOut(C).label,'HaR'));
        find(startsWith(dataOut(C).label,'L23'))];
    
    data{C} = [dataOut(C).trial{:}]';
    data{C} = data{C}(:,dataInd);
    dataStore{C} = data{C}';
end

R.obs.trans.norm = 0;
R.obs.trans.normcat = 0;
R.obs.trans.logdetrend = 0;
R.obs.trans.gauss3 = 0;
R.obs.trans.gausSm = 1; % 10 hz smooth window
[R.data.feat_xscale, R.data.feat_emp] = R.obs.transFx(dataStore,R.chloc_name,R.chsim_name,1000,R.obs.SimOrd,R);
R.plot.outFeatFx({R.data.feat_emp},[],R.data.feat_xscale,R,[],[]);
clear data dat

% Peripheral Stim
[R pc m uc] = MS_periphStim_Model_2(R);
R = setSimTime(R,26);

% Revert back
R.obs.trans.gausSm = 0;
R.obs.trans.logdetrend = 0;

% Model Inversion
R.out.dag = 'DH_model1'; %
R.out.tag = '011019';
R.SimAn.rep = 32;
R.Bcond = 0;
R.plot.flag = 1;
[p] = SimAn_ABC_250320(R,pc,m);

% Do posthoc analysis
R.comptype = 1; % i.e. dont do conf matrix style N x N
modID = modelCompMaster_021019(R,1,[]);
% Plot output
load([R.pathrootn 'outputs\' R.out.tag '\' R.out.dag '\modeProbs_' R.out.tag '_' R.out.dag '.mat'])
A = varo; %i.e. permMod
f = figure;
[hl, hp, dl, flag] = PlotFeatureConfInt_gen060818(R,A,f);
