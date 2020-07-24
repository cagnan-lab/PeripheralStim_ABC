
%function dpfx_select_data(subj, wdir) %#ok<INUSL>
% subj = 'subj10';
exdir = 'D:\Data\DP_Tremor_ThalamoMuscular\'; %Output Directory for selected data
wdir = 'D:\OneDrive\OneDrive - Nexus365\DP_BUA_thalamomuscular\wrk_data\'; %Input Directory for Raw Data
%   This function selects data so that only sites without wrong recordings/
%   wo/ stimulation are selected. Besides the coding is enhanced in order to
%   produce the same structure for all subjects. Finally,there is the opportunity
%   to obtain results for the number of subjects, the number of recordings,
%   etc.
%
%   Copyright (C) June 2016
%
%   D. Pedrosa, Nuffield Department of Clinical Neurosciences of the
%   University of Oxford
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

flag_report = 1;                                                            % defines if report should be generated (1) or not (0)
file_directory = [wdir];
save_directory = [exdir];

if~exist(save_directory, 'dir')                                             % this command creates the directory - if not existent - where times
    mkdir(save_directory)                                                   % of stimuli are saved [see lines 72f.]
end

iter_pat = 0;
for np = [1 3 4 6 8 9 10 12 13 14]
    %% Text to be displayed and the filenames are defined
    text = 'the subject actually being computed is subj %d\n';
    fprintf(text, np); iter_pat = iter_pat + 1;                             % displays the nuimber of the patient being processed and adds one number to iter_pat
    filename1 = ...
        strcat(file_directory, 'subj', num2str(np), '_macro.mat');          % defines the filename for LFP recordings
    filename2 = ...
        strcat(file_directory, 'subj', num2str(np), '_micro.mat');          % defines the filename for microelectrode recordings
    
    %% Loads LFP and microelectrode data and throws error if unpresent
    try
        %         load(filename1);
        load(filename2);
    catch
        text = 'problems loading data for subj %d';
        sprintf(text, np);                                                  % provides error message when data could not be loaded
        continue;
    end
    
    %%  Saves original data into workspace and allocates structures
    data_micro_complete = data_micro;     % in order to retain the original data, a copy is made at this point
    data_micro.trial = {}; data_micro.trialinfo = [];
    data_micro.time = {}; data_micro.label = {};
    
    %% The next few lines identify the number of sides recorded for later
    right = arrayfun(@(i) strfind('rightVLp',...
        data_micro_complete.trialinfo.side{i}), ...
        1:length(data_micro_complete.trialinfo.side),'UniformOutput',false);
    right(cellfun('isempty',right)) = {0}; right = cell2mat(right);
    
    left = arrayfun(@(i) strfind('leftVLp', ...
        data_micro_complete.trialinfo.side{i}), ...
        1:length(data_micro_complete.trialinfo.side),'UniformOutput',false);
    left(cellfun('isempty',left)) = {0}; left = cell2mat(left);
    
    if sum(right)>0 && sum(left)>0; flag_sides=2; else flag_sides = 1; end %#ok<SEPEX>
    
    %% from here on, data is extracted
    switch flag_sides
        case(1) % only one side was recorded
            data_micro.label = data_micro_complete.hdr.label{1,1};          % and microelectrode recordings
            side_VLp = data_micro_complete.trialinfo.side{find(left|right,1,'first')}{1,1}(1);       % retrieves the information of which side is being recorded
            
            %% for-loop which runs through the distinct heights for the first condition
            nwrong_trials = find(~data_micro_complete.trialinfo.wrong);
            qt = 0;
            for q = nwrong_trials
                qt = qt + 1;
                data_micro.trial{1,qt} = ...
                    data_micro_complete.trial{q};
                data_micro.time{1,qt} = ...
                    data_micro_complete.time{q};
                data_micro.hdr.filename_raw{qt} = ...
                    data_micro_complete.trialinfo.filename_raw{q};
                data_micro.height{qt} = ...
                    data_micro_complete.trialinfo.height{q};
                data_micro.wrong(qt) = data_micro_complete.trialinfo.wrong(q);
                
                if strcmp(data_micro_complete.trialinfo.side{q}, 'leftVLp') && ...
                        strcmp(data_micro_complete.trialinfo.condition{q}, 'r')
                    data_micro.condition(qt) = 11;
                elseif strcmp(data_micro_complete.trialinfo.side{1,q}, 'leftVLp') && ...
                        strcmp(data_micro_complete.trialinfo.condition{q}, 'h')
                    data_micro.condition(qt) = 12;
                elseif strcmp(data_micro_complete.trialinfo.side{1,q}, 'rightVLp') && ...
                        strcmp(data_micro_complete.trialinfo.condition{q}, 'r')
                    data_micro.condition(qt) = 21;
                elseif strcmp(data_micro_complete.trialinfo.side{1,q}, 'rightVLp') && ...
                        strcmp(data_micro_complete.trialinfo.condition{q}, 'h')
                    data_micro.condition(qt) = 22;
                else
                    data_micro.condition(qt) = 99;
                end
                
                %                 data_micro.trialinfo = data_macro.trialinfo;
            end
            
            %% saves data to  the previously defined folder
            output_filename_micro = strcat(save_directory, 'subj', ...
                num2str(np), side_VLp, '_micro.mat');
            %             output_filename_macro = strcat(save_directory, 'subj', ...
            %                 num2str(np), side_VLp, '_macro.mat');
            eval(['save(''' output_filename_micro, ''', ''data_micro''', ...
                ', ''-v7.3'')'])
            %             eval(['save(''' output_filename_macro, ''', ''data_macro''',...
            %                 ', ''-v7.3'')'])
            
        case (2) % bilateral recordings are available
            
            warning('DOING BILATERAL- SCRIPT NOT SETUP!')
            for VLp = 1:2
                switch VLp
                    case(1)
                        nwrong_trials = find(~data_micro_complete.trialinfo.wrong & left);
                    case(2)
                        nwrong_trials = find(~data_micro_complete.trialinfo.wrong & right);
                end
                
                data_micro.label = data_micro_complete.hdr.label{1,VLp};          % and microelectrode recordings
                side_VLp = data_micro_complete.trialinfo.side{nwrong_trials(1)}{1,1}(1);       % retrieves the information of which side is being recorded

                qt = 0;
                for q = nwrong_trials
                    qt = qt + 1;
                    data_micro.trial{1,qt} = ...
                        data_micro_complete.trial{q};
                    data_micro.time{1,qt} = ...
                        data_micro_complete.time{q};
                    data_micro.hdr.filename_raw{qt} = ...
                        data_micro_complete.trialinfo.filename_raw{q};
                    data_micro.height{qt} = ...
                        data_micro_complete.trialinfo.height{q};
                    data_micro.wrong(qt) = data_micro_complete.trialinfo.wrong(q);
                    
                    if strcmp(data_micro_complete.trialinfo.side{q}, 'leftVLp') && ...
                            strcmp(data_micro_complete.trialinfo.condition{q}, 'r')
                        data_micro.condition(qt) = 11;
                    elseif strcmp(data_micro_complete.trialinfo.side{1,q}, 'leftVLp') && ...
                            strcmp(data_micro_complete.trialinfo.condition{q}, 'h')
                        data_micro.condition(qt) = 12;
                    elseif strcmp(data_micro_complete.trialinfo.side{1,q}, 'rightVLp') && ...
                            strcmp(data_micro_complete.trialinfo.condition{q}, 'r')
                        data_micro.condition(qt) = 21;
                    elseif strcmp(data_micro_complete.trialinfo.side{1,q}, 'rightVLp') && ...
                            strcmp(data_micro_complete.trialinfo.condition{q}, 'h')
                        data_micro.condition(qt) = 22;
                    else
                        data_micro.condition(qt) = 99;
                    end
                    
                    %                 data_micro.trialinfo = data_macro.trialinfo;
                end
                
                %% saves data to  the previously defined folder
                output_filename_micro = strcat(save_directory, 'subj', ...
                    num2str(np), side_VLp, '_micro.mat');
                eval(['save(''' output_filename_micro, ''', ''data_micro''', ...
                    ', ''-v7.3'')'])
%                 end
            end
    end
    
    
end
