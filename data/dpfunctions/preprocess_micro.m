%function preprocess_micro(subj, wdir) %#ok<INUSL>
clear 
subj = 'subj10';
wdir = 'C:\DATA\DP_Tremor_ThalamoMuscularBUA\wrk_data\';
addpath('C:\Users\Tim West\Documents\MATLAB ADDONS\FilterM')
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
save_directory = [wdir 'processed\'];
Hs2             = spectrum.welch('Hamming',25000); %#ok<DWELCH>
sr_new          = 500;                                                      % resampling frequency
filter          = 'low';

% plotting settings
flag_check      = 0;
fig_directory   = [wdir 'oxtrem\results\filtered_data\'];            % folder at which figures will be stored if needed
font            = 'Cambria';
fontsize        = [14, 19, 24];

if~exist(save_directory, 'dir')                                            % this command creates the directory - if not existent - where times
    mkdir(save_directory)                                                   % of stimuli are saved [see lines 72f.]
end
cd(file_directory);

for np = [9 10 12]; %[1 3 4 6 8 9 10 12]
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
        %% Remove artifacts from data according to artifacts_preprocessed.mat
        %         load([wdir 'oxtrem\artifacts_preprocessed.mat']);            % this loads the file with the (manually) detected artifacts to cut
        %         [data_micro.trial, data_micro.time] = ...                           % them and make data artefact free
        %             cut_artifacts(data_micro.trial, data_micro.time, ...
        %             data_micro.trialinfo, artifacts{VLp,np}, data_micro.fsample); %#ok<USENS>
        
        %% High-pass filter, full-wave rectification, band-pass filter
        % general settings for the three microelectrode filter
        sr_micro    = data_micro_preproc.fsample;                                   % Sampling frequency of LFP/EMG data
        f_hpf       = 300;                                                  % high-pass frequency
        f_lpf       = 150;
        f_band1     = 1; f_band2 = 250;                                     % low-pass frequency
        fo          = 51/(sr_micro/2);                                      % frequency of the notch filter, (51 Hertz as this attenuates the line noise best (see figure))
        q           = 30;
        filterOrder = 3;
        
        [bnotch,anotch] = iirnotch(fo,fo/q,2);                              % Notch filter
        % [bnotch,anotch] = iircomb(round(sr/fo),bw,'notch');               % Notch filter with harmonics
        data_micro_temp = arrayfun(@(q) FiltFiltM(bnotch,anotch, ...
            data_micro_preproc.trial{q}.'), ...
            1:length(data_micro_preproc.trial), 'UniformOutput',false);
        
        [bnotch2,anotch2] = iirnotch(2*fo,2*fo/q,2);                        % Notch filter at first harmonic (100Hz);
        data_micro_temp = arrayfun(@(q) FiltFiltM(bnotch2,anotch2, ...
            data_micro_temp{q}), 1:numel(data_micro_temp), ...
            'UniformOutput',false);
        figure(100)
%         plot(data_micro_preproc.time{1},data_micro_temp{1}(:,1)); hold on
%         [bhigh,ahigh]  = butter(filterOrder,2*f_hpf/sr_micro,'high');       % High pass filter at defined frequency
%         data_micro_temp = arrayfun(@(q) FiltFiltM(bhigh,ahigh, ...
%             data_micro_temp{q}),1:numel(data_micro_temp),...
%             'UniformOutput',false);
        
%         data_micro_temp = arrayfun(@(q) abs(data_micro_temp{q}), ...        % full-wave rectification
%             1:numel(data_micro_temp),  'UniformOutput',false);
%         plot(data_micro_preproc.time{1},data_micro_temp{1}(:,1)); hold on
        
        data_micro_temp = arrayfun(@(q) makemua_hayriye3_tw(data_micro_temp{q},0.001,0.003,data_micro.fsample,data_micro.fsample,4), ...        % HC's BUA
            1:numel(data_micro_temp),  'UniformOutput',false);
        plot(data_micro_preproc.time{1},data_micro_temp{1}(:,1)); hold on
        
        
%         [mua] = makemua_hayriye3(muatemp,0.001,0.003,muasr,4);
        
%         switch filter
%             case 'band'
%                 [bband,aband]  = butter(2,[f_band1 f_band2]/sr_micro);      % Band-pass filter at defined frequency
%                 data_micro_temp = arrayfun(@(q) FiltFiltM(bband,aband, ...
%                     data_micro_temp{q}), 1:numel(data_micro_temp),...
%                     'UniformOutput',false);
%                 bfilt = bband; afilt = aband;
%             case 'low'
%                 [blow,alow]  = butter(4,2*f_lpf/sr_micro);                  % Low pass filter at defined frequency
%                 data_micro_temp = arrayfun(@(q) FiltFiltM(blow,alow, ...
%                     data_micro_temp{q}), 1:numel(data_micro_temp),...
%                     'UniformOutput',false);
%                 bfilt = blow; afilt = alow;
%                 plot(data_micro_preproc.time{1},data_micro_temp{1}(:,1)); hold on
%                 
%             case 'lowhigh'
%                 [blow,alow]  = butter(filterOrder,2*f_lpf/sr_micro, 'low'); % first low pass filter at defined frequency
%                 data_micro_temp = arrayfun(@(q) FiltFiltM(blow,alow, ...
%                     data_micro_temp{q}), 1:numel(data_micro_temp),...
%                     'UniformOutput',false);
%                 bfilt1 = blow; afilt1 = alow;
%                 
%                 [bhigh2,ahigh2]  = ...
%                     butter(filterOrder,2*f_band1/sr_micro, 'high');         % then high pass filter
%                 data_micro_temp = arrayfun(@(q) FiltFiltM(bhigh2,ahigh2, ...
%                     data_micro_temp{q}), 1:numel(data_micro_temp),...
%                     'UniformOutput',false);
%                 bfilt2 = bhigh2; afilt2 = ahigh2;
%         end
        
        %% Plotting if required
        if flag_check == 1
            figure;
            subplot(4,4,[1 2 5 6]); % plotting raw signal and filtered microelectrode signal
            spec_raw = arrayfun(@(q) psd(Hs2,data_micro_preproc.trials{q}.', 'Fs', ...% the next few lines define the frequency representation of the raw data
                sr_micro), 1:numel(data_micro_preproc.trials),'UniformOutput',false);
            mean_spec_raw = arrayfun(@(x) spec_raw{x}.Data, ...
                1:numel(spec_raw),'un',0);
            semilogy(spec_raw{1}.Frequencies, ...
                nanmean(horzcat(mean_spec_raw{:}),2)); hold on;
            
            spec_filt = ...
                arrayfun(@(q) psd(Hs2, data_micro_temp{q}, 'Fs', sr_micro), ...    % % the next few lines define the frequency representation of the notch-filtered data
                1:length(data_micro_temp),'UniformOutput',false);
            mean_spec_filt = arrayfun(@(x) spec_filt{x}.Data, ...
                1:numel(spec_filt),'un',0);
            semilogy(spec_filt{1}.Frequencies, ...
                nanmean(horzcat(mean_spec_filt{:}),2));
            
            % plot specifications
            ylabel({'log-scaled power [in a.u.]'}, 'FontName', font, ...
                'FontSize', fontsize(1), 'FontWeight','b');
            xlabel('Frequency [in Hz.]', 'FontName', font, 'FontSize', ...
                fontsize(1), 'fontweight','b');
            xlim([0 450]); ylim('auto');
            set(gca,'FontName', font, 'FontSize', fontsize(1));
            set(gca,'XMinorTick','off','YMinorTick','off');
            set(gca,'XGrid','on','YGrid','on');
            set(gca,'GridLineStyle',':', 'LineWidth', 0.2);
            legend({'Raw signal';'Filtered signal'});
            
            if ~strcmp(filter, 'lowhigh')
                subplot(4,4,[3 4 7 8]); % plotting raw signal and filtered microelectrode signal
                [h1, w1] = freqz(bhigh, ahigh); [h2, w2] = freqz(bfilt, afilt);
                [ax, ~, ~] = ...
                    plotyy(w1/pi*sr_micro/2, abs(h1), w2/pi*sr_micro/2, abs(h2));
                hold on;
                
                % plot specifications
                set(get(ax(2),'Ylabel'),'String', {'Response of the filters'}, ...
                    'FontName', font, 'FontSize', fontsize(1), ...
                    'fontweight','b', 'Color', 'k');
                xlabel('Frequency [in Hz]',  'FontName', font, ...
                    'FontSize', fontsize(1), 'FontWeight','b');
                box('off');
                
                for i = 1:2
                    ylim(ax(i), [0 1.5]);
                    xlim(ax(i), [0 500])
                    set(ax(i),'YTick',[0 .5 1 1.5]);
                    set(ax(i),'FontName',font, 'FontSize',fontsize(1));
                    set(ax(i),'XMinorTick','off','YMinorTick','off');
                    set(ax(i),'XGrid','on','YGrid','on');
                    set(ax(i),'GridLineStyle',':', 'LineWidth', 0.2);
                end
            end
            
            switch filter
                case 'band'
                    legend({strcat(num2str(f_hpf), 'Hz high-pass filter'); ...
                        strcat(num2str(f_band1), '-', ...
                        num2str(f_band2), 'Hz bandpass filter')});
                    
                    %extra plots
                    subplot(4,4,11); % plottig raw signal and notch filtered signal around 50Hz
                    plot(spec_raw{1}.Frequencies, ...
                        nanmean(horzcat(mean_spec_raw{:}),2)); hold on
                    plot(spec_filt{1}.Frequencies, ...
                        nanmean(horzcat(mean_spec_filt{:}),2));
                    xlim([35 65]); ylim('auto');
                    set(gca,'FontName', font, 'FontSize', fontsize(1)-3);
                    set(gca,'XMinorTick','off','YMinorTick','off');
                    set(gca,'XGrid','on','YGrid','on');
                    set(gca,'GridLineStyle',':', 'LineWidth', 0.2);
                    
                case 'low'
                    legend({strcat(num2str(f_hpf), 'Hz high-pass filter'); ...
                        strcat(num2str(f_lpf), 'Hz low-pass filter')});
                case 'lowhigh'
                    subplot(4,4,[3 4 7 8]); % plotting raw signal and filtered microelectrode signal
                    [h1, w1] = freqz(bhigh, ahigh); [h2, w2] = freqz(bfilt1, afilt1);
                    [ax, ~, ~] = ...
                        plotyy(w1/pi*sr_micro/2, abs(h1), w2/pi*sr_micro/2, abs(h2));
                    hold(ax(2)); hold(ax(1));
                    [h3, w3] = freqz(bfilt2, afilt2);
                    plot(ax(2),w3/pi*sr_micro/2, abs(h3));
                    
                    % plot specifications
                    set(get(ax(2),'Ylabel'),'String', {'Response of the filters'}, ...
                        'FontName', font, 'FontSize', fontsize(1), ...
                        'fontweight','b', 'Color', 'k');
                    xlabel('Frequency [in Hz]',  'FontName', font, ...
                        'FontSize', fontsize(1), 'FontWeight','b');
                    box('off');
                    
                    for i = 1:2
                        ylim(ax(i), [0 1.5]);
                        xlim(ax(i), [0 500])
                        set(ax(i),'YTick',[0 .5 1 1.5]);
                        set(ax(i),'FontName',font, 'FontSize',fontsize(1));
                        set(ax(i),'XMinorTick','off','YMinorTick','off');
                        set(ax(i),'XGrid','on','YGrid','on');
                        set(ax(i),'GridLineStyle',':', 'LineWidth', 0.2);
                    end
            end
            
            legend({strcat(num2str(f_hpf), 'Hz high-pass filter'); ...
                strcat(num2str(f_lpf), 'Hz low-pass-filter'); ...
                strcat(num2str(f_band1), 'Hz high-pass filter')});
            
            subplot(4,4,[9 10 13 14]);
            semilogy(spec_raw{1}.Frequencies, ...
                nanmean(horzcat(mean_spec_raw{:}),2)); hold on;
            semilogy(spec_filt{1}.Frequencies, ...
                nanmean(horzcat(mean_spec_filt{:}),2));
            
            xlim([0 45]);
            ylim('auto');
            set(gca,'FontName',font,'FontSize',fontsize(1)-3);
            set(gca,'XMinorTick','off','YMinorTick','off');
            set(gca,'XGrid','on','YGrid','on');
            set(gca,'GridLineStyle',':', 'LineWidth', 0.2);
            legend({'Raw signal'; 'filtered signal'});
            hold off;
            
            %             supertitle('Summary of the microelectrode pre-processing', ...
            %                 'FontName', font, 'FontSize',fontsize(3),'Color','k');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 30 20])
            fig_name = strcat(fig_directory, 'subj', num2str(np), ...
                micro(end-10), '_micro.tif');
            %             print('-dtiff', fig_name, '-r300');
            %             savefig(gcf,strcat(fig_name(1:end-3), 'fig'));
            %             close(gcf);
        end
        
        %% Finish preprocessing by downsampling data and arranging it according to rest of the data
        
        %         %% Cut artifacts out of data according to artifacts file
        %         load([wdir 'oxtrem\artifacts_preprocessed.mat']);
        %         art = nan(numel(data_micro.trial),2);
        %         b = [   1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10,...
        %             11, 11, 12, 12, 13, 13, 14, 14, 15, 15, 16, 16, 17, 17, 18, 18, 19, 19, 20, 20  ];
        %
        %         for a = 1:numel(data_micro.trial);                                  % loops through all the trials available
        %             if data_micro.trialinfo(a) == 11 || ...
        %                     data_micro.trialinfo(a) == 21;                          % this checks whether it is a rest or a postural tremor condition
        %                 condition = 1; % rest
        %             else
        %                 condition = 2; % postural tremor
        %             end
        %
        %             try
        %                 art(a,1) = dsearchn(data_micro.time{1,a}', ...              % searches for the timepoint closest to
        %                     artifacts{VLp,np}{1,condition}{1,b(a)}(1)');%#ok<USENS> % the detected artifact start/stop
        %                 art(a,2) = dsearchn(data_micro.time{1,a}', ...
        %                     artifacts{VLp,np}{1,condition}{1,b(a)}(2)');
        %             catch
        %                 continue
        %             end
        %
        %             if isfinite(art(a,1));
        %                 data_micro_temp{1, a} = ...
        %                     data_micro_temp{1, a}(art(a,1):art(a,2),:);               % removes data with artifacts
        %             end
        %         end
        
        %         sr = data_micro.fsample;                % old sampling rate
        
        % change dimension so that time is row- and trials are column vectors
        %         if size(data_micro_temp{1,1},2) > size(data_micro_temp{1,1},1)
        %             data_micro_preproc.trial = arrayfun(@(q) downsample_jsb(data_micro_temp{q}.', ...
        %                 sr_micro, sr_new), 1:numel(data_micro_temp),...
        %                 'UniformOutput',false);
        %
        %         else
        %             data_micro_preproc.trial = arrayfun(@(q) downsample(data_micro_temp{q}, ...
        %                 sr_micro, sr_new), 1:numel(data_micro_temp),...
        %                 'UniformOutput',false);
        %         end
        
        for q = 1:numel(data_micro_preproc.trial)
            data_micro_preproc.trial{q} = resample(data_micro_preproc.trial{q}',sr_new,sr_micro);
        end
        
        
        
        data_micro = data_micro_preproc;
        
        data_micro.time = arrayfun(@(q) ...                                 % this cerates a new time vector according to data length
            ([0:1:length(data_micro_temp{1,q})-1]/data_micro.fsample).', ...
            1:numel(data_micro_temp), 'UniformOutput', false); %#ok<NBRAK>
        
%         if size(data_micro.time{1,1},2) > size(data_micro.time{1,1},1)
%             data_micro.time = arrayfun(@(q) downsample_jsb(data_micro.time{q}.', ...
%                 sr_micro, sr_new).', 1:numel(data_micro.time),...
%                 'UniformOutput',false);
%         else
%             data_micro.time = arrayfun(@(q) downsample(data_micro.time{q}, ...
%                 sr_micro, sr_new).', 1:numel(data_micro.time),...
%                 'UniformOutput',false);
%         end

%         for q = 1:numel(data_micro.time)
%             data_micro.time{q} = resample(data_micro.time{q}',sr_new,sr_micro);
%         end

        data_micro.fsample = sr_new;
        clear data_micro_temp mean* spec* ahigh alow ...
            anotch aband ax bhigh blow bnotch bband h1 h2 ind*
        
        eval(['save(''' output_micro, ''', ''data_micro''', ', ''-v7.3'')']);
    end
end