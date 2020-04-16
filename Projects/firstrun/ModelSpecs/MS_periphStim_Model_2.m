function [R p m uc] = MS_periphStim_Model2(R)
% THIS IS THE STN/GPE
% stn only!
m.m = 4; % # of sources
m.x = {[0 0 0 0] [0 0 0 0 0 0 0 0] [0 0 0 0]  [0 0]}; % Initial states
m.Gint = [2 14 2 1];
m.Tint = [2 4 2 1];
m.Sint = [2 9 2 2];
m.n =  size([m.x{:}],2); % Number of states
% These outline the models to be used in compile function
for i = 1:numel(R.nmsim_name)
    m.dipfit.model(i).source = R.nmsim_name{i};
end
m.outstates = {[0 0 1 0] [0 0 1 0 0 0 0 0] [1 0 0 0]   [1 0]}; % SPINDLE TO MODEL ACC!
R.obs.outstates = find([m.outstates{:}]);
for i=1:numel(R.chloc_name)
    R.obs.obsstates(i) = find(strcmp(R.chloc_name{i},R.chsim_name));
end

% Precompute xinds to make things easier with indexing
% Compute X inds (removes need to spm_unvec which is slow)
xinds = zeros(size(m.x,2),2);
for i = 1:size(m.x,2)
    if i == 1
        xinds(i,1) = 1;
        xinds(i,2) = size(m.x{i},2);
    else
        xinds(i,1) = xinds(i-1,2)+1;
        xinds(i,2) = xinds(i,1) + (size(m.x{i},2)-1);
    end
end
m.xinds = xinds;

% setup exogenous noise
% m.uset.p = DCM.Ep;
m.uset.p.covar = eye(m.m);
m.uset.p.scale = 1e1; %.*R.InstP.dt;
uc = innovate_timeseries(R,m);

%% Prepare Priors
% R.nmsim_name = {'Musc1','MMC','SpinCrd','THAL'}; %modules (fx) to use.

% Excitatory connections
p.A{1} =  repmat(-32,m.m,m.m);
p.A_s{1} = repmat(0,m.m,m.m);


p.A{1}(3,1) = 0; % EP to SC
p.A{1}(3,2) = 0; % MMC to SC
p.A{1}(4,2) = 0; % MMC to Thal
p.A{1}(1,3) = 0; % SC to EP
p.A{1}(2,3) = 0; % SC to MMC
p.A{1}(4,3) = 0; % SC to Thal
p.A{1}(2,4) = 0; % Thal to CTX

p.A_s{1}(3,1) = 1/2; 
p.A_s{1}(3,2) = 1/2;
p.A_s{1}(4,2) = 1/2; 
p.A_s{1}(1,3) = 1/2;
p.A_s{1}(2,3) = 1/2; 
p.A_s{1}(4,3) = 1/2;
p.A_s{1}(2,4) = 1/2; 

% Modulatory
p.B{1} = p.A{1};
p.B_s{1} = repmat(1/2,size(p.A_s{1})).*(p.A_s{1}>0);



% Inhibtory
p.A{2} =  repmat(-32,m.m,m.m);
p.A_s{2} = repmat(0,m.m,m.m);

% Connection strengths
p.C = zeros(m.m,1);
p.C_s = repmat(1/8,size(p.C));

% Leadfield
p.obs.LF = [0 0];
p.obs.LF_s = repmat(2,size(p.obs.LF));

p.obs.Cnoise = [0 0 0 0];
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
%     p.int{i}.C = 0;
%     p.int{i}.C_s = 1/4;
    %     p.int{i}.BT = zeros(1,m.Tint(i));
    %     p.int{i}.BT_s = repmat(prec,size(p.int{i}.T));
end


% p.int{1}.T = [0.2784 -0.6034];
% p.int{1}.G = [1.3413 -0.7329];
% p.int{1}.S = [0.0566 0.5538];
% 
% p.int{2}.T = [0.8557 -0.5290];
% p.int{2}.G = [-0.1564 0.9265];
% p.int{2}.S = [0.5377 1.3622];

