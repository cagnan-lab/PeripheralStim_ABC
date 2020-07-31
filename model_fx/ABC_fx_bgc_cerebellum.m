function f = ABC_fx_bgc_cerebellum(x,ui,ue,P)
% state equations for a neural mass model of motor cortex
% Bhatt et al. 2016 Neuroimage
%
% FORMAT [f,J,D] = spm_fx_mmc(x,u,P,M)
% FORMAT [f,J]   = spm_fx_mmc(x,u,P,M)
% FORMAT [f]     = spm_fx_mmc(x,u,P,M)
% x      - state vector
%   x(:,1) - voltage     (deep cerebellar nuclei cells)
%   x(:,2) - conductance (deep cerebellar nuclei cells)
%   x(:,3) - voltage     (pontine nuclei cells)
%   x(:,4) - conductance (pontine nuclei cells)
%   x(:,5) - voltage     (inferior olive cells)
%   x(:,6) - conductance (inferior olive cells)
%   x(:,7) - voltage     (granule cells)
%   x(:,8) - conductance (granule cells)
%   x(:,9) - voltage     (granule cells)
%   x(:,10) - conductance (granule cells)
%
% f        - dx(t)/dt  = f(x(t))
%
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

% input
%==========================================================================
%  U = u;
% time constants and intrinsic connections
%==========================================================================
T = P.T;
G = P.G;
%--------------------------------------------------------------------------
% free parameters on time constants and intrinsic connections
%--------------------------------------------------------------------------
% G(:,1)  pn -> dcn
% G(:,2)  io -> dcn
% G(:,3)  pc -| dcn
% G(:,4)  gc -| gc (self inh golgi cells)
% G(:,5)  pn -> grc 
% G(:,6)  pc -| pc 
% G(:,7)  IO -> pc 
% G(:,8)  gc -> pc 

%--------------------------------------------------------------------------
% Neuronal states (deviations from baseline firing)
%--------------------------------------------------------------------------
%   S(:,1) - voltage     (deep cerebellar nuclei cells)
%   S(:,2) - voltage     (pontine nuclei cells)
%   S(:,3) - voltage     (inferior olive cells)
%   S(:,4) - voltage     (granule cells)
%   S(:,5) - voltage     (Purkinje cells)
%--------------------------------------------------------------------------
 
% Motion of states: f(x)
%--------------------------------------------------------------------------
 
% Conductance
%==========================================================================
 
% Deep Cerebellar Nuclei
%--------------------------------------------------------------------------
u      =  0;
u      =  G(:,1).*S(:,2) + G(:,2).*S(:,3) - G(:,3).*S(:,5) + u;
f(:,2) =  (u - 2*x(:,2) - x(:,1)./T(:,1))./T(:,1);
 
% Pontine Nuclei
%--------------------------------------------------------------------------
u      = ui(1); % Receives input 1 
f(:,4) =  (u - 2*x(:,4) - x(:,3)./T(:,2))./T(:,2);
 
% Inferior Olive
%--------------------------------------------------------------------------
u      = ui(1)+ue(1);%
f(:,6) =  (u - 2*x(:,6) - x(:,5)./T(:,3))./T(:,3);
 
% Granule Cell
%--------------------------------------------------------------------------
u      =  0;%
u      = - G(:,4).*S(:,4) + G(:,5).*S(:,2) + u;
f(:,8) =  (u - 2*x(:,8) - x(:,7)./T(:,4))./T(:,4);

% Purkinje cell
%--------------------------------------------------------------------------
u      =  0;%
u      =  - G(:,6).*S(:,5) + G(:,7).*S(:,3) + G(:,8).*S(:,4) + u; 
f(:,10) =  (u - 2*x(:,10) - x(:,9)./T(:,5))./T(:,5);

% Voltage
%==========================================================================
f(:,1) = x(:,2);
f(:,3) = x(:,4);
f(:,5) = x(:,6);
f(:,7) = x(:,8);
f = f';
% f      = spm_vec(f);
 
