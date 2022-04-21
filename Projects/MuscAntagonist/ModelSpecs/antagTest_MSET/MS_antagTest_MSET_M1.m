function [R p m uc] = MS_antagTest_MSET_M1(R)
% FULL MODEL
[R,m] = getStateDetails(R);

% setup exogenous noise
% m.uset.p = DCM.Ep;
m.uset.p.covar = eye(m.m);
m.uset.p.scale = 1e-3; %.*R.InstP.dt;
uc = innovate_timeseries(R,m);

%% Prepare Priors
%%R.chsim_name = {'ctx','Thal','SpinAgo','MuscAgo','SpinAnt','MuscAnt'}; % simulated channel names (names must match between these two!)

% Primary connections
p.A{1} =  repmat(-32,m.m,m.m);
p.A{1}(3,1) = 0; % ctx -> SpinAgo
p.A{1}(5,1) = 0; % ctx -> SpinAnt
p.A{1}(2,1) = 0; % ctx -> Thal
p.A{1}(1,2) = 0; % Thal -> ctx
p.A{1}(4,3) = 0; % SpinAgo -> MuscAgo
p.A{1}(3,4) = 0; % MuscAgo -> SpinAgo
p.A{1}(6,5) = 0; % SpinAnt -> MuscAnt
p.A{1}(5,6) = 0; % MuscAnt -> SpinAnt

p.A_s{1} = repmat(0,m.m,m.m);
p.A_s{1}(find(p.A{1}==0)) = 1/2;

% Modulatory
p.B{1} =  repmat(-32,m.m,m.m);
p.B_s{1} = repmat(1/8,size(p.A_s{1})).*(p.B{1}==0);

% Secondary Connection
p.A{2} =  repmat(-32,m.m,m.m);
p.A{2}(5,4) = 0; % MuscAgo -> SpinAnt
p.A{2}(3,6) = 0; % MuscAnt -> SpinAgo
% p.A{2}(4,6) = 0; % MuscAnt -> MuscInt
% p.A{2}(6,4) = 0; % MuscInt -> MuscAnt

p.A_s{2} = repmat(0,m.m,m.m);

p.B{2} =  repmat(-32,m.m,m.m);
p.B_s{2} = repmat(1/8,size(p.A_s{2})).*(p.B{2}==0);

% Input strengths
p.C = zeros(m.m,1);
p.C_s = repmat(1,size(p.C));

% Leadfield
p.obs.LF = zeros(1,m.m);
p.obs.LF_s = repmat(2,size(p.obs.LF));

p.obs.Cnoise = zeros(1,m.m);
p.obs.Cnoise_s = repmat(1/2,size(p.obs.Cnoise));

p.obs.mixing = [1]; %zeros(size(R.obs.mixing));
p.obs.mixing_s = repmat(0,size(p.obs.mixing));

% Delays
p.D = repmat(-32,size(p.A{1})).*~((p.A{1}>-32) | (p.A{2}>-32)) ;
p.D_s = repmat(1/8,size(p.D));

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
end

