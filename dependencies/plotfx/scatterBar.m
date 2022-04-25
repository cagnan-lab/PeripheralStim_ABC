function [B,S,E] = scatterBar(X,LABEL,cmap)
for j = unique(LABEL)'
    if any(isnan(X(LABEL==j)));
        warning('X in bar chart contains nans! Using nanmedian!')
    end
    Xbar(j) = nanmedian(X(LABEL==j));
    Sx(j) = nanstd(X(LABEL==j))./sqrt(numel(X(LABEL==j)));
end

B = bar(Xbar);
B.FaceColor = 'flat';
for j = 1:numel(B.XData)
    B.CData(j,:) = cmap(j,:);
    B.FaceAlpha = 0.4;
end

hold on

for j = unique(LABEL)'
    Xsamp = X(LABEL==j);
    jitter = 0.075.*randn(size(Xsamp));
    S(j) = scatter(B.XData(j) + jitter, Xsamp, 'filled');
    S(j).MarkerFaceAlpha = 0.8;
    S(j).MarkerFaceColor =  cmap(j,:);
end

hold on
E = errorbar(B.XData,B.YData,Sx);
E.LineStyle = 'none';
E.LineWidth = 1.25;
E.Color = 'k';