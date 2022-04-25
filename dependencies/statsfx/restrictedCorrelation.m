function [R,p,n,index] = restrictedCorrelation(X,Y,minR)
% This finds the restricted correlation using a minimum of minR sequential
% values. The Bonferonni corrected Spearmans R is returned, with the
% maximum selected. 
% Ensure row vector
if size(X,1)>size(X,2)
    X = X';
end
if size(Y,1)>size(Y,2)
    Y = Y';
end

for K = minR:size(X,2)
    [~,indRange] = slideWindow(X, K, K-1);
    indRange(:,any(indRange==0)) = [];
    indRangeStore{K} = indRange;
    for i = 1:size(indRange,2)
        [C,p] = corr([X(indRange(:,i))',Y(indRange(:,i))']);
        Rs(i,K) = C(1,2);
        P(i,K) = p(1,2);
    end
end

% alpha = 0.05/sum(P(:)>0); Bonferonni
% mask = P>0 & P<alpha;
% FDR
Pc = P;
Pc(Pc==0) = nan;
[mask,H] = fdr_bh(Pc,0.3,'pdep','yes');
Rs = Rs.*mask;
[R,ind] = max(abs(Rs(:))); % maximum correlation
[i,j] = ind2sub(size(Rs),ind);
n = j; % range of correlation
index = indRangeStore{j}(:,i); % indices of correlation
p = Pc(ind);