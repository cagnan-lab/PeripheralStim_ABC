function ABC_periphModel_DPdata_inspectfits(R,fresh,plotop)
% Run through fits of DP data and plot
subsel = [1 6 8 11];
R.plot.cmap_group = brewermap(12,'Set2');
for cursub = subsel%1:numel(R.sublist)
    modID = 1;% You only fitted to model 1
    R.out.dag = sprintf([R.out.tag '_BMOD_MSET%.0f_' R.sublist{cursub}],modID); % 'All Cross'
    
    % Load Config
    load([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\' R.out.dag '\R_' R.out.tag '_' R.out.dag  '.mat'])
    
    % Replace with new version but maintain paths
    tmp = varo;
    tmp.path = R.path;
    tmp.plot = R.plot;
    R  = tmp;
    
    
    if fresh
        % Load Model
        load([R.path.rootn '\outputs\' R.path.projectn '\'  R.out.tag '\' R.out.dag '\modelspec_' R.out.tag '_'  R.out.dag '.mat'])
        m = varo;
        
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
    
    r2bank{cursub} = permMod.r2rep;
    dklbank{cursub} = permMod.DKL;
    ACCbank{cursub} = permMod.ACCrep;
    mapbank{cursub} = permMod.MAP;

    
    if plotop
    h(1) = figure(cursub*100 + 1);
    h(2) = figure(cursub*100 + 2);
    R.plot.confint = 'yes';
    R.plot.cmplx = 1;
    PlotFeatureConfInt_gen170620(R,permMod,h,R.plot.cmap_group(cursub,:));
    end
end


%% Now Plot the various parameters
i = 0;
r2par = []; dklpar = []; accpar = []; parpar = [];
for cursub = subsel
    i = i+1;
    X = [r2bank{cursub}{:}];
    r2par(:,i) = keyUnivariateStats(X);
    dklpar(i) = [dklbank{cursub}]';
    X = [ACCbank{cursub}{:}]';
    accpar(:,i) = keyUnivariateStats(X);
%     mapbank{cursub}

   [pInd,pMu,pSig] = parOptInds_110817(R, mapbank{cursub},4); % in structure form
   % Form descriptives
   pMuMap = spm_vec(pMu);
   pSigMap = spm_vec(pSig);

   parvec = spm_vec(mapbank{cursub});
   parpar(:,1,i) = parvec(pMuMap);
   parpar(:,2,i) = parvec(pSigMap);
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

subplot(2,1,1)
X = squeeze(parpar(:,1,:));
makeBarPlotError(X,[],[],R.plot.cmap_group(subsel,:))
ylabel('Log Scaling'); title('All fitted parameters'); ylim([-4 2.5]); xlabel('Parameter Number')

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
