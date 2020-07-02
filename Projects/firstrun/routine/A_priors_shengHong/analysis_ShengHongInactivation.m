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
condname = {'Fitted','IFMF -> Thal','IFMF -> AMN','MMC -> AMN','MMC -> Thal','AMN-> IFMF','Thal -> MMC'};
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
fitIJ = []; tremPow = [];
if fresh == 1
    parfor i = 1:size(condname,2)
        Pbase_i = Pbase; % Load parameter base
        if i~=1
            Pbase_i.A{AIJ{i}(1)}(AIJ{i}(2),AIJ{i}(3)) = -32; % Remove the ith connection
        end
            [r2,~,feat_sim,dum,xsim_gl] = computeSimData_160620(R,m,uc,Pbase_i,0); % Simulates the new model
            featSave{i} = feat_sim;
            % Find resulting power statistics of the simulated data (STN
            % beta
            [tremPow(i),trempeak(i),tremfreq(i)] = findSpectralStats(R.frqz,squeeze(feat_sim(1,1,1,1,:)),[2 10]);
            fitIJ(i) = r2;
            disp([i])
    end
    rootan = [R.path.projpath '\outputs\' R.out.tag '\LesionData'];
    mkdir(rootan)
    save([rootan '\tremorlesions'],'tremPow','trempeak','tremfreq','condname','featSave')
else
    rootan = [Rorg.rootn 'data\' Rorg.out.oldtag '\LesionData'];
    load([rootan '\tremorlesions'],'tremPow','trempeak','tremfreq','condname','featSave')
end

figure(10); gcf
subplot(2,1,1)
X = (tremPow-tremPow(1,1))./(tremPow(1,1)).*100;
b = bar(X(1,:));
a = gca;
a.XTickLabel = condname
a.XTickLabelRotation = 45;
ylabel('Change in Tremor Power at Spindle');
title('Impact of Inactivations upon Tremor Amplitude')
grid on

subplot(2,1,2)
X = (tremfreq-tremfreq(1,1))./(tremfreq(1,1)).*100;
b = bar(X(1,:));
a = gca;
a.XTickLabel = condname
a.XTickLabelRotation = 45;
ylabel('Change in Tremor Power at Spindle');
title('Impact of Inactivations upon Tremor Amplitude')
grid on
% xlim([0.5 5.5])

figure

for i = [1 4]
    plot(R.frqz,squeeze(featSave{i,i}(1,1,1,1,:))); 
    hold on
end