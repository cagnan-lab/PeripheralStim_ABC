function getDP_corticomuscular_data(R)
sublist = {'subj1r','subj3l','subj4l','subj6l','subj6r','subj8l','subj9r','subj10l','subj10r','subj12l','subj13l','subj14r'};
datapath = 'C:\DATA\DP_Tremor_ThalamoMuscular\';

for sub = 1:numel(sublist)
    figure(sub)
    load([datapath sublist{sub} '_micro_mua.mat']);
    load([datapath sublist{sub} '_preproc_macro.mat']);
    
    micro_ind = find(strncmp(data_macro.label,'lateral',4));
    ECD = find(strncmp(data_macro.label,'EDC',3));
    FDL1 = find(strncmp(data_macro.label,'FDLl',3));
    FDL2 = find(strncmp(data_macro.label,'FDIl',3));
    
    % EMG Indices
    [dum height_ind] = min(abs(data_macro.height));
    ds_mac = min([size(data_macro.trial{height_ind},1) size(data_macro.trial{height_ind},1)]);
    % Thal Indices
    [dum height_ind] = min(abs(data_micro.height));
    ds_mic = min([size(data_micro.trial{height_ind},1) size(data_micro.trial{height_ind},1)]);
    
    data = [];
    X = [data_micro.trial{height_ind}(1:ds_mic,micro_ind) data_macro.trial{height_ind}(1:ds_mac,ECD) data_macro.trial{height_ind}(1:ds_mac,FDL1) data_macro.trial{height_ind}(1:ds_mac,FDL2)];
    X = (X-mean(X,1))./std(X,[],1);
    data.trial = {X'};
    data.label = {'Central','EDCl','FDLl','FDIl'};
    data.fsample = data_macro.fsample;
    data.time{1} = data_macro.time{height_ind};
    data = ft_preprocessing([],data);
    
    
    cfg = [];
    cfg.length  = 1;
    data = ft_redefinetrial(cfg,data);
    
    %% Basic Common Filtering for all channels
    cfg = [];
    % Low Pass Filter at 1 Hz:
    cfg.hpfilter    = 'yes';
    cfg.hpfreq      = 3;
    % Low Pass Filter at 75 Hz:
    cfg.lpfilter    = 'yes';
    cfg.lpfreq      = 98;
    % Remove line noise frequencies (is this meant to do now or later?):
    cfg.dftfilter   = 'yes';
    cfg.dftfreq     = [50 100 150];
    cfg.demean      = 'yes';
    data= ft_preprocessing(cfg,data);
    
    % Visual Artefact Rejection
    cfg = [];
    data = ft_rejectvisual(cfg,data);
    mkdir([R.path.rootn '\outputs\' R.path.projectn '\data\DP\thalamomuscular'])
    save([R.path.rootn '\outputs\' R.path.projectn '\data\DP\thalamomuscular\dp_thalamomuscular_' sublist{sub} '_pp.mat'],'data')

end



