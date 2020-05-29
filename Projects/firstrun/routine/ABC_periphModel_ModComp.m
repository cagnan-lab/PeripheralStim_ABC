clear; close all
addpath('C:\Users\Tim West\Documents\GitHub\ABC_Inference_Neural_Paper')
% addpath('C:\Users\timot\Documents\GitHub\ABC_Inference_Neural_Paper')

R = ABCAddPaths('C:\Users\Tim West\Documents\GitHub\PeripheralStim_ABC','firstRun');
% R = ABCAddPaths('C:\Users\timot\Documents\GitHub\PeripheralStim_ABC','firstRun');

R = simannealsetup_periphStim(R);

% Bi condition Settings!
R.condnames = {'Tremor'}; %,'Rest'};
R.Bcond = 0; % 2Which condition is the modulating?
R.SimAn.pOptList = {'.int{src}.T','.int{src}.G','.int{src}.S','.C','.A','.D','.obs.Cnoise'}; %,'.B'}; %
R.SimAn.scoreweight = [1 1/1e8];

R.obs.gainmeth{1} = 'obsnoise';
% R.obs.gainmeth{2} = 'unitvar';
R.obs.gainmeth{2} = 'boring';
R.obs.condchecker = 0; %1;
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
    %     data{C} = (data{C}-mean(data{C}))./std(data{C});
    dataStore{C} = data{C}';
end

R.obs.trans.norm = 0;
R.obs.trans.zerobase = 1;
R.obs.trans.normcat = 1;
R.obs.trans.logdetrend = 0;
R.obs.trans.gauss3 = 0;
R.obs.trans.gausSm = 1; % 10 hz smooth window
[R.data.feat_xscale, R.data.feat_emp] = R.obs.transFx(dataStore,R.datinds,1000,R.obs.SimOrd,R);
R.plot.outFeatFx({R.data.feat_emp},[],R.data.feat_xscale,R,[],[]);
clear data dat

%% Start Loop (for parallel sessions)
R.out.tag = 'periphModel_MSET1_v1';
try
    load([R.path.rootn '\outputs\' R.out.tag '\WorkingModList'])
    disp('Loaded Mod List!!')
catch
    WML = [];
    mkdir([R.path.rootn '\outputs\' R.out.tag ]);
    save([R.path.rootn '\outputs\' R.out.tag '\WorkingModList'],'WML')
    disp('Making Mod List!!')
end

% Revert back
R.obs.trans.gausSm = 0;
R.obs.trans.logdetrend = 0;


for modID = 1:7
    if modID == 7
        R.obs.Cnoise = R.obs.Cnoise;
        R.obs.LF = R.obs.LF ; % Fit visually and for normalised data
        R.nmsim_name = {'Musc1','MMC','SpinCrd','THAL','Cereb'}; %modules (fx) to use.
        R.chsim_name = {'EP','ctx','amn','Thal','Cereb'}; % simulated channel names (names must match between these two!)
        R.siminds = 1:5;
    else
       R.obs.Cnoise = R.obs.Cnoise(1:4);
        R.obs.LF = R.obs.LF(1:4); % Fit visually and for normalised data
        R.nmsim_name = {'Musc1','MMC','SpinCrd','THAL'}; %modules (fx) to use.
        R.chsim_name = {'EP','ctx','amn','Thal'}; % simulated channel names (names must match between these two!)
        R.siminds = 1:4;
    end
    load([R.path.rootn '\outputs\' R.out.tag '\WorkingModList'],'WML')
    if ~any(intersect(WML,modID))
        WML = [WML modID];
        save([R.path.rootn '\outputs\' R.out.tag '\WorkingModList'],'WML')
        disp('Writing to Mod List!!')
        fprintf('Now Fitting Model %.0f',modID)
        f = msgbox(sprintf('Fitting Model %.0f',modID));
        
        %% Prepare Model
        modelspec = eval(['@MS_periphStim_MSET1_M' num2str(modID)]);
        [R p m uc] = modelspec(R); % M! intrinsics shrunk"
        pause(5)
        R.out.dag = sprintf([R.out.tag '_M%.0f'],modID); % 'All Cross'
        
        %% Run ABC Optimization
        R = setSimTime(R,32);
        R.Bcond = 0;
        R.SimAn.rep = 64;
        SimAn_ABC_250320(R,p,m);
        closeMessageBoxes
    end
end
