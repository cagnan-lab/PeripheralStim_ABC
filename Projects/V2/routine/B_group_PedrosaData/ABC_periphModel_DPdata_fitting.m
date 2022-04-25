function ABC_periphModel_DPdata_fitting(R,fresh)
closeMessageBoxes
%% Start Loop (for parallel sessions)
try
        if fresh; error('Starting Fresh'); end
    load([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\WorkingModList'])
    disp('Loaded Mod List!!')
catch
    WML = [];
    mkdir([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag ]);
    save([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\WorkingModList'],'WML')
    disp('Making Mod List!!')
end

% Pretend the current sub is 1
for cursub = 1:numel(R.sublist)
    load([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\WorkingModList'],'WML')
    if ~any(intersect(WML,cursub))
        WML = [WML cursub];
        save([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\WorkingModList'],'WML')
        disp('Writing to Sub List!!')
        fprintf('Now Fitting Subject %.0f',cursub)
%         f = msgbox(sprintf('Fitting Subject %.0f',cursub));
        
        %% Load in precomputed empirical CSDs
        subABCdatafile = [R.path.rootn '\outputs\' R.path.projectn '\data\DP\thalamomuscular\dp_thalamomuscular_' R.sublist{cursub} '_ABC.mat'];
        load(subABCdatafile,'Rdat')
        R.data = Rdat;
            R.plot.outFeatFx({R.data.feat_emp},[],R.data.feat_xscale,R,[],[]);

        %% Prepare Model
        modID = 1;
        modelspec = eval(['@MS_' R.modelspec '_M' num2str(modID)]);
        [R p m uc] = modelspec(R); % M! intrinsics shrunk"
        R.SimAn.jitter = 1;
        
        pause(1)
        R.out.dag = sprintf([R.out.tag '_BMOD_MSET%.0f_' R.sublist{cursub}],modID); % 'All Cross'
        
        %% Run ABC Optimization
        R = setSimTime(R,28);
        R.Bcond = 2;
        R.SimAn.rep = 256;
        SimAn_ABC_201120(R,p,m);
        closeMessageBoxes
    end
end
