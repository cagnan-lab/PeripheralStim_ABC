function plotTremorConditionModelComparison(R)
close all
cmap = brewermap(128,'YlOrRd');
FitStats = loadABCGeneric(R,{'FitStats'});
subplot(2,2,4); ylim([-0.075 0.075])
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

familyName = {'No DA','No TC','No CT','No CCer','No CerC'};

fP = fP./sum(fP);
fACS = fACS./sum(fACS);
figure
subplot(2,2,3)
B = bar((fP))
B.FaceColorMode = 'manual';
B.FaceColor = 'k';
a = gca;
a.XTick = 1:numel(familyName);
a.XTickLabel = familyName;
a.XTickLabelRotation = 45;
ylabel('P(M|D)')
title('Family-wise P(F|D)')
axis([0 6 0 0.35])

subplot(2,2,4)
B = bar(fACS)
B.FaceColorMode = 'manual';
B.FaceColor = 'k';

a = gca;
a.XTick = 1:numel(familyName);
a.XTickLabel = familyName;
a.XTickLabelRotation = 45;
ylabel('Acc. - Complexity')
title('Family-wise ACS')
axis([0 6 -1 1])

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
IS = imagesc((fPMat));
IS.AlphaData =~isnan(fPMat);
colormap(cmap)
caxis([0 0.15])
colorbar
axis square
title('P(M|D)')
a = gca;
a.XTick = 1:numel(familyName);
a.XTickLabel = familyName;
a.XTickLabelRotation = 45;
a.YTick = 1:numel(familyName);
a.YTickLabel = familyName;

subplot(2,2,2)
IS = imagesc((fACSMat));
IS.AlphaData =~isnan(fACSMat);
caxis([-0.05 0.05])
colorbar

axis square
title('Acc. - Complexity')
a = gca;
a.XTick = 1:numel(familyName);
a.XTickLabel = familyName;
a.XTickLabelRotation = 45;
a.YTick = 1:numel(familyName);
a.YTickLabel = familyName;

