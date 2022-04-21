function [R p m uc] = MS_LMSV1_M13(R)
%% Lesion Model Space V1 %%
% Model 13 (3.6)

% FULL MODEL
[R,m] = getStateDetails(R);

% setup exogenous noise
% m.uset.p = DCM.Ep;
m.uset.p.covar = eye(m.m);
m.uset.p.scale = 1e-3; %.*R.InstP.dt;
uc = innovate_timeseries(R,m);

%% Prepare Priors
% R.nmsim_name = {'SC','Thal','EP','MMC','CER'}; %modules (fx) to use.

% Excitatory connections
p.A{1} =  repmat(-32,m.m,m.m);
p.A_s{1} = repmat(0,m.m,m.m);

p.A{1}(3,1) = 0; % SC to EP
% % p.A{1}(4,2) = 0; % THAL to MMC
p.A{1}(1,3) = 0; % EP to SC (spinal reflex)
p.A{1}(2,3) = 0; % EP to THAL
p.A{1}(1,4) = 0; % MMC to SC
p.A{1}(2,4) = 0; % MMC to THAL
p.A{1}(5,4) = 0; % MMC to CER
% % p.A{1}(2,5) = 0; % CER to THAL

p.A_s{1}(find(p.A{1}==0)) = 1/2;

% Modulatory
p.B{1} =  repmat(-32,m.m,m.m);
p.B_s{1} = repmat(1/8,size(p.A_s{1})).*(p.B{1}==0);

% Inhibtory
p.A{2} =  repmat(-32,m.m,m.m);
p.A_s{2} = repmat(0,m.m,m.m);

p.B{2} =  repmat(-32,m.m,m.m);
p.B_s{2} = repmat(1/8,size(p.A_s{2})).*(p.B{2}==0);

% Input strengths
p.C = zeros(m.m,1);
p.C_s = repmat(1,size(p.C));

% Leadfield
p.obs.LF = [0 0];
p.obs.LF_s = repmat(2,size(p.obs.LF));

p.obs.Cnoise = zeros(1,m.m);
p.obs.Cnoise_s = repmat(1/2,size(p.obs.Cnoise));

p.obs.mixing = [1]; %zeros(size(R.obs.mixing));
p.obs.mixing_s = repmat(0,size(p.obs.mixing));

% Delays
p.DExt = repmat(-32,size(p.A{1})).*~((p.A{1}>-32) | (p.A{2}>-32)) ;
p.DExt_s = repmat(1/8,size(p.DExt));

% Sigmoid transfer for connections
% p.S = [0 0];
% p.S_s = [1/8 1/8];
% time constants and gains
for i = 1:m.m
    prec = 1/8;
    p.int{i}.T = zeros(1,m.Tint(i));
    p.int{i}.T_s = repmat(prec,size(p.int{i}.T));
    p.int{i}.G = zeros(1,m.Gint(i));
    p.int{i}.G_s = repmat(prec/2,size(p.int{i}.G));
    p.int{i}.S = zeros(1,m.Sint(i));
    p.int{i}.S_s = repmat(prec,size(p.int{i}.S));
%     p.int{i}.C = 0;
%     p.int{i}.C_s = 1/4;
    %     p.int{i}.BT = zeros(1,m.Tint(i));
    %     p.int{i}.BT_s = repmat(prec,size(p.int{i}.T));
end


% load('shenghong_cerebellumFit2Thal.mat','Pfit')
% disp('Loading pre-fitted cerebellum priors')
% p.int{5} = Pfit.int{1};

