function analysis_ShengHongInactivation(R)
% How do you have an oscillation if you remove connection between AMN and
% SPIN? Where the hell is is coming from?
fresh = 1;
simtime = 32;
modID = 1;
[R,m,permMod,xsimMod] = getSimModelData_160620(R,modID,simtime,1);
p = permMod{1}.par_rep{1};

% Plotting colors
cmap = brewermap(128,'RdBu');
ckeypow = linspace(-100,75,128); % These make a key for colorcoding the results
ckeyfrq = linspace(-10,10,128);

% Connection names
condname = {'Fitted','Spin -> Thal','Spin -> AMN','MMC -> AMN','MMC -> Thal','AMN-> spin','Thal -> MMC'};
% Connection spec [ex/inh tar src]
AIJ = {[], ... % base model
    [1 4 1],... % Spin to Thal
    [1 3 1],... % Spin to AMN
    [1 3 2],... % MMC to AMN
    [1 4 2],... % MMC to Thal
    [1 1 3],... % AMN to Spin
    [1 2 4],... % Thal to MMC
    };

% Give all timeseries the same input
uc = innovate_timeseries(R,m);
R.obs.trans.norm = 0; % No normalization of spectra
R.obs.trans.normcat = 0;


Pbase = p;
fitIJ = []; powIJ_B = [];
if fresh == 1
    for i = 1:size(condname,2)
        Pbase_i = Pbase; % Load parameter base
        if i~=1
            Pbase_i.A{AIJ{i}(1)}(AIJ{i}(2),AIJ{i}(3)) = -32; % Remove the ith connection
        end
        for j = 1:size(condname,2)    % Setup the simulations
            Pbase_ij = Pbase_i;
            if j~=1
                Pbase_ij.A{AIJ{j}(1)}(AIJ{j}(2),AIJ{j}(3)) = -32; % Remove the jth connection
            end
            [r2,~,feat_sim,dum,xsim_gl] = computeSimData_160620(R,m,uc,Pbase_ij,0); % Simulates the new model
            featSave{j,i} = feat_sim;
            % Find resulting power statistics of the simulated data (STN
            % beta
            [powIJ_B(j,i),peakIJ_B(j,i),freqIJ_B(j,i)] = findSpectralStats(R.frqz,squeeze(feat_sim(1,1,1,1,:)),[2 10]);
            [powIJ_B1(j,i),peakIJ_B1(j,i),freqIJ_B1(j,i)] = findSpectralStats(R.frqz,squeeze(feat_sim(1,1,1,1,:)),[2 10]);
            [powIJ_B2(j,i),peakIJ_B2(j,i),freqIJ_B2(j,i)] = findSpectralStats(R.frqz,squeeze(feat_sim(1,1,1,1,:)),[2 10]);
            fitIJ(j,i) = r2;
            disp([i j])
        end
    end
    rootan = [Rorg.rootn 'data\' Rorg.out.oldtag '\LesionData'];
    mkdir(rootan)
    save([rootan '\BAA_lesion'],'powIJ_B','peakIJ_B','freqIJ_B',...
        'powIJ_B1','peakIJ_B1','freqIJ_B1',...
        'powIJ_B2','peakIJ_B2','freqIJ_B2','condname',...
        'featSave')
else
    rootan = [Rorg.rootn 'data\' Rorg.out.oldtag '\LesionData'];
    load([rootan '\BAA_lesion'],'powIJ_B','peakIJ_B','freqIJ_B',...
        'powIJ_B1','peakIJ_B1','freqIJ_B1',...
        'powIJ_B2','peakIJ_B2','freqIJ_B2','condname')
end

figure
        X = (powIJ_B-powIJ_B(1,1))./(powIJ_B(1,1)).*100;
        Y = (freqIJ_B-freqIJ_B(1,1));
b = bar(X(1,:));
a = gca;
a.XTickLabel = condname
ylabel('Change in Tremor Power at Spindle');
title('Impact of Inactivations upon Tremor Amplitude')
% xlim([0.5 5.5])

figure

for i = [1 4]
    plot(R.frqz,squeeze(featSave{i,i}(1,1,1,1,:))); 
    hold on
end