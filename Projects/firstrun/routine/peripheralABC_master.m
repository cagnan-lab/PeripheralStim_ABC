clear; close all;
% addpath('C:\Users\Tim West\Documents\GitHub\ABC_Inference_Neural_Paper')
% addpath('D:\GITHUB\ABC_Inference_Neural_Paper')
% addpath('C:\Users\timot\Documents\GitHub\ABC_Inference_Neural_Paper')

% MASTER SCRIPT FOR PERIPHERAL ABC
%
% %

%   %   %   %   %   %   %   %   %
% Get Paths
% R = ABCAddPaths('C:\Users\Tim West\Documents\GitHub\PeripheralStim_ABC','firstRun');
% R = ABCAddPaths('D:\GITHUB\PeripheralStim_ABC','firstRun');
R = ABCAddPaths('C:\Users\timot\Documents\GitHub\PeripheralStim_ABC','firstRun');

% Note on file structure:
% File structure [system repo project tag dag]; all outputs follow this
% structure. Use tag to name a particular setup/analysis pipeline. dag is
% often used when running through models/data within a tagged project.

%%%%%%%%%%%%%%%%%%%%%%%%% SHENGHONG DATA
%% First we parameterise models using a example data set including Thalamic LFP,
% EMG, EEG, and Accelorometer from an Essential Tremor Patient
R.out.tag = 'periphModel_MSET1_v1'; % This tags the files for this particular instance
R = ABCsetup_periphStim_shenghong(R); % Sets up parameters for model, data fitting etc

% First do single condition
fresh = 0;
R = formatShengHongData4ABC(R,fresh); % Loads in raw data, preprocess and format for ABC
R.modelspec = 'periphStim_MSET1';

fresh = 1;
 R.modcomp.modlist = 1:3;
ABC_periphModel_ModComp_fitting(R,fresh) % Does the individual model fits
fresh = 0;
ABC_periphModel_ModComp_comparison(R,fresh) % Compares the models' performances(Exceedence probability)

%% Now look at modulation condition
R.out.tag = 'periphModel_MSET1_v1'; % This tags the files for this particular instance
R.IntP.intFx = @spm_fx_compile_periphStim_delayupdate;
R.modelspec = 'periphStim_BMOD_MSET2';
R.condnames = {'Tremor','Rest'};
R.Bcond = 2; % The second condition is the modulation i.e. parRest = parTremor + B;

R.modcomp.modlist = 1;
fresh = 0;
R = formatShengHongData4ABC(R,fresh); % Loads in raw data, preprocess and format for ABC
fresh = 1;
ABC_periphModel_ModComp_fitting(R,fresh) % Does the individual model fits
fresh = 0;
ABC_periphModel_ModComp_comparison(R,fresh) % Compares the models' performances(Exceedence probability)

%% Fit the cerebellar model to tremor
R.out.tag = 'periphModel_SH_cereb_only'; % This tags the files for this particular instance
R = ABCsetup_periphStim_shenghong(R); % Sets up parameters for model, data fitting etc
R.obs.Cnoise = R.obs.Cnoise(1);
R.obs.LF = R.obs.LF(1); % Fit visually and for normalised data
R.nmsim_name = {'Cereb'}; %modules (fx) to use.
R.chsim_name = {'Cereb'}; % simulated channel names (names must match between these two!)
R.chdat_name = {'Cereb'};
R.siminds = 1;
R.SimAn.convIt.dEps = 1e-4;
R.SimAn.scoreweight = [1 1/1e8];
R.frqz = [2:.2:24];
R = formatShengHongData4ABC(R,0); % Loads in raw data, preprocess and format for ABC
R.modcomp.modlist = 1;
R.modelspec = 'periphStim_cereb';
ABC_periphModel_ModComp_fitting(R,1) % Does the individual model fits






analysis_ShengHongInactivation(R)

%%%%%%%%%%%%%%%%%%%%%% PEDROSA DATA
%% Now we use a larger (but more incomplete) data set from David Pedrosa
R.out.tag = 'dpcohort_V1';
R = ABCsetup_periphStim_pedrosa(R);
fresh = 1;
R = formatDPdata_Data4ABC(R,fresh);
fresh = 1;
ABC_periphModel_DPdata_fitting(R,fresh) % This will fit just the big full model

fresh = 0;
ABC_periphModel_DPdata_fitting_bua(R,fresh) % This will fit just the big full model

% R.out.tag = 'dpmod_test';
% ABC_periphModel_DPdata_fitting_Bvar(R) % This will fit variations of the full model with individual modulations

R.out.tag = 'dptest_sub_bua';
R.modelspec = 'periphStim_MSET1';
R.sublist = {'subj1r','subj3l','subj4l','subj6l','subj6r','subj8l','subj9r','subj10l','subj10r','subj12l','subj13l','subj14r'};
R.subsel = [1 4 6 9 10 11]; % BUA
R.subsel = 1:numel(R.sublist);
ABC_periphModel_DPdata_inspectfits(R,0,1)
