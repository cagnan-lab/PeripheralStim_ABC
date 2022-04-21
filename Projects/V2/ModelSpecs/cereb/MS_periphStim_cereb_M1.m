function [R p m uc] = MS_periphStim_cereb_M1(R)
% FULL MODEL
[R,m] = getStateDetails(R);

% setup exogenous noise
% m.uset.p = DCM.Ep;
m.uset.p.covar = eye(m.m);
m.uset.p.scale = 1e-3; %.*R.InstP.dt;
uc = innovate_timeseries(R,m);

%% Prepare Priors
% R.nmsim_name = {'SpinCrd','THAL','Musc1','MMC'}; %modules (fx) to use.

% Excitatory connections
p.A{1} =  repmat(-32,m.m,m.m);
p.A_s{1} = repmat(0,m.m,m.m);

% Modulatory
p.B{1} =  repmat(-32,m.m,m.m);
p.B_s{1} = repmat(0,m.m,m.m);

% Inhibtory
p.A{2} =  repmat(-32,m.m,m.m);
p.A_s{2} = repmat(0,m.m,m.m);

p.B{2} =  repmat(-32,m.m,m.m);
p.B_s{2} = repmat(0,m.m,m.m);

% Input strengths
p.C = zeros(m.m,1);
p.C_s = repmat(1,size(p.C));

% Leadfield
p.obs.LF = [0];
p.obs.LF_s = repmat(2,size(p.obs.LF));

p.obs.Cnoise = [0];
p.obs.Cnoise_s = repmat(1/2,size(p.obs.Cnoise));

p.obs.mixing = [1]; %zeros(size(R.obs.mixing));
p.obs.mixing_s = repmat(0,size(p.obs.mixing));

% Delays
p.DExt = repmat(-32,size(p.A{1})).*~((p.A{1}>-32) | (p.A{2}>-32)) ;
p.DExt_s = repmat(0,size(p.DExt));

% Sigmoid transfer for connections
% p.S = [0 0];
% p.S_s = [1/8 1/8];
% time constants and gains
for i = 1:m.m
    prec = 1/4;
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

