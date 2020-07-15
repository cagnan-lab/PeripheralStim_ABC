function [f] = ABC_fx_periphStim_Musc(x,ui,ue,P)
% state equations for a neural mass model of the motor endplate
%
% order           cells     states
% 1 = stn       - pyr       x(1,1:2)

% G(1,1) = gpe -> stn (-ve ext)

% [default] fixed parameters
%--------------------------------------------------------------------------
R    = P.Rz(2:end);              % gain of activation function (1st is extrinsic- so remove)
S = sigmoidin(x(1:2:end),R,0);
S = S';
% G  = [2]*200;   % synaptic connection strengths
% T  = [4];               % synaptic time constants [str,gpe,stn,gpi,tha];
% R  = 2/3;                       % slope of sigmoid activation function
% NB for more pronounced state dependent transfer functions use R  = 3/2;

% input
%==========================================================================
% Ui = ui;
% Ue = ue;
% time constants and intrinsic connections
%==========================================================================
T = P.T;

% intrinsic/extrinsic connections to be optimised
%--------------------------------------------------------------------------
G = P.G; % FOR SELF CONNECTIONS 

% Motion of states: f(x)
%--------------------------------------------------------------------------
% MEP:

% Motor Endplate
%--------------------------------------------------------------------------
u      =  ui;
% u      =  u; 
f(:,2) =  (u - 2*x(:,2) - x(:,1)./T(1,1))./T(1,1);

% Muscle Spindle
%--------------------------------------------------------------------------
u      =  0;
u      =  G(:,1)*S(:,1) + u;
f(:,4) =  (u - 2*x(:,4) - x(:,3)./T(1,2))./T(1,2);

% Voltage
%==========================================================================
f(:,1) = x(:,2);
f(:,3) = x(:,4);
f      = f'; %spm_vec(f);
