function R = ABCsetup_periphStim_shenghong(R)

%% PLOTTING
R.plot.feat(1).axtit = {'Frq','amplitude'};
R.plot.feat(1).axlim = [4 48 0 5];

%% DATA SPECIFICATION
R.filepathn = [R.path.rootn 'data\storage'];
R.data.datatype{1} = 'CSD'; %%'NPD'
R.frqz = [2:.2:24];
% R.frqz(R.frqz>47 & R.frqz<53) = NaN;
R.frqz(R.frqz==0) = NaN;
R.frqzfull = [1:.2:120]; % used for filters/detrending
% R.chloc_name = {'Musc1'};
R.nmsim_name = {'SpinCrd','THAL','Musc1','MMC','Cereb'}; %modules (fx) to use. These must match those listed in the fx_compile function
R.chdat_name = {'amn','Thal','EP','ctx'}; % observed channels (redundant)
% R.datinds = 1:4; % Specify this when you deal with the data - ensure its not the wrong order!
R.chsim_name = {'amn','Thal','EP','ctx','Cereb'}; % simulated channel names
R.siminds = 1:5; % Maps from simulation to data
R.condnames = {'Tremor'}; %,'Rest'};
% Spectral characteristics
R.obs.csd.df = 0.5;
R.obs.csd.reps = 32; %96;

%% INTEGRATION
% Main dynamics function
R.IntP.intFx = @spm_fx_compile_periphStim; %@spm_fx_compile_120319;
R.objfx.compFx= @compareData_180520;
R.objfx.errorFx = @fxPooledR2;
R.IntP.dt = .001;
R.IntP.Utype = 'white_covar'; % DCM_Str_Innov
R.IntP.bufferExt = ceil(0.050*(1/R.IntP.dt)); % buffer for extrinsic delays

R.IntP.getNoise = 0;
N = R.obs.csd.reps; % Number of epochs of desired frequency res
fsamp = 1/R.IntP.dt;
R.obs.SimOrd = floor(log2(fsamp/(2*R.obs.csd.df))); % order of NPD for simulated data
R.obs.SimOrd = 9;
R.IntP.tend = (N*(2^(R.obs.SimOrd)))/fsamp;
R.IntP.nt = R.IntP.tend/R.IntP.dt;
R.IntP.tvec = linspace(0,R.IntP.tend,R.IntP.nt);
R.Bcond = 0;
dfact = fsamp/(2*2^(R.obs.SimOrd));
disp(sprintf('The target simulation df is %.2f Hz',R.obs.csd.df));
disp(sprintf('The actual simulation df is %.2f Hz',dfact));

%% OBSERVATION
% observation function
R.obs.obsFx = @observe_dataTremor;
R.obs.gainmeth{1} = 'obsnoise';
R.obs.gainmeth{2} = 'boring';
R.obs.glist =0; %linspace(-5,5,12);  % gain sweep optimization range [min max listn] (log scaling)
R.obs.condchecker = 0; %1; % This is in the observation function and checks if there is a big difference between conditions- 0 is OFF
R.obs.brn =2; % 2; % burn in time
LF = [1 1 1 1 1]*10; % Fit visually and for normalised data
R.obs.LF = LF;
R.obs.Cnoise = [1e-8 1e-8 1e-8 1e-8 1e-8]; % Noise gain on the observation function

% Data Features
% fx to construct data features
R.obs.transFx = @constructGenCrossMatrix;
% These are options for transformation (NPD)
R.obs.trans.logscale = 0;
R.obs.trans.zerobase = 1;
R.obs.trans.norm = 0;
R.obs.trans.normcat = 1;
R.obs.trans.logdetrend = 0;
R.obs.trans.gauss3 = 0;
R.obs.trans.gausSm = 0; % This is off but is switched on to 1 Hz at data processing stage
R.obs.trans.interptype = 'linear';

%% OBJECTIVE FUNCTION
R.objfx.feattype = 'complex'; %%'ForRev'; %
R.objfx.specspec = 'cross'; %%'auto'; % which part of spectra to fit

%% OPTIMISATION
R.SimAn.pOptList = {'.int{src}.T','.int{src}.G','.int{src}.S','.C','.A','.DExt','.obs.Cnoise','.B'}; %this is edited!
R.SimAn.pOptBound = [-12 12];
R.SimAn.pOptRange = R.SimAn.pOptBound(1):.1:R.SimAn.pOptBound(2);
R.SimAn.searchMax = 200;
R.SimAn.convIt.dEps = 1e-3;
R.SimAn.convIt.eqN = 5;
R.analysis.modEvi.N  = 500;
    R.SimAn.scoreweight = [1 1e-5];
R.SimAn.rep = 512; %512; % Repeats per temperature
% R.SimAn.saveout = 'xobs1';
R.SimAn.jitter = 1; % Global precision
%% PLOTTING
R.plot.outFeatFx = @genplotter_200420; %%@;csdplotter_220517
R.plot.save = 'False';
R.plot.distchangeFunc = @plotDistChange_KS;
% R.plot.gif.delay = 0.3;
% R.plot.gif.start_t = 1;
% R.plot.gif.end_t = 1;
% R.plot.gif.loops = 2;
%






