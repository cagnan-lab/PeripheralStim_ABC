function ABC_AntagonistPair_fit(R,fresh)
closeMessageBoxes

%% Start Loop (for parallel sessions)
% WML is a remote accessible for coordinating parallel sessions
if fresh
    spreadSession(R,[]); % Fresh
else
    spreadSession(R,0)
end


%% This is the main loop
for modID = R.modcomp.modlist
    switch R.modelspec
        case 'antagPair_SET1'
                R.obs.Cnoise = R.obs.Cnoise(1:4);
                R.obs.LF = R.obs.LF(1:4); % Fit visually and for normalised data
                R.nmsim_name = {'MMC','THAL','SpinCrd','Musc1','SpinCrd','Musc1'}; %modules (fx) to use.
                R.chsim_name = {'ctx','Thal','SpinAgo','MuscAgo','SpinAnt','MuscAnt'}; % simulated channel names (names must match between these two!)
                R.siminds = 1:6;
    end
%     if  spreadSession(R,modID)
        %% Prepare Model
        modelspec = eval(['@MS_' R.modelspec '_M' num2str(modID)]);
        [R p m uc] = modelspec(R); % M! intrinsics shrunk"
        pause(5)
        R.out.dag = sprintf([R.out.tag '_M%.0f'],modID); % 'All Cross'
        
        %% Run ABC Optimization
        SimAn_ABC_201120(R,p,m);
%         spreadSession(R,0);
%     end
end
