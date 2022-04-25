function [durMeanSTD,ampMeanSTD,intMeanSTD,feat_out,bddls,F,wflag] = getBurstStats(R,X,frq,fsamp,statflag)
R.condnames = {'a'};
X = X(:); %concatanate
dat{1} = X';
R.obs.trans.gausSm = 2.5;
if numel(frq)==1
    R.obs.trans.bursts.frq = [frq-3 frq+3];
    warning('Remember the burst definition is now changing based on the spectral peak frequency')
else
    R.obs.trans.bursts.frq = frq;
end
[F,feat_out] = R.obs.transFx(dat,1,fsamp,11,R);
if ~any(isnan(F{2}))
    wflag = 0;
    [ampMeanSTD(1),ampMeanSTD(2)] = pdfExpVal(feat_out{2},F{2}');
    [durMeanSTD(1),durMeanSTD(2)] = pdfExpVal(feat_out{3},F{3}');
    [intMeanSTD(1),intMeanSTD(2)] = pdfExpVal(feat_out{4},F{4}');
    
else
    wflag = 1;
    durMeanSTD = nan(1,2);
    ampMeanSTD = nan(1,2);
    intMeanSTD = nan(1,2);
    
    feat_out{2} = nan(size(F{2}));
    feat_out{3} = nan(size(F{3}));
    feat_out{4} = nan(size(F{4}));
end

if statflag == 1
    [surr,params] = surrogate(dat{1}, 100, 'FT', 1, 1/fsamp);
    LS_1 = []; LS_2 = [];
    parfor i_surr = 1:100
        [F,feat_out_sur,wflag] = R.obs.transFx({surr(i_surr,:)},1,fsamp,11,R);
        if ~wflag
            LS_1(:,i_surr) = feat_out_sur{2};
            LS_2(:,i_surr) = feat_out_sur{3};
        else
            LS_1(:,i_surr) = nan;
            LS_2(:,i_surr) = nan;
        end
    end
    surrAvgBurstDuration = mean(LS_1,2);
    bddls(1) = nansum((feat_out{2} - surrAvgBurstDuration).^2)/nansum((feat_out{2}-nanmean(feat_out{2})).^2);
    surrAvgBurstAmp = mean(LS_2,2);
    bddls(2) = nansum((feat_out{3} - surrAvgBurstAmp).^2)/nansum((feat_out{3}-nanmean(feat_out{3})).^2);
    bddls = 1-bddls;
else
    bddls = nan(1,2);
end

