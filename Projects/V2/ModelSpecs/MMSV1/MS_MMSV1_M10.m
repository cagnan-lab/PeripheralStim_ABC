function [R p m uc] = MS_MMSV1_M10(R)
% Modulate Model Space V1 %
% Model 10 (DA CerT)
if ~isfield(R,'modelSpecOpt')
    R.modelSpecOpt.fresh = 1;
end

[R,m] = getStateDetails(R);

% setup exogenous noise
% m.uset.p = DCM.Ep;
m.uset.p.covar = eye(m.m);
m.uset.p.scale = 1e-3; %.*R.InstP.dt;
uc = innovate_timeseries(R,m);

Rtmp = R;
Rtmp.out.tag = 'periphModel_MSET1_v1'; % This tags the files for this particular instance
Rtmp.out.dag = 'periphModel_MSET1_v1_M1'; % This tags the files for this particular instance
Mfit = loadABCGeneric(Rtmp,'modelfit');
p = Mfit.MAP;

% Modulatory
p.B{1} =  repmat(-32,m.m,m.m);
p.B{1}(2,3) = 0; % EP to THAL
p.B{1}(2,5) = 0; % CER to THAL
p.B_s{1} = repmat(1/2,size(p.A_s{1})).*(p.B{1}==0);

p.B{2} =  repmat(-32,m.m,m.m);
p.B_s{2} = repmat(1/2,size(p.A_s{2})).*(p.B{2}==0);

p.BC = zeros(m.m,1);
p.BC = [-32 0 -32 0 0]; 
p.BC_s = repmat(1/2,size(p.BC)).*(p.BC==0);

