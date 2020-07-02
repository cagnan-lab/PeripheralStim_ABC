function preprocess_lfpemg(wdir)

%   This function preprocesses all LFP/EMGdata.
%   Steps:
%   1.) Notch filter of LFP and EMG data;
%   2.) LFP data is high-pass filtered at .5 Hz and low-pass filtered at 450 Hz.
%   3.) EMG-channels are notch-filtered, high-pass-filtered at 35 Hz,
%   full-wave rectified and band pass filtereed between 1-25Hz
%   4.) LFP and EMG data are resampled at 500Hz sampling rate.
%
%   Copyright (C) October 2015 and June 2016, modified November 2016 and
%   February 2017
%
%   D. Pedrosa, University Hospital of Cologne and Nuffield Department of
%   Clinical Neurosciences of the University of Oxford
%
%   This software may be used, copied, or redistributed as long as it is
%   not sold and this copyright notice is reproduced on each copy made.
%   This routine is provided as is without any express or implied
%   warranties whatsoever.

% General settings
file_directory  = [wdir 'oxtrem\wrk_data_reduced\'];                        % folder from whcih information is taken
save_directory  = [wdir 'oxtrem\preproc_data_reduced_2-5k\'];               % folder at which data will be written at
Hs1             = spectrum.welch('Hamming',2500); %#ok<DWELCH>
nsr             = 2500;
% plotting settings
flag_check      = 1;
fig_directory   = [wdir 'oxtrem\results\filtered_data\'];                   % folder at which figures will be stored if needed
font            = 'Cambria';
fontsize        = [14, 19, 24];

if~exist(save_directory, 'dir')                                             % this command creates the directory - if not existent - where times
    mkdir(save_directory)                                                   % of stimuli are saved [see lines 72f.]
end
cd(file_directory);

for np = [1,3:4, 6, 8:10, 12:14] %[1, 3:4, 6, 8:10, 12:14];
    %% Text to be displayed and the filenames are defined
    text = 'the subject actually being computed is subj %d\n';
    fprintf(text, np);                                                      % displays the nuimber of the patient being processed and adds one number to iter_pat
    filename1 = strcat(file_directory, 'subj', num2str(np), 'l_macro.mat'); % defines the filename for LFP recordings
    filename2 = strcat(file_directory, 'subj', num2str(np), 'r_macro.mat'); % defines the filename for LFP recordings
    
    if exist(filename1, 'file') && exist(filename2, 'file')                 % defines the number of recordings bilateral (2) or unilateral (1)
        numrec = 2;
    else
        numrec = 1;
    end
    
    for VLp = 1:numrec
        try load(filename1);
            filename = filename1; filename1 = filename2;                    % the filename is changed so that in cases wher VLp = 1 it does not matter
        catch                                                               % and where VLp = 2, the filename automatically is the one
            load(filename2);
            filename = filename2; filename2 = filename1;                    % of the file not yet loaded/preprocessed
        end
        
        output_filename = ...                                               % defines the name used for storing the preprocessed data
            strcat(save_directory, 'subj', num2str(np), ...
            filename(end-10), '_preproc_macro.mat');
        data_macro_preproc = data_macro;                                    % creates a new structure in which all data is saved
        
        ind_vlp = arrayfun(@(i) strcmp({'central', 'anterior', ...          % the next three lines are intended to identify the
            'medial', 'posterior', 'lateral'},...                           % vlp and the emg channels in the LFP data
            data_macro.label{i}), 1:length(data_macro.label),...            % so that only the VLp data is concatenated
            'UniformOutput',false);
        ind_emg = find(cellfun(@sum, ind_vlp)==0);                          % index of EMG channels
        ind_vlp = find(cellfun(@sum, ind_vlp)==1);                          % index of LFP channels

        %% Remove artifacts from data according to artifacts_preprocessed.mat
        load([wdir 'oxtrem\artifacts_preprocessed.mat']);            % this loads the file with the (manually) detected artifacts to cut
        [data_macro.trial, data_macro.time] = ...                           % them and make data artefact free
            cut_artifacts(data_macro.trial, data_macro.time, ...
            data_macro.trialinfo, artifacts{VLp,np}, ...
            data_macro.fsample); %#ok<USENS>
                
        data_vlp = cellfun( @(x) x(ind_vlp,:), ...
            data_macro.trial, 'UniformOutput', false ); %#ok<FNDSB> % selects only LFP data
        data_emg = cellfun( @(x) x(ind_emg,:), ...
            data_macro.trial, 'UniformOutput', false ); %#ok<FNDSB> % selects only EMG data
        
        %% Start with filter of LFP data
        % general settings for the three LFP filter
        sr          = data_macro.fsample;                                   % Sampling frequency of LFP/EMG data
        f_hpf       = .5;                                                   % high-pass frequency
        f_lpf       = 450;                                                  % low-pass frequency
        fo          = 51/(sr/2);                                            % frequency of the notch filter, (51 Hertz as this attenuates the line noise best (see figure))
        q           = 30;
        filterOrder = 3;
        
        [bnotch,anotch] = iirnotch(fo,fo/q,2);                              % Notch filter
        % [bnotch,anotch] = iircomb(round(sr/fo),bw,'notch');               % Notch filter with harmonics
        data_filt_temp = arrayfun(@(q) FiltFiltM(bnotch,anotch, ...
            data_vlp{q}.'), 1:length(data_vlp),'UniformOutput',false);
        
        [bnotch2,anotch2] = iirnotch(2*fo,2*fo/q,2);                        % Notch filter at first harmonic (100Hz);
        data_filt_temp = arrayfun(@(q) FiltFiltM(bnotch2,anotch2, ...
            data_filt_temp{q}), 1:length(data_filt_temp), ...
            'UniformOutput',false);
        
        if flag_check == 1
            figure;
            subplot(4,4,[1 2 5 6]); % plotting raw signal and notch filtered signal
            spec_raw = arrayfun(@(q) psd(Hs1, data_vlp{q}.', 'Fs', sr), ... % the next few lines define the frequency representation of the raw data
                1:length(data_vlp),'UniformOutput',false);
            mean_spec_raw = arrayfun(@(x) spec_raw{x}.Data, ...
                1:numel(spec_raw),'un',0);
            semilogy(spec_raw{1}.Frequencies, ...
                nanmean(horzcat(mean_spec_raw{:}),2)); hold on;
            
            spec_notch = ...
                arrayfun(@(q) psd(Hs1, data_filt_temp{q}, 'Fs', sr), ...    % % the next few lines define the frequency representation of the notch-filtered data
                1:length(data_filt_temp),'UniformOutput',false);
            mean_spec_notch = arrayfun(@(x) spec_notch{x}.Data, ...
                1:numel(spec_notch),'un',0);
            semilogy(spec_notch{1}.Frequencies, ...
                nanmean(horzcat(mean_spec_notch{:}),2));
            
            % plot specifications
            ylabel({'log-scaled power [in a.u.]'}, 'FontName', font, ...
                'FontSize', fontsize(1), 'FontWeight','b');
            xlabel('Frequency [in Hz.]', 'FontName', font, 'FontSize', ...
                fontsize(1), 'fontweight','b');
            xlim([0 155]); ylim('auto');
            set(gca,'FontName', font, 'FontSize', fontsize(1));
            set(gca,'XMinorTick','off','YMinorTick','off');
            set(gca,'XGrid','on','YGrid','on');
            set(gca,'GridLineStyle',':', 'LineWidth', 0.2);
            legend({'Raw signal';'Notch filtered signal'}) % this is a cell array!
            
            %extra plots
            subplot(4,4,11); % plottig raw signal and notch filtered signal around 50Hz
            plot(spec_raw{1}.Frequencies, ...
                nanmean(horzcat(mean_spec_raw{:}),2)); hold on
            plot(spec_notch{1}.Frequencies, ...
                nanmean(horzcat(mean_spec_notch{:}),2));
            xlim([35 65]); ylim('auto');
            set(gca,'FontName', font, 'FontSize', fontsize(1)-3);
            set(gca,'XMinorTick','off','YMinorTick','off');
            set(gca,'XGrid','on','YGrid','on');
            set(gca,'GridLineStyle',':', 'LineWidth', 0.2);
        end
        
        [bhigh,ahigh]  = butter(filterOrder,2*f_hpf/sr,'high');             % High pass filter at defined frequency
        data_filt_temp = arrayfun(@(q) FiltFiltM(bhigh,ahigh, ...
            data_filt_temp{q}),1:numel(data_filt_temp),...
            'UniformOutput',false);
        [blow,alow]     = butter(filterOrder,2*f_lpf/sr,'low');             % Low pass filter at defined frequency
        data_filt_temp = arrayfun(@(q) FiltFiltM(blow,alow, ...
            data_filt_temp{q}), 1:numel(data_filt_temp),...
            'UniformOutput',false);
        
        if flag_check == 1
            subplot(4,4,[3 4 7 8]); % frequency response of high- and low-pass filter
            [h1, w1] = freqz(bhigh, ahigh); [h2, w2] = freqz(blow, alow);
            [ax, ~, ~] = ...
                plotyy(w1/pi*sr/2, abs(h1), w2/pi*sr/2, abs(h2)); hold on;
            
            % plot specifications
            set(get(ax(2),'Ylabel'),'String', {'Response of the filters'}, ...
                'FontName', font, 'FontSize', fontsize(1), ...
                'fontweight','b', 'Color', 'k');
            set(ax(1),'YTick',[.5 1 1.5]); set(ax(2),'YTick',[.5 1 1.5]);
            xlabel('Frequency [in Hz]',  'FontName', font, ...
                'FontSize', fontsize(1), 'FontWeight','b');
            box('off');
            
            for i = 1:2
                ylim(ax(i), [.5 1.5]);
                xlim(ax(i), [0 500])
                set(ax(i),'FontName',font, 'FontSize',fontsize(1));
                set(ax(i),'XMinorTick','off','YMinorTick','off');
                set(ax(i),'XGrid','on','YGrid','on');
                set(ax(i),'GridLineStyle',':', 'LineWidth', 0.2);
            end
            legend({strcat(num2str(f_hpf), 'Hz high-pass filter');...
                strcat(num2str(f_lpf), 'Hz low-pass filter')}) % this is a cell array!
            
            subplot(4,4,[9 10 13 14]); % frequency representations of filtered signal and raw signal
            semilogy(spec_raw{1}.Frequencies, ...
                nanmean(horzcat(mean_spec_raw{:}),2)); hold on;
            spec_filt = arrayfun(@(q) psd(Hs1, data_filt_temp{q}, 'Fs', sr), ...
                1:length(data_filt_temp),'UniformOutput',false);
            mean_spec_filt = arrayfun(@(x) spec_filt{x}.Data, ...
                1:numel(spec_filt),'un',0);
            semilogy(spec_filt{1}.Frequencies, ...
                nanmean(horzcat(mean_spec_filt{:}),2));
            
            % plot specifications
            ylabel({'log-scaled power [in a.u.]'}, ...
                'FontName', font, 'fontsize',fontsize(1), 'fontweight','b');
            xlabel('Frequency [in Hz.]', 'FontName', font, ...
                'FontSize', fontsize(1), 'FontWeight','b');
            xlim([0 800]); ylim('auto');
            set(gca,'FontName',font,'FontSize',fontsize(1));
            set(gca,'XMinorTick','off','YMinorTick','off');
            set(gca,'XGrid','on','YGrid','on');
            set(gca,'GridLineStyle',':', 'LineWidth', 0.2);
            legend({'Raw signal';'Filtered signal'}) % this is a cell array!
            hold off;
            
            % extra plots
            subplot(4,4,12) % enlarged frequency response
            [ax, ~, ~] = plotyy(w1/pi*sr/2, abs(h1), w2/pi*sr/2, abs(h2));
            box('off'); hold on
            
            for i = 1:2
                set(ax(i),'YTick',[.5 1 1.5]);
                ylim(ax(i), [.0 1.5]); xlim(ax(i), [0 6]);
                set(ax(i),'FontName',font, 'FontSize',fontsize(1)-3);
                set(ax(i),'XMinorTick','off','YMinorTick','off');
                set(ax(i),'XGrid','on','YGrid','on');
                set(ax(i),'GridLineStyle',':', 'LineWidth', 0.2);
            end
            
            subplot(4,4,15);
            semilogy(spec_raw{1}.Frequencies, ...
                nanmean(horzcat(mean_spec_notch{:}),2)); hold on;
            semilogy(spec_filt{1}.Frequencies, ...
                nanmean(horzcat(mean_spec_filt{:}),2));
            
            xlim([0 45]);
            ylim('auto');
            set(gca,'FontName',font,'FontSize',fontsize(1)-3);
            set(gca,'XMinorTick','off','YMinorTick','off');
            set(gca,'XGrid','on','YGrid','on');
            set(gca,'GridLineStyle',':', 'LineWidth', 0.2);
            hold off;
            supertitle('Summary of the preprocessing of LFP-signals', ...
                'FontName', font, 'FontSize',fontsize(3),'Color','k');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 30 20])
            fig_name = strcat(fig_directory, 'subj', num2str(np), ...
                filename(end-10), '_LFP.tif');
            print('-dtiff', fig_name, '-r300');
%             savefig(gcf,strcat(fig_name(1:end-3), 'fig'));
            close(gcf);
        end
        
        %% Filter EMG data
        % general settings for the EMG filter
        f_hpf       = 35;
        bpf1        = 1;
        bpf2        = 25;
        filterOrder= 3;
        
        [bnotch,anotch] = iirnotch(fo,fo/q,2);                              % Notch filter
        % [bnotch,anotch] = iircomb(round(sr/fo),bw,'notch');               % Notch filter with harmonics
        data_filt_emg_temp = arrayfun(@(q) FiltFiltM(bnotch,anotch, ...
            data_emg{q}.'), 1:length(data_emg),'UniformOutput',false);
        
        [bnotch2,anotch2] = iirnotch(2*fo,2*fo/q,2);                        % Notch filter at first harmonic
        data_filt_emg_temp = arrayfun(@(q) FiltFiltM(bnotch2,anotch2, ...
            data_filt_emg_temp{q}), 1:numel(data_filt_emg_temp), ...
            'UniformOutput',false);
       
        [bhigh,ahigh]   = butter(filterOrder,2*f_hpf/sr,'high');            % High pass filter at defined frequency
        data_filt_emg_temp = arrayfun(@(q) FiltFiltM(bhigh,ahigh, ...
            data_filt_emg_temp{q}),1:numel(data_filt_emg_temp),...
            'UniformOutput',false);
        
        data_filt_emg_temp = arrayfun(@(q) abs(data_filt_emg_temp{q}), ...
            1:numel(data_filt_emg_temp),...
            'UniformOutput',false);
        
        [bband, aband]     = butter(2,[bpf1 bpf2]/(sr/2));                  % Low pass filter at defined frequency
        data_filt_emg_temp = arrayfun(@(q) FiltFiltM(bband,aband, ...
            data_filt_emg_temp{q}), 1:numel(data_filt_emg_temp),...
            'UniformOutput',false);
        
        %% Plot data when needed (e.g. for illustration purposes)
        if flag_check == 1
            figure;
            subplot(2,2,1);
            spec_raw = ...
                arrayfun(@(q) psd(Hs1, data_emg{q}.', 'Fs', sr), ...
                1:length(data_emg),'UniformOutput',false);
            mean_spec_raw = ...
                arrayfun(@(x) spec_raw{x}.Data, 1:numel(spec_raw),'un',0);
            semilogy(spec_raw{1}.Frequencies, ...
                nanmean(horzcat(mean_spec_raw{:}),2));
            hold on;
            
            spec_filt = ...
                arrayfun(@(q) psd(Hs1, data_filt_emg_temp{q}, 'Fs', sr), ...
                1:length(data_filt_emg_temp),'UniformOutput',false);
            mean_spec_filt = ...
                arrayfun(@(x) spec_filt{x}.Data, 1:numel(spec_filt),'un',0);
            mean_spec_filt = horzcat(mean_spec_filt{:});
            semilogy(spec_raw{1}.Frequencies, nanmean(mean_spec_filt,2));
            ylabel({'Average power of the'; 'EMG-signal [in a.u.] log-scaled'}, ...
                'FontName', font, 'FontSize', fontsize(1), ...
                'fontweight','b');
            xlabel('Frequency [in Hz.]', ...
                'FontName', font, 'FontSize', fontsize(1), ...
                'fontweight','b');
            xlim([0 50]);
            ylim('auto');
            set(gca,'FontName',font,'FontSize',fontsize(1));
            set(gca,'XMinorTick','off','YMinorTick','off');
            set(gca,'XGrid','on','YGrid','on');
            set(gca,'GridLineStyle',':', 'LineWidth', 0.2);
            legend({'Raw signal';'Preprocessed EMG'}) % this is a cell array!
            
            subplot(2,2,2);
            [h1, w1] = freqz(bhigh, ahigh);
            [h2, w2] = freqz(bband, aband);
            [ax, ~, ~] = ...
                plotyy(w1/pi*sr/2, abs(h1), w2/pi*sr/2, abs(h2));
            set(get(ax(1),'Ylabel'), 'String', ...
                {'Response of the high-pass filter'}, ...
                'FontName', font, 'FontSize', fontsize(1), ...
                'fontweight','b');
            set(get(ax(2),'Ylabel'), 'String', ...
                {'Response of the bandpass filter'}, ...
                'FontName', font, 'FontSize', fontsize(1), ...
                'fontweight','b');
            
            set(ax(1),'YTick',[.5 1 1.5]);
            set(ax(2),'YTick',[.5 1 1.5]);
            xlabel('Frequency [in Hz]', ...
                'FontName', font, 'FontSize', fontsize(1), ...
                'fontweight','b');
            ylim(ax(1), [0 1.5]); ylim(ax(2), [0 1.5]);
            xlim(ax(1), [0 200]); xlim(ax(2), [0 200]);
            
            set(gca,'FontName',font,'FontSize',fontsize(1));
            set(gca,'XMinorTick','off','YMinorTick','off');
            set(gca,'XGrid','on','YGrid','on');
            set(gca,'GridLineStyle',':', 'LineWidth', 0.2);
            legend({strcat(num2str(f_hpf), 'Hz high-pass filter'); ...
                strcat(num2str(bpf1), '-', ...
                num2str(bpf2), 'Hz bandpass filter')}) % this is a cell array!
            box('off');
            
            subplot(2,2,4);
            [ax, ~, ~] = ...
                plotyy(w1/pi*sr/2, abs(h1), w2/pi*sr/2, abs(h2));
            
            set(ax(1),'YTick',[.5 1 1.5]);
            set(ax(2),'YTick',[.5 1 1.5]);
            for i = 1:2
                ylim(ax(i), [0 1.5]);
                xlim(ax(i), [0 45]);
            end
            
            set(gca,'XMinorTick','off','YMinorTick','off');
            set(gca,'XGrid','on','YGrid','on');
            set(gca,'GridLineStyle',':', 'LineWidth', 0.2);
            box('off');
            
            supertitle('Summary of the EMG preprocessing', ...
                'FontName', font, 'FontSize',fontsize(3),'Color','k');
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 30 20])
            fig_name = strcat(fig_directory, 'subj', num2str(np), ...
                filename(end-10), '_EMG.tif');
            print('-dtiff', fig_name, '-r300');
%             savefig(gcf,strcat(fig_name(1:end-3), 'fig'));
            close(gcf);
        end
        
        data_complete = arrayfun(@(q) [data_filt_temp{q}, ...               % the next few lines merge the LFP and the
            data_filt_emg_temp{q}], 1:numel(data_filt_emg_temp),...         % EMG data to get (again) one file with all channels in it
            'UniformOutput',false);
        sr = data_macro.fsample; sr_new = nsr;                              % old/new sampling rate
        
        if size(data_complete{1,1},2) > size(data_complete{1,1},1)
            data_macro_preproc.trial = arrayfun(@(q) downsample_jsb(data_complete{q}.', ...
                sr, sr_new), 1:numel(data_complete),...
                'UniformOutput',false);
        else
            data_macro_preproc.trial = arrayfun(@(q) downsample_jsb(data_complete{q}, ...
                sr, sr_new), 1:numel(data_complete),...
                'UniformOutput',false);
        end
        clear *high *low *notch bpf* f_* filterOrder* fo;
        data_macro = data_macro_preproc;
        data_macro.time = arrayfun(@(q) ...
            ([0:1:length(data_complete{1,q})-1]/data_macro.fsample).', ...
            1:numel(data_complete), 'UniformOutput', false); %#ok<NBRAK>
        
        if size(data_macro.time{1,1},2) > size(data_macro.time{1,1},1)     % this makes sure that LFP/micro data is saved
            data_macro.time = arrayfun(@(q) downsample_jsb(data_macro.time{q}.', ...% as columns while time data is saved as row vector
                sr, sr_new).', 1:numel(data_macro.time),...
                'UniformOutput',false);
        else
            data_macro.time = arrayfun(@(q) downsample_jsb(data_macro.time{q}, ...
                sr, sr_new).', 1:numel(data_macro.time),...
                'UniformOutput',false);
        end
        
        data_macro.fsample = nsr;
        clear data_filt* data_emg data_vlp mean* spec* ahigh alow ...
            anotch aband ax bhigh blow bnotch bband h1 h2 ind* sr_new
        
        eval(['save(''' output_filename, ''', ''data_macro''', ', ''-v7.3'')']);
    end
end