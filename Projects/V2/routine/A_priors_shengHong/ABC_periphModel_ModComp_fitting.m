function ABC_periphModel_ModComp_fitting(R,fresh)
if nargin<2
    fresh = 0;
end

closeMessageBoxes
spreadSession(R,fresh)

%% This is the main loop
for modID = R.modcomp.modlist
    switch R.modelspec
        case 'periphStim_MSET1'
            if modID >=7
                R.obs.Cnoise =[1 1 1 1 1]*1e-8;
                R.obs.LF = [1 1 1 1 1]*10; % Fit visually and for normalised data
                R.nmsim_name = {'SpinCrd','THAL','Musc1','MMC','Cereb'}; %modules (fx) to use.
                R.chsim_name = {'amn','Thal','EP','ctx','Cereb'}; % simulated channel names (names must match between these two!)
                R.siminds = 1:5;
            else
                R.obs.Cnoise = R.obs.Cnoise(1:4);
                R.obs.LF = R.obs.LF(1:4); % Fit visually and for normalised data
                R.nmsim_name = {'SpinCrd','THAL','Musc1','MMC'}; %modules (fx) to use.
                R.chsim_name = {'amn','Thal','EP','ctx'}; % simulated channel names (names must match between these two!)
                R.siminds = 1:4;
            end
        case 'periphStim_BMOD_MSET2'
            R.obs.Cnoise = R.obs.Cnoise(1:4);
            R.obs.LF = R.obs.LF(1:4); % Fit visually and for normalised data
            R.nmsim_name = {'SpinCrd','THAL','Musc1','MMC'}; %modules (fx) to use.
            R.chsim_name = {'amn','Thal','EP','ctx'}; % simulated channel names (names must match between these two!)
            R.siminds = 1:4;
    end
    if  spreadSession(R,modID)
        %% Prepare Model
        modelspec = eval(['@MS_' R.modelspec '_M' num2str(modID)]);
        [R p m uc] = modelspec(R); % M! intrinsics shrunk"
        pause(0.5)
        R.out.dag = sprintf([R.out.tag '_M%.0f'],modID); % 'All Cross'
        
        %% Run ABC Optimization
        R = setSimTime(R,32);
        R.obs.SimOrd = 10.5;
        SimAn_ABC_201120(R,p,m);
        spreadSession(R,0);
    end
end
