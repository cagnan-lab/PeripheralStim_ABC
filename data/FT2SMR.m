function ft_dataOut = FT2SMR(SMR_data,fsample)
X = [];
for ch = 1:numel(SMR_data)-1
    X(:,ch) = SMR_data(ch).imp.adc;
    chanlabs{ch}  = SMR_data(ch).hdr.title;
end

% XT = [double(SMR_data(ch+1).imp.mrk(:,1)) double(SMR_data(ch+1).imp.tim)];
% %  Convert to target sample rate
% XT(:,2) = (XT(:,2)/fsample)/256
%
% trialdef = [XT(find(XT(:,1)==0),2) XT(find(XT(:,1)==1),2) repmat(1,numel(find(XT(:,1)==1)),1);
%     XT(find(XT(:,1)==2),2) XT(find(XT(:,1)==3),2) repmat(2,numel(find(XT(:,1)==3)),1)];

% Standardize
X = (X-mean(X,1))./std(X);

%% Make Trial Definition
XT = [
    69790 117900 0;
    123700 162600 0;
    185100 204800 1;
    215100 239800 1;
    254700 318800 0;
    348900 416500 1;
    429300 494300 0;
    505800 600800 1;
    608500 694600 1;
    722600 819800 1;
    831200 890000 0;
    898100 974700 1;
    1012000 1089000 0;
    1118000 1200000 1;
    1243000 1349000 0;
    1397000 1464000 1;
    1499000 1539000 0];

XT(:,1:2) = floor((XT(:,1:2)/fsample)*256);
XT(:,3) = XT(:,3)  + 1;
trialdef = XT;

tend    = size(X,1)./fsample;
timeVec = linspace(0,tend,size(X,1));

ft_data.label           = chanlabs;
ft_data.fsample         = fsample;
ft_data.trial{1}        = X';
ft_data.time{1}         = timeVec;

% Reference EEG Channels
ft_data.trial{1}(2:10,:) = ft_data.trial{1}(2:10,:)- ft_data.trial{1}(1,:);


cfg = [];
cfg.resamplefs = 256;
ft_data = ft_resampledata(cfg,ft_data);


for C = 1:2
    cfg = [];
    cfg.trl = trialdef(trialdef(:,3)==C,:);
    ft_dataOut(C) = ft_redefinetrial(cfg,ft_data);
end
