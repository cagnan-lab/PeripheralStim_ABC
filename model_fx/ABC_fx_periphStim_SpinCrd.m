function f = ABC_fx_periphStim_SpinCrd(x,ui,ue,P)
% state equations for a neural mass model of spinal cord circuit
%
% x      - state vector
%   x(:,1) - voltage     (alpha motor neurons)
%   x(:,2) - conductance (alpha motor neurons)
%   x(:,3) - voltage     (inhibitory interneurons)
%   x(:,4) - conductance (inhibitory interneurons)
%   x(:,5) - current     (gamma motor neurons)
%   x(:,6) - conductance (gamma motor neurons)


% Prior fixed parameter scaling [Defaults]
%
% E  = (forward, backward, lateral) extrinsic rates
% G  = intrinsic rates
% D  = propagation delays (intrinsic, extrinsic)
% T  = synaptic time constants
% S  = slope of sigmoid activation function
%
% Copyright (C) 2016 Wellcome Trust Centre for Neuroimaging


% pre-synaptic inputs: s(V)
%--------------------------------------------------------------------------
R    = P.Rz(2:end);              % gain of activation function (1st is extrinsic- so remove)
S = sigmoidin(x(1:2:end),R,0);
S = S';
% R    = (2/3);     %0.5.*                  % slope of sigmoid activation function
% B    = 0;                        % bias or background (sigmoid)
% R    = R.*exp(P.S);              % gain of activation function
% F    = 1./(1 + exp(-R*x + B));   % firing rate
% S    = F - 1/(1 + exp(B));       % deviation from baseline firing

% input
%==========================================================================
% Ui = ui;
% Ue = ue;
% time constants and intrinsic connections
%==========================================================================
% T    = ones(n,1)*T/1000;
% G    = ones(n,1)*G;
T = P.T;
G = P.G;

% extrinsic connections
%--------------------------------------------------------------------------
% forward  (i)   2  sp -> mp (+ve)
% forward  (ii)  1  sp -> dp (+ve)
% backward (i)   2  dp -> sp (-ve)
% backward (ii)  1  dp -> ii (-ve)
%--------------------------------------------------------------------------
% free parameters on time constants and intrinsic connections
%--------------------------------------------------------------------------
% G(:,1)  inhibitory input from interneuron
% G(:,2)  IIN self inhibition
% G(:,3)  AMN to IIN
%--------------------------------------------------------------------------
% Neuronal states (deviations from baseline firing)
%--------------------------------------------------------------------------
%   S(:,1) - voltage     (alpha motor neurons)
%   S(:,2) - conductance (alpha motor neurons)

%--------------------------------------------------------------------------

% Motion of states: f(x)
%--------------------------------------------------------------------------

% Conductance
%==========================================================================

% Alpha Motor Neuron
%--------------------------------------------------------------------------
u      =  ui + ue; %A{1}*S(:,3)+ ;
u      =  -G(:,1).*S(:,2) + u; % IIN to AMN + input
f(:,2) =  (u - 2*x(:,2) - x(:,1)./T(:,1))./T(:,1);

% Inhibitory Interneuron
%--------------------------------------------------------------------------
u      = ui;%
u      = -G(:,2).*S(:,2) + G(:,3).*S(:,1) + u; % Self inh + AMN to IIN + input
f(:,4) =  (u - 2*x(:,4) - x(:,3)./T(:,2))./T(:,2);

% Gamma Motor Neuron
%--------------------------------------------------------------------------

% Voltage
%==========================================================================
f(:,1) = x(:,2);
f(:,3) = x(:,4);
f = f';
% f      = spm_vec(f);

