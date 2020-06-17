function [Xpar Xnpar] = keyUnivariateStats(X)

Xpar = [mean(X) std(X) std(X)./sqrt(numel(X)) confInt95(X) numel(X)];
Xnpar = [median(X) iqr(X)]; 
    


