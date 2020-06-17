clear; close all
% addpath('C:\Users\Tim West\Documents\GitHub\ABC_Inference_Neural_Paper')
addpath('C:\Users\timot\Documents\GitHub\ABC_Inference_Neural_Paper')

R = ABCAddPaths('C:\Users\timot\Documents\GitHub\PeripheralStim_ABC','firstRun');
% R.root = 'C:\Users\Tim West\Documents\GitHub\PeripheralStim_ABC\';
R = simannealsetup_periphStim(R);

mkdir([R.path.rootn 'outputs\' R.path.projectn '\data\Shenghong\'])
if ~exist([R.path.rootn 'outputs\' R.path.projectn '\data\Shenghong\data.mat'])
    dataOut = shenghongTremorData(R);
    save([R.path.rootn 'outputs\' R.path.projectn '\data\Shenghong\data.mat'],'dataOut')
else
    load([R.path.rootn 'outputs\' R.path.projectn '\data\Shenghong\data.mat'],'dataOut')
end

% Juse use condition (1) for now (tremor); (2) is rest
C = 1;s
dataInd = [find(startsWith(dataOut(C).label,'ACCR'));
    find(startsWith(dataOut(C).label,'C3'));
    find(startsWith(dataOut(C).label,'HaR'));
    find(startsWith(dataOut(C).label,'L23'))];

data{1} = [dataOut(C).trial{:}]';
data{1} = data{1}(:,dataInd);
data{1} = data{1}';
R.obs.trans.norm = 0;
R.obs.trans.logdetrend = 0;
R.obs.trans.gauss3 = 0;
R.obs.trans.gausSm = 1; % 10 hz smooth window
[R.data.feat_xscale, R.data.feat_emp] = R.obs.transFx(data,R.chloc_name,R.chsim_name,1000,R.obs.SimOrd,R);
npdplotter_110717({R.data.feat_emp},[],R.data.feat_xscale,R,[],[]);
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
R.SimAn.rep = 512;
R.Bcond = 0;
R.plot.flag = 1;
% R.obs.gainmeth = {R.obs.gainmeth{1}};
[p] = SimAn_ABC_250320(R,pc,m);

% Do posthoc analysis
R.comptype = 1; % i.e. dont do conf matrix style N x N
modID = modelCompMaster_021019(R,1,[]);
% Plot output
load([R.pathrootn 'outputs\' R.out.tag '\' R.out.dag '\modeProbs_' R.out.tag '_' R.out.dag '.mat'])
A = varo; %i.e. permMod
f = figure;
            [hl, hp, dl, flag] = PlotFeatureConfInt_gen060818(R,A,f);
