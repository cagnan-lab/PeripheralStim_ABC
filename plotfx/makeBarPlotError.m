function makeBarPlotError(X,err,labs,cmap)

b = bar(1:size(X,1),X); hold on
for ib = 1:numel(b)
    b(ib).FaceColor = 'flat';
    b(ib).CData = repmat(cmap(ib,:),size(X,1),1);
end

if ~isempty(err)
    hold on
    for ib = 1:numel(b)
        e = errorbar(b(ib).XEndPoints,b(ib).YData,err(:,ib));
        e.LineStyle = 'none';
        e.LineWidth = 2;
        e.Color = cmap(ib,:).*0.75;
    end
    
end
if ~isempty(labs)
    a = gca;
    a.XTickLabel = labs;
    a.XTickLabelRotation = 45;
end
grid on
box off