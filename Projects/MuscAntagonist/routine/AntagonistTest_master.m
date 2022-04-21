clear; close all;
% restoredefaultpath

addpath('C:\Users\Tim West\Documents\GitHub\ABCNeuralModellingToolbox')
% addpath('C:\Users\timot\Documents\GitHub\ABCNeuralModellingToolbox')

% MASTER SCRIPT FOR PERIPHERAL ABC
%   %   %   %   %   %   %   %   %
% Get Paths
R = ABCAddPaths('C:\Users\Tim West\Documents\GitHub\PeripheralStim_ABC','MuscAntagonist');
% R = ABCAddPaths('C:\Users\timot\Documents\GitHub\PeripheralStim_ABC','firstRun');
R = antagonistTestABCAddPaths(R);

%% First we parameterise models using a example data set including Thalamic LFP,
% EMG, EEG, and Accelorometer from an Essential Tremor Patient
R.out.tag = 'antagonistTest_1'; % This tags the files for this particular instance
R = ABCsetup_AntagonistTest(R); % Sets up parameters for model, data fitting etc

fresh =0;
R = formatShengHongData4ABC(R,fresh); % Loads in raw data, preprocess and format for ABC
R.modelspec = 'antagTest_MSET';
modID = 1;
modelspec = eval(['@MS_' R.modelspec '_M' num2str(modID)]);
[R p m uc] = modelspec(R); % M! intrinsics shrunk"
R.out.dag = sprintf([R.out.tag '_M%.0f'],modID); % 'All Cross'

%% Run ABC Optimization
SimAn_ABC_201120(R,p,m);


