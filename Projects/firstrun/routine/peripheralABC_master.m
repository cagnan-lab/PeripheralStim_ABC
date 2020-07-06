clear; close all; 
addpath('C:\Users\timot\Documents\GitHub\ABC_Inference_Neural_Paper')
% MASTER SCRIPT FOR PERIPHERAL ABC
%
% %
% TO DO:
% (1) Clean up the ABC model comparison script(modelCompMaster_V2), it 
% looks a bit nasty right now.
% (2) Change output folder to be within the project folder!
%   %   %   %   %   %   %   %   %
% Get Paths
R = ABCAddPaths('C:\Users\timot\Documents\GitHub\PeripheralStim_ABC','firstRun');
% Note on file structure:
% File structure [system repo project tag dag]; all outputs follow this
% structure. Use tag to name a particular setup/analysis pipeline. dag is
% often used when running through models/data within a tagged project.

%% First we parameterise models using a example data set including Thalamic LFP,
% EMG, EEG, and Accelorometer from an Essential Tremor Patient
R.out.tag = 'periphModel_MSET1_v1'; % This tags the files for this particular instance

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
ABC_periphModel_DPdata_fitting(R) % This will fit just the big full model
R.out.tag = 'dpmod_test';
ABC_periphModel_DPdata_fitting_Bvar(R) % This will fit variations of the full model with individual modulations

