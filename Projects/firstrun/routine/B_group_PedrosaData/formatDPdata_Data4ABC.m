function R = formatDPdata_Data4ABC(R,fresh)
for cursub = 1:numel(R.sublist)
    
    % This function converts ShengHongs data to format required for ABC
    mkdir([R.path.rootn '\outputs\' R.path.projectn '\data\DP\thalamomuscular'])
    subdatafile = [R.path.rootn '\outputs\' R.path.projectn '\data\DP\thalamomuscular\dp_thalamomuscular_' R.sublist{cursub} '_pp.mat'];
    if ~exist(subdatafile) || fresh
        dataOut = getDP_thalamomuscular_data(R,R.sublist{cursub});
        save(subdatafile,'dataOut')
    else
        load(subdatafile)
    end
    
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
    
    % Save the data only (precomputed and reloaded within fitting)
    Rdat = R.data;
    subABCdatafile = [R.path.rootn '\outputs\' R.path.projectn '\data\DP\thalamomuscular\dp_thalamomuscular_' R.sublist{cursub} '_ABC.mat'];
    save(subABCdatafile,'Rdat')
end