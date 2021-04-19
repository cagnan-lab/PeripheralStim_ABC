function [R p m uc] = MS_periphStim_BMOD_TremPrior_M5(R)
% FULL MODEL with Cerebellum
% Thalamocerebellar
[R,m] = getStateDetails(R);

% setup exogenous noise
% m.uset.p = DCM.Ep;
m.uset.p.covar = eye(m.m);
m.uset.p.scale = 1e-3; %.*R.InstP.dt;
uc = innovate_timeseries(R,m);

%% Prepare Priors
% R.nmsim_name = {'SpinCrd','THAL','Musc1','MMC'}; %modules (fx) to use.
load('shenhong_TremPrior_withCerebV2','Pfit')
p = Pfit;

% Modulatory
p.B{1} =  repmat(-32,m.m,m.m);
p.B{1}(5,2) = 0; % Thal to Cereb
p.B_s{1} = repmat(1/8,size(p.A_s{1})).*(p.B{1}==0);

p.B{2} =  repmat(-32,m.m,m.m);
p.B_s{2} = repmat(1/8,size(p.A_s{2})).*(p.B{2}==0);

