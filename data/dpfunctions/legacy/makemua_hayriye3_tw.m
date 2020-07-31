function [mua] = makemua_hayriye3_tw(hpsig,msback,msfoward,muasr,rssr,uthresh)
mua = [];
plotop = 0;
for ch = 1:size(hpsig,2)
    X = hpsig(:,ch);
% hpsig = wideband signal
% msback = length of data replaced before a spike in s
% msback = length of data replaced before after spike in s
% muasr = sampling rate of the orignal channel
% rssr = sampling rate of the new channel
% uthresh = threshold for single units in SDs of baseline. 


% For example
%[mua] = makemua_fede(muatemp,0.001,0.003,muasr,4);
% 
% hpsig = unit (already high pass filtered);
% msback = 0.001;
% msfoward = 0.003;
% muasr = 16000;
% uthresh = 4;
% Highpass filter signal
if plotop; plot(X); hold on; end
% clear mua
clear beta*
clear muatemphp
[betab,betaa] = butter(3,300/(muasr/2),'high');
muatemphp = filtfilt(betab,betaa,X);

if plotop; plot(muatemphp); end

% clear muatemphp
% muatemphp = hpsig;

clear E1d*
clear E1n*
% Resample 
E1d = muatemphp;
tback = floor(msback*muasr);
tforward = floor(msfoward*muasr);
clear E1 abs;
E1dabs = abs(E1d);

if plotop;plot(E1dabs); end

clear tthres*
% Set threshold for single units
tthres = mean(E1dabs)+(std(E1dabs)*uthresh);
% tthresneg = mean(E1d)-(std(E1d)*uthresh);

clear tpass*

% Find index of units
tpass = find(E1dabs>tthres);
% tpassneg = find(E1d<tthresneg);

% Make binary unit channel for pos and neg crosses 
tpassbin = zeros(size(E1d,1),1);
tpassbin(tpass) = 1;
% 
% tpassbinneg = zeros(size(E1d,1),1);
% tpassbinneg(tpassneg) = 1;


% tpassbinbw = bwlabeln(tpassbin);

% Define window for unit removal

% Define start of window
tpassmina  = tpass-tback; 
% Remove any windows t0o near the front
tpassmin = tpassmina(tpassmina>0);
% Make matrix of indices to remove
tpassmat = repmat(tpassmin,1,tforward);
tpassmatplus = repmat(0:1:tforward-1,size(tpassmin,1),1); 
% Reshape to vector of indices
tpassmatall = reshape(tpassmat'+tpassmatplus',tforward*size(tpassmin,1),1);
% 
% Make new unit channel
clear E1n*
E1n = E1d;
% Make all unit indices NaN
E1n(tpassmatall) = NaN;
if plotop; plot(E1n); end

% E1n(npassmatall) = NaN;
% 
clear nanpos
clear nanneg
nanpos = isnan(E1n);
nanneg = (nanpos ==0);


clear allnoise*
allnoise = E1n(nanneg);

allnoisemix = [allnoise(round(end/2):end); allnoise(1:round(end/2));allnoise(round(end/2):end); allnoise(1:round(end/2))];
allnoisemid = round(size(allnoisemix,1)/2);
allnoisematchA =  allnoisemix(   allnoisemid-round((size(nanpos,1)/2)):  allnoisemid+round((size(nanpos,1)/2)));
allnoisematch = allnoisematchA(1:size(nanpos,1));
allnoisematch(nanneg) = NaN;

E1z = nansum([E1n allnoisematch],2);
if plotop;plot(E1z); end

% plot(E1d)
% hold on
% plot(E1z,'r')

% Low pass filter 
clear beta*
clear muatemphp
clear muat
[betab,betaa] = butter(3,300/(muasr/2),'low');
muat = filtfilt(betab,betaa,E1z.^2);
if plotop; plot(muat); end

    
mua(:,ch) = resample(muat(1:length(X)),rssr,muasr);  
end
% 
% clear mua
% clear tx1
% mua =E1z;


% [pow,f] = pwelch(mua,1000,500,1000,1000);



