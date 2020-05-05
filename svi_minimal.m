function svi_minimal()

% Generate synthetic dataset and note corresponding likelihood
randn('state', 0);
rand('state', 0);
D = 3;
ww = 5*randn(D, 1);
N = 20;
X = [randn(N, D-1), ones(N, 1)];
yy = rand(N, 1) < (1./(1 + exp(-X*ww)));
neg_log_like_grad = @(w) logreg_negLlike(w, X, yy);

% If you rerun the fitting with different seeds you'll see we don't
% get quite the same answer each time. I'd need to set the learning rate
% schedule better, and/or run for longer, to get better convergence.
randn('state', 2);
rand('state', 2);

% Simple stochastic steepest descent with decreasing learning rate.
% Here each update includes the whole dataset because the dataset is
% tiny. However, we still have stochastic updates, as each update
% uses a different random weight drawn from the current variational
% approximation to the posterior.
Lsigma_w = log(10); % Initialize prior width broader than it actually was. (We'll learn to fix that.)
mm = zeros(D, 1);
LL = zeros(D);
LL(1:(D+1):end) = Lsigma_w;
eta0 = 0.1;
tau = 0.1;
for ii = 1:10000
    eta = eta0/(1 + tau*eta0*ii);
    [J, mm_bar, LL_bar, Lsigma_w_bar] = svi_grad(mm, LL, Lsigma_w, neg_log_like_grad);
    mm = mm - eta*mm_bar;
    LL = LL - eta*LL_bar;
    Lsigma_w = Lsigma_w - eta*Lsigma_w_bar;
end

% Extract covariance of the variational posterior from its
% unconstrained parameterization.
L = LL;
L(1:(D+1):end) = exp(LL(1:(D+1):end));
V = L*L';

% Plot data:
clf; hold on;
plot(X(yy==1, 1), X(yy==1, 2), 'bx');
plot(X(yy==0, 1), X(yy==0, 2), 'ro');
legend({'y=1', 'y=0'});

% Overlay contour plot of approximate predictive distribution:
x_grid = -3:0.05:3;
[X1, X2] = meshgrid(x_grid, x_grid);
X_test = [X1(:), X2(:) ones(numel(X1),1)];
kappa = 1 ./ sqrt(1 + (pi/8)*sum((X_test*V).*X_test, 2));
p_test = 1./(1+exp(-(X_test*mm).*kappa));
P = reshape(p_test, size(X1));
[C, hh] = contour(X1, X2, P, [0.1,0.25,0.5,0.75,0.9]);
clabel(C, hh, 'LabelSpacing', 2000);
xlabel('x_1');
ylabel('x_2');
title('Contours of p(y=1|x,D)');


function [negLlike, ww_bar] = logreg_negLlike(ww, X, yy)
%LOGREG_NEGLLIKE negative log-likelihood and gradients of logistic regression
%
%     [negLlike, ww_bar] = logreg_negLlike(ww, X, yy)
%
% There's no separate bias term. So X needs augmenting with a constant column to
% include a bias.
%
% Inputs:
%          ww Dx1 
%           X NxD 
%          yy Nx1 
%
% Outputs:
%    negLlike 1x1 
%      ww_bar Dx1 

% Iain Murray, November 2016

% Force targets to be +/- 1
yy = 2*(yy==1) - 1;

% forward computation of error
sigma = 1./(1 + exp(-yy.*(X*ww)));
negLlike = -sum(log(sigma));

% reverse computation of gradients
ww_bar = X'*(yy.*(sigma - 1));


function [J, mm_bar, LL_bar, Lsigma_w_bar] = svi_grad(mm, LL, Lsigma_w, neg_log_like_grad)
%SVI_GRAD cost function and gradients for black-box stochastic variational inference
%
%     [J, mm_bar, LL_bar, Lsigma_w_bar] = svi_grad(mm, LL, Lsigma_w, neg_log_like_grad)
%
% Inputs:
%                    mm Dx1 mean of variational posterior
%                    LL DxD lower-triangular Cholesky decomposition of
%                           variational posterior, with diagonal log-transformed
%              Lsigma_w 1x1 log of prior standard deviation over weights
%     neg_log_like_grad @fn -ve log-likelihood of model and gradients wrt weights
%                           Could be an unbiased estimate based on a mini-batch,
%                           we only get unbiased estimates of cost and gradients anyway.
%
% Outputs:
%                     J 1x1 estimate of variational cost function = -ELBO
%                mm_bar Dx1 with derivatives wrt mm, ...
%                LL_bar DxD ...LL, ...
%          Lsigma_w_bar 1x1 ...and Lsigma_w

% Iain Murray, November 2016

% Unpack Cholesky factor of posterior covariance and prior variance
% from their unconstrained forms.
D = numel(mm);
L = tril(LL); L(1:(D+1):end) = exp(LL(1:(D+1):end));
sigma2_w = exp(2*Lsigma_w);

% The estimate of the variational cost function
J1 = -0.5*D - sum(diag(LL)); % - D/2*log(2*pi)
tmp = (L(:)'*L(:) + mm'*mm)/sigma2_w;
J2 = tmp/2 + D*Lsigma_w;   % + D/2*log(2*pi)
nu = randn(D, 1);
ww = mm + L*nu; % Using random weight
[J3, ww_bar] = neg_log_like_grad(ww);
J = J1 + J2 + J3;

% The derivatives
mm_bar = mm/sigma2_w + ww_bar;
L_bar = L/sigma2_w + tril(ww_bar*nu');
LL_bar = L_bar;
LL_bar(1:(D+1):end) = L_bar(1:(D+1):end) .* L(1:(D+1):end) - 1;
Lsigma_w_bar = D - tmp;

