function ABC_periphModel_ModComp_fitting_bmod(R)
        closeMessageBoxes

%% Start Loop (for parallel sessions)
% WML is a remote accessible for coordinating parallel sessions
try
    load([R.path.rootn '\outputs\' R.out.tag '\WorkingModList'])
    disp('Loaded Mod List!!')
catch
    WML = [];
    mkdir([R.path.rootn '\outputs\' R.out.tag ]);
    save([R.path.rootn '\outputs\' R.out.tag '\WorkingModList'],'WML')
    disp('Making Mod List!!')
end

%% This is the main loop
for modID = 1:7
    if modID == 7
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
    load([R.path.rootn '\outputs\' R.out.tag '\WorkingModList'],'WML')
    if ~any(intersect(WML,modID))
        WML = [WML modID];
        save([R.path.rootn '\outputs\' R.out.tag '\WorkingModList'],'WML')
        disp('Writing to Mod List!!')
        fprintf('Now Fitting Model %.0f',modID)
        f = msgbox(sprintf('Fitting Model %.0f',modID));
        
        %% Prepare Model
        modelspec = eval(['@MS_periphStim_MSET1_M' num2str(modID)]);
        [R p m uc] = modelspec(R); % M! intrinsics shrunk"
        pause(5)
        R.out.dag = sprintf([R.out.tag '_M%.0f'],modID); % 'All Cross'
        
        %% Run ABC Optimization
        R = setSimTime(R,32);
        R.Bcond = 0; % This is the switch for modulation
        R.SimAn.rep = 256; % This determines the number of iterations per ABC sequence
        SimAn_ABC_250320(R,p,m);
        closeMessageBoxes
    end
end
