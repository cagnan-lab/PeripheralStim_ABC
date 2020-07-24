%function preprocess_micro(subj, wdir) %#ok<INUSL>
clear 
wdir = 'D:\Data\DP_Tremor_ThalamoMuscular\';
outdir = 'D:\Data\DP_Tremor_ThalamoMuscular\';
addpath('C:\Users\timot\Documents\Work\MATLAB ADDONS\FilterM')
%   This function preprocesses all microelectrode recordings.
%   Steps:
%   1.) Notch filter of microelectrode recordings;
%   2.) Microelectrode data is high-pass filtered at 300 Hz, full-wave
%   rectified and bandpass filtered between 2-250 Hz.
%
%   Copyright (C) June 2016, modified February 2017
%
%   D. Pedrosa, University Hospital of Cologne and Nuffield Department of
%   Clinical Neurosciences of the University of Oxford
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

% General settings
file_directory = [wdir];
save_directory = [outdir];
sr_new          = 2500;                                                      % resampling frequency

if~exist(save_directory, 'dir')                                            % this command creates the directory - if not existent - where times
    mkdir(save_directory)                                                   % of stimuli are saved [see lines 72f.]
end
cd(file_directory);

for np = [ 9 10 12 13 14] %1 3 4 6 8
    %% Text to be displayed and the filenames are defined
    text = 'the subject actually being computed is subj %d\n';
    fprintf(text, np);                                                      % displays the nuimber of the patient being processed and adds one number to iter_pat
    micro1 = strcat(file_directory, 'subj', num2str(np), 'l_micro.mat');    % defines the filename for LFP recordings
    micro2 = strcat(file_directory, 'subj', num2str(np), 'r_micro.mat');    % defines the filename for LFP recordings
    
    if exist(micro1, 'file') && exist(micro2, 'file')                       % defines the number of recordings bilateral (2) or unilateral (1)
        numrec = 2;
    else
        numrec = 1;
    end
    
    for VLp = 1:numrec
        try load(micro1);
            micro = micro1; micro1 = micro2;                                % the filename is changed so that in cases wher VLp = 1 it does not matter
        catch                                                               % and where VLp = 2, the filename automatically is the one
            load(micro2);
            micro = micro2; micro2 = micro1;                                % of the file not yet loaded/preprocessed
        end
        
        %% Creates a set of indices important for the processing later
        output_micro = ...                                                  % defines the name used for storing the preprocessed data
            strcat(save_directory, 'subj', num2str(np), ...                 % of microelectrode recordings
            micro(end-10), '_preproc_micro.mat');
        data_micro_preproc = data_micro;                                    % creates a new structure in which all data is saved
        
        ind_micro = arrayfun(@(i) strcmp({'central', 'anterior', ...        % the next three lines are intended to identify the
            'medial', 'posterior', 'lateral'},...                           % vlp and the emg channels in the microelectrode data
            data_micro.label{i}), 1:numel(data_micro.label),...             % so that only the VLp data is concatenated
            'UniformOutput',false);
        ind_micro = find(cellfun(@sum, ind_micro)==1);                      % index of microelectrode  channels
        
        data_micro_preproc.trial = cellfun( @(x) x(ind_micro,:), ...
            data_micro_preproc.trial, 'UniformOutput', false ); %#ok<FNDSB> % selects only microelectrode data
        
        ind_goodrecording = find(data_micro_preproc.condition~= 99 & ~data_micro_preproc.wrong);                      % index of microelectrode  channels
        data_micro_preproc.trial = data_micro_preproc.trial(ind_goodrecording);
        data_micro_preproc.time = data_micro_preproc.time(ind_goodrecording);
        data_micro_preproc.height = data_micro_preproc.height(ind_goodrecording);
        data_micro_preproc.wrong = data_micro_preproc.wrong(ind_goodrecording);
        data_micro_preproc.condition = data_micro_preproc.condition(ind_goodrecording);

        
        % Apply Notch
        sr_micro    = data_micro_preproc.fsample;                                   % Sampling frequency of LFP/EMG data
        fo          = 51/(sr_micro/2);                                      % frequency of the notch filter, (51 Hertz as this attenuates the line noise best (see figure))
        q           = 30;
        
        [bnotch,anotch] = iirnotch(fo,fo/q,2);                              % Notch filter
        % [bnotch,anotch] = iircomb(round(sr/fo),bw,'notch');               % Notch filter with harmonics
        data_micro_temp = arrayfun(@(q) FiltFiltM(bnotch,anotch, ...
            data_micro_preproc.trial{q}.'), ...
            1:length(data_micro_preproc.trial), 'UniformOutput',false);
        
        [bnotch2,anotch2] = iirnotch(2*fo,2*fo/q,2);                        % Notch filter at first harmonic (100Hz);
        data_micro_temp = arrayfun(@(q) FiltFiltM(bnotch2,anotch2, ...
            data_micro_temp{q}), 1:numel(data_micro_temp), ...
            'UniformOutput',false);
        
% % % TW ARTEFACT REJECTION        
% % %         Make temp trial
% %        for qt = 1:numel(data_micro_preproc.trial);
% %         sintrial = [];
% %         sintrial.trial{1} = data_micro_preproc.trial{qt};
% %         sintrial.time{1} = data_micro_preproc.time{qt};
% %         sintrial.label = data_micro_preproc.label;
% %         sintrial.fsample = data_micro_preproc.fsample;
% %         
% % %         % Temp Lowpass for artefact detection
% % %         f_lpf = 20;
% % %         filterOrder = 3;
% % %         [bhigh,ahigh]  = butter(filterOrder,2*f_lpf/sr_micro,'low');       % Low pass filter at defined frequency
% % %         sintrial.trial = arrayfun(@(q) FiltFiltM(bhigh,ahigh, ...
% % %             sintrial.trial{q}')',1:numel(sintrial.trial),...
% % %             'UniformOutput',false);        
% %         % Demean
% %         sintrial.trial = arrayfun(@(q)sintrial.trial{q}-mean(sintrial.trial{q},2),1:numel(sintrial.trial),...
% %             'UniformOutput',false);        
% %         
% %         cfg= [];
% %         cfg.length = 1;
% %         sintrial= ft_redefinetrial(cfg,sintrial);
% %         
% %         badstore = [];
% %         for i = 1:numel(sintrial.label)
% %             bad = cellfun(@(x) any(x(i,:)>6*std(x(i,:))),sintrial.trial, 'UniformOutput', false);
% %             badind =find([bad{:}]);
% %             
% %             for b = badind
% %                 sintrial.trial{b}(i,:) = nan(size(sintrial.trial{b}(i,:)));
% %             end
% %         end
% %          X = [sintrial.trial{:}];
% %         % size diff
% %         sd = size(data_micro_preproc.trial{qt},2)-size(X,2);
% %         X = [X nan(size(X,1),sd)];
% %         data_micro_preproc.trial{qt} = X; % With rejected samples and filled to length
% %         
% %        end
        
        
%         % Apply HC's BUA function
        data_micro_temp = arrayfun(@(q) makemua_hayriye3_tw(data_micro_temp{q},0.0005,0.0005,data_micro.fsample,data_micro.fsample,4), ...        % HC's BUA
            1:numel(data_micro_temp),  'UniformOutput',false);
        
        % Apply TW's BUA function
%         data_micro_temp = arrayfun(@(q) makemua_dpmeth(data_micro_temp{q},data_micro.fsample), ...        % HC's BUA
%             1:numel(data_micro_temp),  'UniformOutput',false);
        
        
        data_micro_preproc.trial = data_micro_temp;
        % Resample to target
         data_micro_preproc.trial = arrayfun(@(q) resample(data_micro_preproc.trial{q},sr_new,sr_micro),1:numel(data_micro_temp),  'UniformOutput',false);
                
        data_micro_preproc.fsample = sr_new;
        % Reassign to output structue
        data_micro = data_micro_preproc;
        
        data_micro.time = arrayfun(@(q) ...                                 % this cerates a new time vector according to data length
            linspace(0,length(data_micro.trial{1,q})/data_micro.fsample,length(data_micro.trial{1,q})), ...
            1:numel(data_micro.trial), 'UniformOutput', false); %#ok<NBRAK>
        
        % ensure format is ch x N
        if size(data_micro.trial{1},1)>size(data_micro.trial{1},2)
         data_micro.trial = arrayfun(@(q) data_micro.trial{q}.',1:numel(data_micro.trial),  'UniformOutput',false); %transpose
        end
        
        if size(data_micro.time{1},1)>size(data_micro.time{1},2)
         data_micro.time = arrayfun(@(q) data_micro.time{q}',1:numel(data_micro.trial),  'UniformOutput',false); %transpose
        end
        

        clear data_micro_temp mean* spec* ahigh alow ...
            anotch aband ax bhigh blow bnotch bband h1 h2 ind*
        
       save(output_micro, 'data_micro','-v7.3')
    end
end


%%        
