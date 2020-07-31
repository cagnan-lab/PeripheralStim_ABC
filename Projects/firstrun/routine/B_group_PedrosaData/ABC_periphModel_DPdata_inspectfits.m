function ABC_periphModel_DPdata_inspectfits(Rorg,fresh,plotop)
% Run through fits of DP data and plot
D = []; %initialize regressors
subsel = Rorg.subsel;

Rorg.plot.cmap_group = brewermap(12,'Set2');
for cursub = subsel
    modID = 1;% You only fitted to model 1
    Rorg.out.dag = sprintf([Rorg.out.tag '_BMOD_MSET%.0f_' Rorg.sublist{cursub}],modID); % 'All Cross'
    
    % Load Config
    load([Rorg.path.rootn '\outputs\' Rorg.path.projectn '\'  Rorg.out.tag '\' Rorg.out.dag '\R_' Rorg.out.tag '_' Rorg.out.dag  '.mat'])
    
    % Replace with new version but maintain paths
    tmp = varo;
    tmp.path = Rorg.path;
    tmp.plot = Rorg.plot;
    
    %% Corrections to file structure to make compatible
    if ~iscell(tmp.data.feat_xscale)
        X = tmp.data.feat_xscale;
        tmp.data.feat_xscale = [];
        tmp.data.feat_xscale{1} = X;
    end
    if ~iscell(tmp.data.feat_emp)
        X = tmp.data.feat_emp;
        tmp.data.feat_emp = [];
        tmp.data.feat_emp{1} = X;
    end
    if ~iscell(tmp.data.datatype)
        X = tmp.data.datatype;
        tmp.data.datatype = [];
        tmp.data.datatype{1} = X;
    end
    
    if ~isfield(tmp,'chdat_name')
        tmp.chdat_name = tmp.chsim_name;
    end
    R = tmp;
    %%          %%
    % Load Model Specs
    load([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\' R.out.dag '\modelspec_' R.out.tag '_'  R.out.dag '.mat'])
    m = varo;
    
    if fresh
        % load modelfit
        load([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\' R.out.dag '\modelfit_' R.out.tag '_' R.out.dag '.mat'])
        mfit = varo;
        R.Mfit = mfit;
        p = mfit.BPfit;
        
        % load parbank?
        load([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\' R.out.dag '\parBank_' R.out.tag '_' R.out.dag '.mat'])
        parBank =  varo;
        R = setSimTime(R,32);
        
        R.analysis.modEvi.eps = parBank(end,R.SimAn.minRank);
        R.analysis.BAA.flag = 0; % Turn off BAA flag (time-locked analysis)
        parOptBank = parBank(1:end-1,parBank(end,:)>R.analysis.modEvi.eps);
        
        if  size(parOptBank,2)>1
            R.parOptBank = parOptBank;
            R.obs.gainmeth = R.obs.gainmeth(1);
            R.obs.trans.gauss = 0;
            figure(modID);
            R.analysis.modEvi.N = 256;
            permMod = modelProbs_160620(m.x,m,p,R);
        else
            permMod = [];
        end
        saveMkPath([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\' R.out.dag '\modeProbs_' R.out.tag '_' R.out.dag '.mat'],permMod)
    else
        
        load([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\' R.out.dag '\modeProbs_' R.out.tag '_' R.out.dag '.mat'],'varo')
        permMod = varo;
    end
    
    subdatafile = [R.path.rootn '\outputs\' R.path.projectn '\data\DP\thalamomuscular\dp_thalamomuscular_' R.sublist{cursub} '_pp.mat'];
    load(subdatafile)
    
    D = getDPdata_regressors(R,cursub,D);
    
    
    r2bank{cursub} = permMod.r2rep;
    dklbank{cursub} = permMod.DKL;
    ACCbank{cursub} = permMod.ACCrep;
    mapbank{cursub} = permMod.MAP;
    
    
    if plotop
        h(1) = figure(cursub*100 + 1);
        h(2) = figure(cursub*100 + 2);
        R.plot.confint = 'yes';
        R.plot.cmplx = 1;
        PlotFeatureConfInt_gen170620(R,permMod,h,Rorg.plot.cmap_group(cursub,:));
    end
end


%% Now Plot the various parameters
i = 0;
r2par = []; dklpar = []; accpar = []; parpar = [];
for cursub = subsel
    i = i+1;
    X = [r2bank{cursub}];
    r2par(:,i) = keyUnivariateStats(X,1);
    dklpar(i) = [dklbank{cursub}]';
    X = [ACCbank{cursub}]';
    accpar(:,i) = keyUnivariateStats(X,1);
    %     mapbank{cursub}
    
    [pInd,pMu,pSig] = parOptInds_110817(R, mapbank{cursub},4); % in structure form
    % Form descriptives
    pMuMap = spm_vec(pMu);
    pSigMap = spm_vec(pSig);
    
    parvec = spm_vec(mapbank{cursub});
    parpar(:,1,i) = parvec(pMuMap);
    parpar(:,2,i) = parvec(pSigMap);
end

parNamesFull = getParFieldNames(permMod.MAP,m);
parNameMu = parNamesFull(pMuMap);
parNameSig = parNamesFull(pSigMap);


%% Convert Regressors to Table
i = 0;
trempow = []; tremSEM = [];
for cursub = subsel
    i = i+1;
    trempow(:,i) = D.trempow(1,1,cursub);
    tremSEM(:,i) = D.tremEnvSEM(1,1,cursub);
    tremDiff(:,i) = D.condpow(1,cursub);
end


[dum id] = intersect(pMuMap,spm_vec(pMu.B))
tab = array2table([tremDiff; squeeze(parpar(id,1,:))]','VariableNames',['Dep',parNamesFull(spm_vec(pMu.B))]);
mdl1 = stepwiselm(tab,'constant','ResponseVar','Dep');
[Rcor,PValue] = corrplot(tab)
% [idx,scores] = fsrftest(tab,'Dep')

[dum id] = intersect(pMuMap,spm_vec(pMu.B))
tab = array2table([tremDiff; squeeze(parpar(id,1,:))]','VariableNames',['Dep',parNamesFull(spm_vec(pMu.B))]);
[B fitinfo] = lasso(table2array(tab(:,2:end)),table2array(tab(:,1)),'CV',5)
lassoPlot(B,fitinfo,'PlotType','Lambda','XScale','log');
% X = tab(:,{'Dep','int THAL G2'});
figure(2312)
plist = find(sum(B(:,end-20:end),2));
for i = 1:3
    subplot(1,3,i)
    scatter(table2array(tab(:,1)),table2array(tab(:,plist(i)+1)),100,'filled'); hold on
    [X,Y] = linregress(table2array(tab(:,1)),table2array(tab(:,plist(i)+1)));
    plot(X,Y,'LineWidth',2)
    xlabel('Change in Tremor Power'); ylabel('log Expectation')
    title( tab.Properties.VariableNames{plist(i)+1}); grid on
end



%% Plots of Fitting Details
figure(28)
subplot(1,3,1)
makeBarPlotError(r2par(1,:),r2par(2,:),'subject',R.plot.cmap_group(subsel,:))
ylabel('RMSE')

subplot(1,3,2)
makeBarPlotError(dklpar(1,:),[],'subject',R.plot.cmap_group(subsel,:))
ylabel('KL Divergence')

subplot(1,3,3)
makeBarPlotError(accpar(1,:),accpar(2,:),'subject',R.plot.cmap_group(subsel,:))
ylabel('Combined ACC Score')
leg = legend(R.sublist(subsel));
leg.Position = [ 0.9136    0.1240    0.0800    0.1961];

set(gcf,'Position',1e3.*[0.3162    0.4074    1.1176    0.3546])
% Plots of parameters
figure(29)

a = subplot(2,1,1)
X = squeeze(parpar(:,1,:));
makeBarPlotError(X,[],[],R.plot.cmap_group(subsel,:))
ylabel('Log Scaling'); title('All fitted parameters'); ylim([-4 2.5]); xlabel('Parameter Number')
a.XTickLabel = parNameMu(a.XTick);
a.XTickLabelRotation = 45;

subplot(2,2,3)
connames = {'IMF to AMN','CTX to AMN','IMF to Thal','CTX to Thal','AMN to IMF','Thal to CTX'}
[dum id] = intersect(pMuMap,spm_vec(pMu.A))
X = squeeze(parpar(id,1,:));
Z = squeeze(parpar(id,2,:));
makeBarPlotError(X,Z,connames,R.plot.cmap_group(subsel,:))
ylabel('Log Scaling'); title('Connectivity')

subplot(2,2,4)
connames = {'CTX to AMN','IMF to Thal','CTX to Thal','Thal to CTX'}
[dum id] = intersect(pMuMap,spm_vec(pMu.B))
X = squeeze(parpar(id,1,:));
Z = squeeze(parpar(id,2,:));
makeBarPlotError(X,Z,connames,R.plot.cmap_group(subsel,:))
ylabel('Log Scaling'); title('Modulation')
leg = legend(R.sublist(subsel))
leg.Position = [0.9141 0.1069 0.0801 0.1161];
set(gcf,'Position',1e3.*[ 0.3162    0.1634    1.1168    0.5986])
