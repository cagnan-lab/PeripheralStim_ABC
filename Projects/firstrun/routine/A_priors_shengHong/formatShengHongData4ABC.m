function R = formatShengHongData4ABC(R,fresh)
% This function converts ShengHongs data to format required for ABC
mkdir([R.path.rootn '\outputs\' R.path.projectn '\data\Shenghong\'])
if fresh
    dataOut = prepareShengHongTremorData(R);
    save([R.path.rootn '\outputs\' R.path.projectn '\data\Shenghong\data.mat'],'dataOut')
else
    load([R.path.rootn '\outputs\' R.path.projectn '\data\Shenghong\data.mat'],'dataOut')
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
if numel(R.chsim_name)>1
    R.datinds = [3 4 1 2]; % maps from data inds to that of the order of simulated modules specified in R.chsim_name 
else
    R.datinds = 4;
    disp('Using Thalamus as Cerebellar Spectra')
end
figure(42)
plotTremorTimeSeries(dataStore,dataOut(1).fsample,{'Acc.','EEG (C3)','EMG (R)','Thal. LFP (L23)'},R.condnames)

figure(43)
R.obs.trans.gausSm = 5; % switch on smoothing
[R.data.feat_xscale, R.data.feat_emp] = R.obs.transFx(dataStore,R.datinds,dataOut(1).fsample,R.obs.SimOrd,R);
R.obs.trans.gausSm = 0; % turn it off for simulations
R.plot.outFeatFx({R.data.feat_emp},[],R.data.feat_xscale,R,[],[]);
a  = 1;

