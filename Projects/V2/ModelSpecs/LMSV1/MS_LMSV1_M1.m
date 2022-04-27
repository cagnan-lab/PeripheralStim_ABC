function [R p m uc] = MS_LMSV1_M1(R)
%% â€œLesion Model Space V1â€? %%
% Model 1
if ~isfield(R,'modelSpecOpt')
    R.modelSpecOpt.fresh = 1;
end

[R,m] = getStateDetails(R);

% setup exogenous noise
% m.uset.p = DCM.Ep;
m.uset.p.covar = eye(m.m);
m.uset.p.scale = 1e-3; %.*R.InstP.dt;
uc = innovate_timeseries(R,m);

%% Prepare Priors
if R.modelSpecOpt.fresh
    % R.nmsim_name = {'SC','Thal','EP','MMC','CER'}; %modules (fx) to use.

    % Excitatory connections
    p.A{1} =  repmat(-32,m.m,m.m);
    p.A_s{1} = repmat(0,m.m,m.m);

    p.A{1}(3,1) = 0; % SC to EP
    p.A{1}(4,2) = 0; % THAL to MMC
    p.A{1}(1,3) = 0; % EP to SC (spinal reflex)
    p.A{1}(2,3) = 0; % EP to THAL
    p.A{1}(1,4) = 0; % MMC to SC
    p.A{1}(2,4) = 0; % MMC to THAL
    p.A{1}(5,4) = 0; % MMC to CER
    p.A{1}(2,5) = 0; % CER to THAL

    p.A_s{1}(find(p.A{1}==0)) = 1/2;
    % Lock the spinal reflex
    p.A_s{1}(3,1) = 1/32; % SC to EP
    p.A_s{1}(1,3) = 1/32; % EP to SC (spinal reflex)

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
    p.C([1 3]) = -32;
    p.C_s = repmat(1,size(p.C));
    p.C_s([1 3]) = 0;

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
        if i == 1 || i == 3
            prec = 1/32;
        else
            prec = 1/8;
        end
        p.int{i}.T = zeros(1,m.Tint(i));
        p.int{i}.T_s = repmat(prec,size(p.int{i}.T));
        p.int{i}.G = zeros(1,m.Gint(i));
        p.int{i}.G_s = repmat(prec,size(p.int{i}.G));
        p.int{i}.S = zeros(1,m.Sint(i));
        p.int{i}.S_s = repmat(prec,size(p.int{i}.S));
        %     p.int{i}.C = 0;
        %     p.int{i}.C_s = 1/4;
        %     p.int{i}.BT = zeros(1,m.Tint(i));
        %     p.int{i}.BT_s = repmat(prec,size(p.int{i}.T));
    end
else
    Rtmp = R;
    Rtmp.out.tag = 'periphModel_MSET1_v1'; % This tags the files for this particular instance
    Rtmp.out.dag = 'periphModel_MSET1_v1_M1'; % This tags the files for this particular instance
    Mfit = loadABCGeneric(Rtmp,'modelfit');
    p = Mfit.MAP;

    % Modulatory
    p.B{1} =  repmat(-32,m.m,m.m);
    p.B{1} = (~(p.A{1}>-32)).*-32;

    p.B_s{1} = repmat(1/2,size(p.A_s{1})).*(p.B{1}==0);

    p.B{2} =  repmat(-32,m.m,m.m);
    p.B_s{2} = repmat(1/2,size(p.A_s{2})).*(p.B{2}==0);

    p.BC = zeros(m.m,1);
    p.BC_s = repmat(1,size(p.C));

end

