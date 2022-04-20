function [R p m uc] = MS_periphStim_BMOD_TremPrior_M1(R)
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
load('shenhong_TremPrior_withCerebV2','Pfit')
p = Pfit;
% Rescale precisions
for i = 1:m.m
    p.int{i}.T_s =  p.int{i}.T_s.*1.5;
    p.int{i}.G_s = p.int{i}.G_s.*1.5;
    p.int{i}.S_s = p.int{i}.S_s.*1.5;
end

% Modulatory
p.B{1} =  repmat(-32,m.m,m.m);
p.B_s{1} = repmat(1/4,size(p.A_s{1})).*(p.B{1}==0);

p.B{2} =  repmat(-32,m.m,m.m);
p.B_s{2} = repmat(1/4,size(p.A_s{2})).*(p.B{2}==0);

