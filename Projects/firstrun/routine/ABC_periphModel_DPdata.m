clear; close all
closeMessageBoxes
addpath('C:\Users\Tim West\Documents\GitHub\ABC_Inference_Neural_Paper')
% addpath('C:\Users\timot\Documents\GitHub\ABC_Inference_Neural_Paper')

% R = ABCAddPaths('C:\Users\Tim West\Documents\GitHub\PeripheralStim_ABC','firstRun');
R = ABCAddPaths('C:\Users\timot\Documents\GitHub\PeripheralStim_ABC','firstRun');

% YOU NEED TO MAKE SURE DATA MATCHES UP WITH THE CORRECT SOURCES IN THE
% MODEL!


%% Initialize
R = simannealsetup_periphStim_dpdata(R);
R.out.tag = 'dptest_sub';
% Bi condition Settings!
R.condnames = {'Tremor','Rest'};
R.Bcond = 2; % 2Which condition is the modulating?
R.SimAn.pOptList = {'.int{src}.T','.int{src}.G','.int{src}.S','.C','.A','.D','.B','.obs.Cnoise'}; %,'.B'}; %
R.SimAn.scoreweight = [1 1/1e6];

R.obs.gainmeth{1} = 'obsnoise';
% R.obs.gainmeth{2} = 'unitvar';
R.obs.gainmeth{2} = 'boring';
R.obs.condchecker = 0; %1;
R.sublist = {'subj1r','subj3l','subj4l','subj6l','subj6r','subj8l','subj9r','subj10l','subj10r','subj12l','subj13l','subj14r'};

%% Start Loop (for parallel sessions)
try
    load([R.path.rootn '\outputs\' R.out.tag '\WorkingModList'])
    disp('Loaded Mod List!!')
catch
    WML = [];
    mkdir([R.path.rootn '\outputs\' R.out.tag ]);
    save([R.path.rootn '\outputs\' R.out.tag '\WorkingModList'],'WML')
    disp('Making Mod List!!')
end

% Pretend the current sub is 1
for cursub = [1 6 8 11] %1:numel(R.sublist)
    load([R.path.rootn '\outputs\' R.out.tag '\WorkingModList'],'WML')
    if ~any(intersect(WML,cursub))
        WML = [WML cursub];
        save([R.path.rootn '\outputs\' R.out.tag '\WorkingModList'],'WML')
        disp('Writing to Sub List!!')
        fprintf('Now Fitting Subject %.0f',cursub)
        f = msgbox(sprintf('Fitting Subject %.0f',cursub));
        
        %% Load in time series data from DPs set
        mkdir([R.path.rootn '\outputs\' R.path.projectn '\data\DP\thalamomuscular'])
        subdatafile = [R.path.rootn '\outputs\' R.path.projectn '\data\DP\thalamomuscular\dp_thalamomuscular_' R.sublist{cursub} '_pp.mat'];
%         if ~exist(subdatafile) 
            dataOut = getDP_thalamomuscular_data(R,R.sublist{cursub});
            save(subdatafile,'dataOut')
%         else
%             load(subdatafile)
%         end
        
        % Juse use condition (1) for now (posture); (2) is rest
        for C = 1:2
            data{C} = [dataOut(C).trial{:}]';
            data{C} = data{C}(:,:);
%             data{C} = (data{C}-mean(data{C}))./std(data{C});
            dataStore{C} = data{C}';
        end
        fs_emp = dataOut.fsample;
%         clear data dataOut
        
        % Setup data transform
        R.obs.trans.norm = 0;
        R.obs.trans.zerobase = 1;
        R.obs.trans.normcat = 1;
        R.obs.trans.logdetrend = 0;
        R.obs.trans.gauss3 = 0;
        R.obs.trans.interptype = 'linear'; %'pchip';
        R.obs.trans.gausSm = 5; % 10 hz smooth window
        R.obs.SimOrd = 11;
        [R.data.feat_xscale, R.data.feat_emp] = R.obs.transFx(dataStore,R.datinds,fs_emp,R.obs.SimOrd,R);
        R.plot.outFeatFx({R.data.feat_emp},[],R.data.feat_xscale,R,[],[]);
        clear data dat
        % Revert back for simulated data
        R.obs.trans.gausSm = 0;
        R.obs.trans.logdetrend = 0;
        
        %% Prepare Model
        modID = 1;
        modelspec = eval(['@MS_periphStim_BMOD_MSET1_M' num2str(modID)]);
        [R dum m uc] = modelspec(R); % M! intrinsics shrunk"
        
        load([R.path.rootn '\Projects\' R.path.projectn '\empirical_priors\shenghong_modelfit.mat'])
        
        p = A.Pfit;
        % Modify so B matrix is available
        p.B{1}(4,1) = 0; % Spin to Thal
        p.B{1}(3,2) = 0; % MMC to SC
        p.B{1}(4,2) = 0; % MMC to Thal
        p.B{1}(2,4) = 0; % Thal to CTX
        p.B_s{1} = repmat(1/2,size(p.A_s{1})).*(p.B{1}==0);
        
        pause(5)
        R.out.dag = sprintf([R.out.tag '_BMOD_MSET%.0f_' R.sublist{cursub}],modID); % 'All Cross'
        
        %% Run ABC Optimization
        R = setSimTime(R,32);
        R.Bcond = 2;
        R.SimAn.rep = 256;
        SimAn_ABC_250320(R,p,m);
        closeMessageBoxes
    end
end
