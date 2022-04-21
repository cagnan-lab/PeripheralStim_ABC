function D = getDPdata_regressors(R,cursub,D)
% This function constructs a set of regressors from the original data
    % Retrieve Data
    subdatafile = [R.path.rootn '\outputs\' R.path.projectn '\data\DP\thalamomuscular\dp_thalamomuscular_' R.sublist{cursub} '_pp.mat'];
    
            load(subdatafile,'dataOut')
for C = 1:2
    fsamp = dataOut(C).fsample;
    X = [dataOut(C).trial{:}]';
    X = (X-mean(X,1))./std(X,[],1);
    [fz hz] = pwelch(X,fsamp,[],fsamp,fsamp);
    TA = fz((hz>=2 & hz <=12),:); % tremor Amps
    TF = hz((hz>=2 & hz <=12),:); % tremor frequencies
    [D.trempow(:,C,cursub) mind] = max(TA);
    
    D.tremfrq(:,C,cursub) = TF(mind,:);
    
    [fz hz] = mscohere(X(:,1),X(:,2),fsamp,[],fsamp,fsamp);
    D.tremcoh(C,cursub) = max(fz((hz>=2 & hz <=12),:));
    
    % Tremor Volatility
    XA = abs(hilbert(X));
    D.tremEnvSTD(:,C,cursub) = std(XA);
    D.tremEnvSEM(:,C,cursub) = std(XA)./mean(XA);
end
    
D.condpow(:,cursub) = diff(D.trempow(:,:,cursub),1,2);