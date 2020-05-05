function dataOut = shenghongTremorData(R)

SMR_data = ImportSMR([R.path.datapath '\ET_1Jun_Posture_NoStim_BiLFP.smr']);
fsample = 2048; %mean(SMR_data(1).imp.adc(1));
ftdata = FT2SMR(SMR_data,fsample);
% load([R.path.datapath '\ET_1Jun_Posture_NoStim_BiLFP.mat'])

for C = 1:2
    acc{1} = strncmp(ftdata(C).label,'Acl',3);
    acc{2} = strncmp(ftdata(C).label,'Acr',3);
    ftdata_pp = ftdata(C);
    for tr = 1:numel(ftdata(C).trial)
        XD = ft_preproc_standardize(ftdata(C).trial{tr});
        XD =  XD.*tukeywin(size(ftdata(C).trial{tr},2))';
        
        % Find PCA of tremor data
        accPCA = [];
        for lr = 1:2
            accAx = XD(acc{lr},:);
            %              [Zica, W, T, mu] = fastICA(accAx,3)
            [U,S] = svd(accAx);
            accPCA(:,lr) = mean(U(:,1:2)'*accAx);
        end
        
        ftdata_pp.trial{tr} = [XD; accPCA'];
    end
    
    ftdata_pp.label(end+1:end+2) = {'ACCL','ACCR'}
    
    
    cfg = [];
    cfg.length  = 1;
    ftdata_pp = ft_redefinetrial(cfg,ftdata_pp);
    
    cfg = [];
    ftdata_pp = ft_rejectvisual(cfg,ftdata_pp);
    
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
    ftdata_pp= ft_preprocessing(cfg,ftdata_pp);
    
    %% Rectify EMG
    emgSel = strncmp(ftdata_pp.label,'Ha',2);
    
    cfg = [];
    cfg.channel         = ftdata_pp.label(emgSel);
    % Low Pass Filter at 4 Hz:
    %     cfg.hpfilter    = 'yes';
    %     cfg.hpfreq      = 2.5;
    % Remove line noise frequencies (is this meant to do now or later?):
    cfg.rectify = 'yes';
    emgfix = ft_preprocessing(cfg,ftdata_pp);
    
    cfg = [];
    cfg.channel  = ftdata_pp.label(~emgSel);
    ftdata_pp = ft_selectdata(cfg,ftdata_pp);
    
    ftdata_pp = ft_appenddata([],ftdata_pp,emgfix);
    
    %
    %     for tr = 1:numel(ftdata_pp.trial)
    %         ftdata_pp.trial{tr} = ft_preproc_standardize(ftdata_pp.trial{tr});
    %     end
    %
    dataOut(C) = ftdata_pp;
end

% % Standarize by the concatanated data
% a = 1;
% 
% XM = mean([[dataOut(1).trial{:}] [dataOut(2).trial{:}]],2);
% XV = std([[dataOut(1).trial{:}] [dataOut(2).trial{:}]],[],2);
% 
% for C = 1:2
%     for tr = 1:numel(dataOut(C).trial)
%         XD = dataOut(C).trial{tr};
%         XD = (XD-XM)./XV;
%         dataOut(C).trial{tr} = XD;
%     end
% end

