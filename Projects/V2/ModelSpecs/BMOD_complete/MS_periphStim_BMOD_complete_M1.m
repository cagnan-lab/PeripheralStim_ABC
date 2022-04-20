function [R p m uc] = MS_periphStim_BMOD_complete_M1(R)
% FULL MODEL with Cerebellum
% Null-Model
[R,m] = getStateDetails(R);

% setup exogenous noise
% m.uset.p = DCM.Ep;
m.uset.p.covar = eye(m.m);
m.uset.p.scale = 1e-3; %.*R.InstP.dt;
uc = innovate_timeseries(R,m);

%% Prepare Priors
% R.nmsim_name = {'SpinCrd','THAL','Musc1','MMC'}; %modules (fx) to use.
load('shenhong_TremPrior_withCereb','Pfit')
p = Pfit;

% Modulatory
p.B{1} =  repmat(-32,m.m,m.m);
p.B{1}(1,3) = 0; % Spin to SC (spinal reflex)
p.B{1}(5,3) = 0; % Spin to Cereb
p.B{1}(2,4) = 0; % MMC to Thal
p.B{1}(5,4) = 0; % MMC to Cereb
p.B{1}(4,2) = 0; % Thal to CTX
p.B{1}(5,2) = 0; % Thal to Cereb

p.B_s{1} = repmat(1/8,size(p.A_s{1})).*(p.B{1}==0);

p.B{2} =  repmat(-32,m.m,m.m);
p.B{2}(2,3) = 0; % Spin to Thal
p.B{2}(5,3) = 0; % Spin to Cereb
p.B_s{2} = repmat(1/8,size(p.A_s{2})).*(p.B{2}==0);


