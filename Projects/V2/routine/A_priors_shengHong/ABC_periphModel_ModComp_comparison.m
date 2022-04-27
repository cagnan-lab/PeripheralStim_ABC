function ABC_periphModel_ModComp_comparison(R,mSel,pSel,fresh)
close all
if any(fresh) | isempty(fresh)
    R.comptype = 1;
    R.plot.flag = 1;
    modelCompMaster_160620(R,mSel,fresh);
end
R.modcomp.modN =  R.modcomp.modlist;
R.modcompplot.NPDsel = pSel;
R.plot.confint = 'yes';
R.plot.cmplx = 1;
cmap = linspecer(numel(R.modcomp.modN));
cmap = cmap(end:-1:1,:);
% load tmpData
FitStats = plotModComp_310520(R,cmap)


%% Plotting (put in seperate function)
modGroups = {
    [ 2  7  8  9 10],... % Deafferent
    [ 3  2 11 12 13],... % No TC
    [ 4  8 11 14 15],... % No CT
    [ 5  9 12 14 16],... % No CCer
    [ 6 10 13 15 16],... % No CerT
    };

pMD = FitStats.pModDist;


for G = 1:numel(modGroups)
    % calculate combined probabilities
    fP(G) = sum(FitStats.pModDist(modGroups{G}));
    
    fACS(G) = sum(FitStats.ACS(modGroups{G}));
end

familyName = {'No Aff','No Thalamocortical','No CorticoThalamic','No Cereb. Cortico','No Cereb. Thalamic'}

fP = fP./sum(fP);
fACS = fACS./sum(fACS);
figure
subplot(2,2,3)
bar((fP))
    a = gca;
    a.XTick = 1:numel(familyName);
    a.XTickLabel = familyName;
    a.XTickLabelRotation = 45;

subplot(2,2,4)
bar(fACS)
    a = gca;
    a.XTick = 1:numel(familyName);
    a.XTickLabel = familyName;
    a.XTickLabelRotation = 45;
% Matrix Setup

AG  = [2  0  0  0  1
    7  3  0  0  0
    8 11  4  0  0
    9 12 14  5  0
    10 13 15 16  6];

for i = 1:5
    for j = 1:5
        modInd = AG(i,j)
        if modInd ~= 0
        fPMat(i,j) = FitStats.pModDist(modInd);
        fACSMat(i,j) = FitStats.ACS(modInd);
        else
        fPMat(i,j) = nan;
         fACSMat(i,j) = nan;
        end
    end
end
subplot(2,2,1)
imagesc((fPMat))
axis square

subplot(2,2,2)
imagesc((fACSMat))
axis square




figure(2)
% subplot(3,1,1); ylim([-8 1])

% % Get sample Data
% uc = innovate_timeseries(R,m);
% uc{1} = uc{1}.*sqrt(R.IntP.dt);
% [~,~,feat_sim{1},~,xsim_ip{1}] = computeSimData(R,m,uc_ip{1},Pbase,0);
