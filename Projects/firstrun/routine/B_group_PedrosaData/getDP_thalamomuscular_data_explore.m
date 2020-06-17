% function getDP_thalamomuscular_data(R)
clear
sublist = {'subj1r','subj3l','subj4l','subj6l','subj6r','subj8l','subj9r','subj10l','subj10r','subj12l','subj13l','subj14r'};
datapath = 'C:\DATA\DP_Tremor_ThalamoMuscular\';
close all
%% QUESTIONS FOR DP
% (1) Are the micro trials_nospike derived from trials? doesnt look like
% MUA
% (2) Why is macrodata one sample less than micro in length?
% (3) How were EMG and MUA synced? Same amplifier?
thalsrc = 'LFP';
for sub =1:numel(sublist)
    load([datapath sublist{sub} '_micro_mua.mat']);
    load([datapath sublist{sub} '_preproc_macro.mat']);
    
    %     micro_ind = find(strncmp(data_macro.label,'lateral',4));
    switch thalsrc
        case 'LFP'
            thaldat = data_macro;
            thaldat.label = intersect(thaldat.label,data_micro.label);
        case 'BUA'
            thaldat = data_micro;
            thaldat.trial = data_micro.trial;
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
        trempow(i) = max(fz((hz>=2 & hz <=15)));
    end
    
    % Use EMG with maximum tremor amplitude
    [dum emgsel] = max(trempow)
    
    for cond = 1:2
        % Now search the depths by computing coherence
        
        if cond == 1
            heightlist = find(abs(data_macro.height)<=2); % find heights that are less than 2mm from target
            heightlist = heightlist((data_macro.trialinfo(heightlist)==treminf(1)) | (data_macro.trialinfo(heightlist)==treminf(2))); % then select only the tremor data
            
            tremcoh = []; Xs = []; Ys = []; cz = []; chz = [];
            for i = 1:numel(heightlist)
                X = data_macro.trial{heightlist(i)}(:,emgsel);
%                 X = (X-mean(X,1))./std(X,[],1); % standardize
                %         X = abs(X); % rectify
                [fz hz] = pwelch(X,fsamp,[],fsamp,fsamp);
                Xs{i} = [data_macro.time{heightlist(i)}; X'];
                Xfs{i} = [hz';fz'];
                for j = 1:numel(thaldat.label)
                    Y = thaldat.trial{heightlist(i)}(:,j);
%                     Y = makemua_hayriye3(Y,1/1000,3/1000,fsamp,fsamp,4);
%                     Y = (Y-mean(Y,1))./std(Y,[],1); % standardize
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
            % redefine list of trials using posture selected height
            heightlist = find(data_macro.height==postheight); % find heights that are less than 2mm from target
            % find overlap with rest trials
            heightlist = heightlist((data_macro.trialinfo(heightlist)==restinf(1)) | (data_macro.trialinfo(heightlist)==restinf(2))); % then select only the tremor data
            isel = 1; % only one should exist
            
            % clear the banks
            tremcoh = []; Xs = []; Ys = []; cz = []; chz = [];
            
            % Get the EMG data + spectra
            X = data_macro.trial{heightlist(isel)}(:,emgsel);
%             X = (X-mean(X,1))./std(X,[],1); % standardize
            %         X = abs(X); % rectify
            [fz hz] = pwelch(X,fsamp,[],fsamp,fsamp);
            Xs{isel} = [data_macro.time{heightlist(isel)}; X'];
            Xfs{isel} = [hz';fz'];
            
            % Get the thalamic MUA + spectra
            Y = thaldat.trial{heightlist(isel)}(:,j);
%             Y = makemua_hayriye3(Y,1/1000,3/1000,fsamp,fsamp,4);
%             Y = (Y-mean(Y,1))./std(Y,[],1); % standardize
            [fz hz] = pwelch(Y,fsamp,[],fsamp,fsamp);
            Yfs{isel,jsel} = [hz';fz'];
            Ys{isel,jsel} = [thaldat.time{heightlist(isel)}; Y'];
            % Ensure samples match (HACK for now)
            ds = min([size(X,1) size(Y,1)]);
            % Get the coherence
            [cz(:,isel,jsel) chz(:,isel,jsel)] = mscohere(X(1:ds),Y(1:ds),fsamp,[],fsamp,fsamp);
        end
        
        
        
        figure(sub)
        subplot(3,2,1)
        plot(Xs{isel}(1,:),Xs{isel}(2,:)); hold on
        xlabel('Time (s)'); ylabel(data_macro.label{emgsel}); xlim([5 7])
        title(sublist{sub})
        subplot(3,2,2)
        plot(Xfs{isel}(1,:),Xfs{isel}(2,:)); hold on
        xlabel('Hz'); ylabel('Power'); xlim([0 40]); set(gca,'YScale','log')
        subplot(3,2,3)
        plot(Ys{isel,jsel}(1,:),Ys{isel,jsel}(2,:)); hold on
        xlabel('Time (s)'); ylabel(['Thal ' num2str(data_macro.height(heightlist(isel))) ' ' data_micro.label{jsel}]); xlim([5 7])
        subplot(3,2,4)
        plot(Yfs{isel,jsel}(1,:),Yfs{isel,jsel}(2,:)); hold on
        xlabel('Hz'); ylabel('Power'); xlim([0 40]);set(gca,'YScale','log')
        subplot(3,2,6)
        plot(squeeze(chz(:,isel,jsel)),squeeze(cz(:,isel,jsel))); hold on
        xlabel('Hz'); ylabel('Coherence'); xlim([0 40]); ylim([0 0.1])
        legend({'Posture','Rest'})
        
        codes{sub,cond} = {data_macro.label{emgsel} data_micro.label{jsel} data_macro.height(heightlist(isel)) data_macro.trialinfo(heightlist)}
        
    end
    %
    %     % 1st EMG choose best tremor by power
    %     % best data between -2 and 2mm
    %     % trial_nospike
    %     % select height -2 to 2mm and select best coherence
    %     X = [data_macro.trial{height_ind}(:,ECD) data_macro.trial{height_ind}(:,FDL1) data_macro.trial{height_ind}(:,FDL2)];
    %     X = (X-mean(X,1))./std(X,[],1);
    %     for i = 1:size(X,3)
    %         pwelch(X(:,i),fsamp)
    %     end
    %
    %
    %     % EMG Indices
    %     [dum height_ind] = min(abs(data_macro.height));
    %     ds_mac = min([size(data_macro.trial{height_ind},1) size(data_macro.trial{height_ind},1)]);
    %     % Thal Indices
    %     [dum height_ind] = min(abs(data_micro.height));
    %     ds_mic = min([size(data_micro.trial{height_ind},1) size(data_micro.trial{height_ind},1)]);
    %
    %     data = [];
    %     X = [data_macro.trial{height_ind}(1:ds_mac,ECD) data_macro.trial{height_ind}(1:ds_mac,FDL1) data_macro.trial{height_ind}(1:ds_mac,FDL2)];
    %     X = (X-mean(X,1))./std(X,[],1);
    %     data.trial = {X'};
    %     data.label = {'Central','EDCl','FDLl','FDIl'};
    %     data.fsample = data_macro.fsample;
    %     data.time{1} = data_macro.time{height_ind};
    %     data = ft_preprocessing([],data);
    %
    %
    %     cfg = [];
    %     cfg.length  = 1;
    %     data = ft_redefinetrial(cfg,data);
    %
    %     %% Basic Common Filtering for all channels
    %     cfg = [];
    %     % Low Pass Filter at 1 Hz:
    %     cfg.hpfilter    = 'yes';
    %     cfg.hpfreq      = 3;
    %     % Low Pass Filter at 75 Hz:
    %     cfg.lpfilter    = 'yes';
    %     cfg.lpfreq      = 98;
    %     % Remove line noise frequencies (is this meant to do now or later?):
    %     cfg.dftfilter   = 'yes';
    %     cfg.dftfreq     = [50 100 150];
    %     cfg.demean      = 'yes';
    %     data= ft_preprocessing(cfg,data);
    %
    %     % Visual Artefact Rejection
    %     cfg = [];
    %     data = ft_rejectvisual(cfg,data);
    %     mkdir([R.path.rootn '\outputs\' R.path.projectn '\data\DP\thalamomuscular'])
    %     save([R.path.rootn '\outputs\' R.path.projectn '\data\DP\thalamomuscular\dp_thalamomuscular_' sublist{sub} '_pp.mat'],'data')
    
end



