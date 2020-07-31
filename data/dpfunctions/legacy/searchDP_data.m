clear; close all
% original
load('C:\DATA\DP_Tremor_ThalamoMuscular\micro_mua_backup\subj1r_micro_mua.mat')
ORG = data_micro;
ORG_data = ORG.trial;
fsORG = ORG.fsample;

% Preprocessed
load('C:\DATA\DP_Tremor_ThalamoMuscular\subj1r_preproc_macro.mat')
EMG = data_macro;
EMG_data = EMG.trial;
fsEMG = EMG.fsample;


% Raw
load('C:\DATA\DP_Tremor_ThalamoMuscular\subj1r_preproc_micro.mat')
BUA = data_micro;
BUA_data = BUA.trial;
fsBUA = BUA.fsample;





for trX = 1:numel(ORG_data)
    for trY = 1:numel(BUA_data)
        
        ORGs = ORG_data{trX};
        EMGs = EMG_data{trY}';
        BUAs = BUA_data{trY}';
        
        BUAs = resample(BUAs',fsEMG,fsBUA)';
        
        
    end
end

%% Data is the SAME length?
% Micro doesnt seem to match up though?