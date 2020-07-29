function [Xpar Xnpar] = keyUnivariateStats(X,nanopt)
if nargin<2
    nanopt = 0; % dont remove nans by default!
end

if nanopt == 1
    X(isnan(X)) = [];
    X(isinf(X)) = [];
end
Xpar = [mean(X) std(X) std(X)./sqrt(numel(X)) confInt95(X) numel(X)];
Xnpar = [median(X) iqr(X)]; 
    


