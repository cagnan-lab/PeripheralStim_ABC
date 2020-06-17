function Zx = confInt95(X)
Z = 1.96; % Z value for 95% confidence ilevel

Zx = Z.*nanstd(X)./sqrt(sum(~isnan(X(:))))'; 