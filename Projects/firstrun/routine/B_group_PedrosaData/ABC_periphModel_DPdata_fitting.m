function ABC_periphModel_DPdata_fitting(R,fresh)
closeMessageBoxes
%% Start Loop (for parallel sessions)
try
        if fresh; error('Starting Fresh'); end
    load([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\WorkingModList'])
    disp('Loaded Mod List!!')
catch
    WML = fresh;
    mkdir([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag ]);
    save([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\WorkingModList'],'WML')
    disp('Making Mod List!!')
end

% Pretend the current sub is 1
for cursub = 3:numel(R.sublist)
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
        modelspec = eval(['@MS_periphStim_BMOD_MSET2_M' num2str(modID)]);
        [R dum m uc] = modelspec(R); % M! intrinsics shrunk"
        
        load([R.path.rootn '\Projects\' R.path.projectn '\empirical_priors\shenghong_modelfit.mat'])
        
        p = varo.Pfit;
        % Modify so B matrix is available
        p.B{1}(4,1) = 0; % Spin to Thal
        p.B{1}(4,2) = 0; % MMC to Thal
        p.B{1}(2,4) = 0; % Thal to CTX
        p.B{1}(3,1) = 0; % Spin to AMN
        p.B_s{1} = repmat(1/2,size(p.A_s{1})).*(p.B{1}==0);
        
        pause(1)
        R.out.dag = sprintf([R.out.tag '_BMOD_MSET%.0f_' R.sublist{cursub}],modID); % 'All Cross'
        
        %% Run ABC Optimization
        R = setSimTime(R,32);
        R.Bcond = 2;
        R.SimAn.rep = 256;
        SimAn_ABC_250320(R,p,m);
        closeMessageBoxes
    end
end
