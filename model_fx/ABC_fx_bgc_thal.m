function f = ABC_fx_bgc_thal(x,ui,ue,P)
% state equations for a neural mass model of the basal ganglia circuit
% models the circuit between striatum, gpe, stn, gpi, and thalamus as a
% single source (no extrinsic connections)
%
% order           cells     states
% 1 = thalamus  - pyr       x(1,1:4)

% G(1,9) = RET Self -ve
% G(2,9) = REL -> RET +ve
% G(3,9) = RET -> REL -ve

% pre-synaptic inputs: s(V)
%--------------------------------------------------------------------------
R    = P.Rz(2:end);              % gain of activation function (1st is extrinsic- so remove)
S = sigmoidin(x(1:2:end),R,0);
S = S';

% R    = R.*exp(P.S);              % gain of activation function
% F    = 1./(1 + exp(-R*x + 0));   % firing rate
% S    = F - 1/(1 + exp(0));       % deviation from baseline firing (0)

% input
%==========================================================================
% U = u;

% time constants and intrinsic connections
T = P.T;

% intrinsic/extrinsic connections to be optimised
%--------------------------------------------------------------------------
G = P.G;

% Motion of states: f(x)
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1 - Thalamus: inhibitory reticular cells - recieve input
%--------------------------------------------------------------------------
u      =  ue + ui(2); 
u      =  -G(:,1)*S(:,1) + G(:,2)*S(:,2) +  u; % Self inh + Rel + noise
f(:,2) =  (u - 2*x(:,2) - x(:,1)./T(1,1))./T(1,1);

% 2 - Thalamus: excitatory relay cells - send output
%--------------------------------------------------------------------------
u      =  ui(1); 
u      =  -G(:,3)*S(:,1) + u; % RET inh + endogenous input
f(:,4) =  (u - 2*x(:,4) - x(:,3)./T(1,2))./T(1,2);


% Voltage
%==========================================================================
f(:,1) = x(:,2);
f(:,3) = x(:,4);
f      = f'; %spm_vec(f);
