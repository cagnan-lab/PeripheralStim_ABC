function dataOut = getDP_thalamomuscular_data(R,subsel,thalsrc)
% datapath = 'D:\Data\DP_Tremor_ThalamoMuscular\'; %R.path.datapath_pedrosa;
%% QUESTIONS FOR DP
% (1) Are the micro trials_nospike derived from trials? doesnt look like
% MUA
% (2) Why is macrodata one sample less than micro in length?
% (3) How were EMG and MUA synced? Same amplifier?
% thalsrc = 'BUA';
% thalsrc = 'LFP';
switch thalsrc
    case 'BUA'
        load([R.path.datapath_pedrosa subsel '_preproc_macro.mat']);
        load([R.path.datapath_pedrosa subsel '_preproc_micro.mat']);
    case 'LFP'
        load([R.path.datapath_pedrosa subsel '_preproc_macro.mat']);
end
microlist = {'central' 'anterior' 'medial' 'posterior' 'lateral'};

%     micro_ind = find(strncmp(data_macro.label,'lateral',4));
switch thalsrc
    case 'LFP'
        thaldat = data_macro;
        thaldat.label = intersect(thaldat.label,microlist);
    case 'BUA'
        thaldat = data_micro;
        thaldat.trial = data_micro.trial;
        for i = 1:numel( thaldat.trial);
            thaldat.trial{i} =  thaldat.trial{i}';
        end
end


emgnames = {'EDC','FDL','FDI'};
treminf = [12 22];
restinf = [11 21];

EMGind = find(strncmp(data_macro.label,'EDC',3) | strncmp(data_macro.label,'FDL',3) | strncmp(data_macro.label,'FDI',3));

% Get sample rate
fsamp = data_macro.fsample;

% Concat EMG data
datacat = vertcat(data_macro.trial{:});
trempow = [];
for i = EMGind
    X = datacat(:,i);
    X = (X-mean(X,1))./std(X,[],1);
    [fz hz] = pwelch(X,fsamp,[],fsamp,fsamp);
    trempow(i) = max(fz((hz>=2 & hz <=12)));
end

% Use EMG with maximum tremor amplitude
[dum emgsel] = max(trempow)

for cond = 1:2
    if cond == 1
        condcode = treminf; % posture
    elseif cond == 2
        condcode = restinf;
    end
    % Now search the depths by computing coherence
    heightlist = find(abs(data_macro.height)<=2); % find heights that are less than 2mm from target
    heightlist = heightlist((data_macro.trialinfo(heightlist)==condcode(1)) | (data_macro.trialinfo(heightlist)==condcode(2))); % then select only the tremor data
    
    if cond == 1
        heightlist = find(abs(data_macro.height)<=2); % find heights that are less than 2mm from target
        heightlist = heightlist((data_macro.trialinfo(heightlist)==treminf(1)) | (data_macro.trialinfo(heightlist)==treminf(2))); % then select only the tremor data
        
        tremcoh = []; Xs = []; Ys = []; cz = []; chz = [];
        for i = 1:numel(heightlist)
            X = data_macro.trial{heightlist(i)}(:,emgsel);
            %             X = (X-mean(X,1))./std(X,[],1); % standardize
            %         X = abs(X); % rectify
            [fz hz] = pwelch(X,fsamp,[],fsamp,fsamp);
            Xs{i} = [data_macro.time{heightlist(i)}; X'];
            Xfs{i} = [hz';fz'];
            for j = 1:numel(thaldat.label)
                Y = thaldat.trial{heightlist(i)}(:,j);
                
                %                 Y = makemua_hayriye3(Y,1/1000,3/1000,fsamp,fsamp,4);
                %                 Y = (Y-mean(Y,1))./std(Y,[],1); % standardize
                [fz hz] = pwelch(Y,fsamp,[],fsamp,fsamp);
                Yfs{i,j} = [hz';fz'];
                Ys{i,j} = [thaldat.time{heightlist(i)}; Y'];
                % Ensure samples match (HACK for now)
                ds = min([size(X,1) size(Y,1)]);
                [cz(:,i,j) chz(:,i,j)] = mscohere(X(1:ds),Y(1:ds),fsamp,[],fsamp,fsamp);
                tremcoh(i,j) = max(cz((hz>=2 & hz <=15),i,j));
            end
        end
        
        [dum ind] =max(tremcoh(:));
        [isel jsel] = ind2sub(size(tremcoh),ind);
        postheight = data_macro.height(heightlist(isel));
    elseif cond == 2 %rest
        heightlist = find(data_macro.height==postheight); % find heights that are less than 2mm from target
        heightlist = heightlist((data_macro.trialinfo(heightlist)==restinf(1)) | (data_macro.trialinfo(heightlist)==restinf(2))); % then select only the tremor data
        isel = 1;
        
        tremcoh = []; Xs = []; Ys = []; cz = []; chz = [];
        X = data_macro.trial{heightlist(isel)}(:,emgsel);
        %         X = (X-mean(X,1))./std(X,[],1); % standardize
        %         X = abs(X); % rectify
        [fz hz] = pwelch(X,fsamp,[],fsamp,fsamp);
        Xs{isel} = [data_macro.time{heightlist(isel)}; X'];
        Xfs{isel} = [hz';fz'];
        Y = thaldat.trial{heightlist(isel)}(:,j);
        %         Y = makemua_hayriye3(Y,1/1000,3/1000,fsamp,fsamp,4);
        %         Y = (Y-mean(Y,1))./std(Y,[],1); % standardize
        [fz hz] = pwelch(Y,fsamp,[],fsamp,fsamp);
        Yfs{isel,jsel} = [hz';fz'];
        Ys{isel,jsel} = [thaldat.time{heightlist(isel)}; Y'];
        % Ensure samples match (HACK for now)
        ds = min([size(X,1) size(Y,1)]);
        [cz(:,isel,jsel) chz(:,isel,jsel)] = mscohere(X(1:ds),Y(1:ds),fsamp,[],fsamp,fsamp);
    end
    
    
    ds = min([size(data_macro.trial{heightlist(isel)},1) size(thaldat.trial{heightlist(isel)},1)]);
    
    data = [];
    X = [data_macro.trial{heightlist(isel)}(1:ds,emgsel) thaldat.trial{heightlist(isel)}(1:ds,jsel)];
    X = (X-mean(X,1))./std(X,[],1);
    data.trial = {X'};
    data.label = {'EMG','Thal'};
    data.fsample = data_macro.fsample;
    data.time{1} = data_macro.time{heightlist(isel)}(1:ds);
    data = ft_preprocessing([],data);
    
    cfg = [];
    cfg.length  = 2;
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
    
    %     % Visual Artefact Rejection
    %     cfg = [];
    %     data = ft_rejectvisual(cfg,data);
    %
    %
    %     for tr = 1:numel(data.trial)
    %         data.trial{tr} = data.trial{tr}.*hanning(size(data.trial{tr},2))';
    %     end
    cfg = [];
    cfg.channel = 'EMG';
    datarep = ft_selectdata(cfg,data);
    
    cfg = [];
    cfg.lpfilter = 'yes';
    cfg.lpfreq = 10;
    datarep = ft_preprocessing(cfg,datarep);
    
    datarep.label{1} = 'fakeACC';
    
    data = ft_appenddata([],data,datarep);
    
    dataOut(cond) = data;
    codes{cond} = {data_macro.label{emgsel} data_macro.label{jsel} data_macro.height(heightlist(isel)) data_macro.trialinfo(heightlist)}
    
end
