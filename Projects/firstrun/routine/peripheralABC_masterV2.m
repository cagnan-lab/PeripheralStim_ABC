clear; close all;


addpath('D:\GITHUB\ABCNeuralModellingToolbox')
% addpath('C:\Users\timot\Documents\GitHub\ABCNeuralModellingToolbox')
% addpath('C:\Users\ndcn0903\Documents\GitHub\ABCNeuralModellingToolbox')


% MASTER SCRIPT FOR PERIPHERAL ABC
%   %   %   %   %   %   %   %   %
% Get Paths
R = ABCAddPaths('D:\GITHUB\PeripheralStim_ABC','V2');
% R = ABCAddPaths('C:\Users\timot\Documents\GitHub\PeripheralStim_ABC','firstRun');
% R = ABCAddPaths('C:\Users\ndcn0903\Documents\GitHub\PeripheralStim_ABC','V2');


R = periphABCAddPaths(R);
% Note on file structure:
% File structure [system repo project tag dag]; all outputs follow this
% structure. Use tag to name a particular setup/analysis pipeline. dag is
% often used when running through models/data within a tagged project.

stepcontrol = 4
%%%%%%%%%%%%%%%%%%%%%%%%% SHENGHONG DATA
%% STEP 1: This creates a prior for the cerebellum in which the cerebellu
if ismember(1,stepcontrol)
    R.out.tag = 'periphModel_SH_cereb_only'; % This tags the files for this particular instance
    R = ABCsetup_periphStim_shenghong(R); % Sets up parameters for model, data fitting etc
    R.obs.Cnoise = R.obs.Cnoise(1);
    R.obs.LF = R.obs.LF(1); % Fit visually and for normalised data
    R.nmsim_name = {'Cereb'}; %modules (fx) to use.
    R.chsim_name = {'Cereb'}; % simulated channel names (names must match between these two!)
    R.chdat_name = {'Cereb'};
    R.siminds = 1;
    R.SimAn.convIt.dEps = 1e-3;
    R.frqz = [2:.2:24];
    R = formatShengHongData4ABC(R,0); % Loads in raw data, preprocess and format for ABC
    R.modcomp.modlist = 1;
    R.modelspec = 'periphStim_cereb';
    ABC_periphModel_ModComp_fitting(R,[]) % Does the individual model fits
end

%% STEP 2: Perform Model Comparison for whole system for just tremor condition
if ismember(2,stepcontrol)
    R.out.tag = 'periphModel_MSET1_v1'; % This tags the files for this particular instance
    R = ABCsetup_periphStim_shenghong(R); % Sets up parameters for model, data fitting etc
    
    % First do single condition
    fresh = 0;
    R = formatShengHongData4ABC(R,fresh); % Loads in raw data, preprocess and format for ABC
    R.modelspec = 'LMSV1';
    R.SimAn.convIt.dEps = 5e-3;
    R.SimAn.pOptList = {'.int{src}.T','.int{src}.G','.C','.A','.obs.Cnoise','.DExt'}; %,'.B','.DExt',,'.int{src}.S'

    R.modcomp.modlist = 1:8;
    ABC_periphModel_ModComp_fitting(R,[0 1]) % Does the individual model fits % LOAD 8
    fresh = 0;
    ABC_periphModel_ModComp_comparison(R,1,0,1) % Compares the models' performances(Exceedence probability)
end

%% STEP 3: Now model both conditions at once using prior from step 3
if ismember(3,stepcontrol)
    %% Now look at modulation condition
    R.out.tag = 'periphModel_BMOD_TremPrior'; % This tags the files for this particular instance
    R = ABCsetup_periphStim_shenghong(R); % Sets up parameters for model, data fitting etc
    R.SimAn.convIt.dEps = 1e-3;
    R.SimAn.rep = 128; % This determines the number of iterations per ABC sequence
    
    R.modelspec = 'LMSV1';
    R.SimAn.convIt.dEps = 5e-3;
    R.SimAn.pOptList = {'.C','.A','.B','.BC'}; %,'.obs.Cnoise','.DExt''.int{src}.T','.int{src}.G',,'.DExt',,'.int{src}.S'
    R.condnames = {'Tremor','Rest'};
    R.modelSpecOpt.fresh = 0; % this sets up the modelSpec to call the previous model
    R.Bcond = 2; % The second condition is the modulation i.e. parRest = parTremor + B;
    
    R.modcomp.modlist = 1:10;
    fresh = 0;
    R = formatShengHongData4ABC(R,fresh); % Loads in raw data, preprocess and format for ABC
    ABC_periphModel_ModComp_fitting(R,[]) % Does the individual model fits
    fresh = 1;
    ABC_periphModel_ModComp_comparison(R,fresh) % Compares the models' performances(Exceedence probability)
    
    analysis_ShengHongInactivation(R)
end

%% STEP4: Expand to larger DP cohort 
if ismember(4,stepcontrol)
    %% Now we use a larger (but more incomplete) data set from David Pedrosa
    R.out.tag = 'dpcohort_V1';
    R = ABCsetup_periphStim_pedrosa(R);
    fresh = 0;
    formatDPdata_Data4ABC(R,fresh,'LFP');
    fresh = 1;
    R.modelspec = 'LMSV1';
    R.modelSpecOpt.fresh = 0; % this sets up the modelSpec to call the previous model
    R.SimAn.pOptList = {'.int{src}.T','.int{src}.G','.C','.A','.obs.Cnoise','.DExt','.B'}; %,'.B','.DExt',,'.int{src}.S'
    ABC_periphModel_DPdata_fitting(R,fresh) % This will fit just the big full model
    
    fresh = 0;
    ABC_periphModel_DPdata_fitting_bua(R,fresh) % This will fit just the big full model
    
    % R.out.tag = 'dpmod_test';
    % ABC_periphModel_DPdata_fitting_Bvar(R) % This will fit variations of the full model with individual modulations
    
    R.out.tag = 'dpfull_sub_bua';
    R.modelspec = 'periphStim_MSET1';
    R.sublist = {'subj1r','subj3l','subj4l','subj6l','subj6r','subj8l','subj9r','subj10l','subj10r','subj12l','subj13l','subj14r'};
    R.subsel = [1 4 6 9 10 11]; % BUA
    R.subsel = 1:numel(R.sublist);
    ABC_periphModel_DPdata_inspectfits(R,0,1)
end