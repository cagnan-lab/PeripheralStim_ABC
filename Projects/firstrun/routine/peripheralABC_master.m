clear; close all; closeMessageBoxes
addpath('C:\Users\Tim West\Documents\GitHub\ABC_Inference_Neural_Paper')
% MASTER SCRIPT FOR PERIPHERAL ABC
%
% %
% TO DO:
% (1) Clean up the ABC model comparison script(modelCompMaster_V2), it 
% looks a bit nasty right now.
R = ABCAddPaths('C:\Users\Tim West\Documents\GitHub\PeripheralStim_ABC','firstRun');


%% First we parameterise models using a example data set including Thalamic LFP,
% EMG, EEG, and Accelorometer from an Essential Tremor Patient
R.out.tag = 'periphModel_MSET1_v1'; % This tags the files

R = ABCsetup_periphStim_shenghong(R); % Sets up parameters for model, data fitting etc
fresh = 0;
R = formatShengHongData4ABC(R,fresh); % Loads in raw data, preprocess and format for ABC
ABC_periphModel_ModComp_fitting(R) % Does the individual model fits
fresh = 1;
ABC_periphModel_ModComp_comparison(R,fresh) % Compares the models' performances(Exceedence probability)

analysis_ShengHongInactivation(R)
%% Now we use a larger (but more incomplete) data set from David Pedrosa

R.out.tag = 'dptest_sub';
R = ABCsetup_periphStim_pedrosa(R);
ABC_periphModel_DPdata_fitting(R)


