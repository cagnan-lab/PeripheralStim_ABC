function [genError,S,ROC,AUCCV] = computePlotSVM(X,LABEL,namelist,cmap,plotop)
if nargin<5
    plotop = 1;
end
hypoptFlag = 0;
if hypoptFlag
    hypoptStr = 'all';
else
    hypoptStr = 'none';
end
% Y = LABEL';  % samp cell of classes
for i = 1:size(X,1)
    Y(i) = LABEL(i); %namelist{LABEL(i)};
end
namelist = 1:numel(namelist);
t = templateSVM('Standardize',true,'KernelFunction','rbf');
myopts.ShowPlots = false;
[MdlUnopt,HpOpt] = fitcecoc(X,Y,'Learners',t,'FitPosterior',true,...
    'ClassNames',namelist,...
    'Verbose',1);

[Mdl,HpOpt] = fitcecoc(X,Y,'Learners',t,'FitPosterior',true,...
    'ClassNames',namelist,...
    'Verbose',1,'OptimizeHyperparameters',hypoptStr,'HyperparameterOptimizationOptions',myopts);

CVMdl = fitcecoc(X,Y,'Learners',t,...
    'ClassNames',namelist,...
    'Verbose',1,'CrossVal','on','KFold',5,'OptimizeHyperparameters',HpOpt);

genError = kfoldLoss(CVMdl,'Mode','individual','LossFun','classiferror');

[label,score_svm,PBScore,posterior] = resubPredict(Mdl);

for i = 1:numel(unique(LABEL))
    [Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(LABEL',posterior(:,i),i);
    ROC(i).Xsvm = Xsvm;
    ROC(i).Ysvm = Ysvm;
    ROC(i).Tsvm = Tsvm;
    ROC(i).AUCsvm = AUCsvm;
end

% Get diff in AUC
CV0 = cvpartition(size(X,1),'KFold',5);
AUCCV = [];
for cv = 1:CV0.NumTestSets
    MdlTMP = fitcecoc(X(training(CV0,cv),:),Y(training(CV0,cv)),'Learners',t,'FitPosterior',true,...
        'ClassNames',namelist,...
        'Verbose',0,'OptimizeHyperparameters',HpOpt);
    [label,score,~,posterior] = predict(MdlTMP,X(test(CV0,cv),:));
    genError(cv) = sum(Y(test(CV0,cv))==label')./numel(label);
    for i = 1:numel(MdlTMP.ClassNames)
        try
            [Xsvm,Ysvm,Tsvm,AUCsvm] = perfcurve(LABEL(test(CV0,cv))',posterior(:,i),i);
            AUCCV(i,cv) = AUCsvm';
        catch
            AUCCV(i,cv) = nan;
        end
    end
end
if isempty(AUCCV)
    a = 1;
end

% ROC = [];
if plotop
    xMax = max(X);
    xMin = min(X);
    xMax = xMax + 2*mean(abs(X));
    xMin = xMin - 2*mean(abs(X));
    
    x1Pts = linspace(xMin(1),xMax(1));
    x2Pts = linspace(xMin(2),xMax(2));
    [x1Grid,x2Grid] = meshgrid(x1Pts,x2Pts);
    [~,~,~,PosteriorRegion] = predict(MdlUnopt,[x1Grid(:),x2Grid(:)]);
    for C = 1:size(PosteriorRegion,2)
        PR = reshape(PosteriorRegion(:,C),size(x1Grid,1),size(x1Grid,2));
        S(C) = scatter(X(LABEL==C,1),X(LABEL==C,2),75,cmap(C,:),'filled','MarkerFaceAlpha',0.7);
        hold on
        [L,cand] = contour(x1Grid,x2Grid,PR,[0.5 0.75]);
        cand.LineColor = cmap(C,:); %[0.6 0.7 0.8]'*
        cand.LineWidth = 1.5;
        cand.LineStyle = '--';
        clabel(L,cand,'Font','Arial','FontSize',12,'Color',cmap(C,:));
    end
else
    S = [];
end