function [b,e] = makeBarPlotError(X,err,labs,cmap)
if size(X,1)>1
    b = bar(1:size(X,1),X); hold on
    for ib = 1:size(X,2)
        b(ib).FaceColor = 'flat';
        b(ib).CData = repmat(cmap(ib,:),size(X,1),1);
    end
else
    b = bar(X);
    for g = 1:size(X,2)
        b(1).FaceColor = 'flat';
        b(1).CData(g,:) = cmap(g,:);
    end
end


if ~isempty(err)
    hold on
    if numel(b) > 1
        for ib = 1:numel(b)
            e = errorbar(b(ib).XData+ b(ib).XOffset,b(ib).YData,err(:,ib));
            e.Color = cmap(ib,:).*0.75;
                e.LineStyle = 'none';
    e.LineWidth = 2;

        end
    else
        e = errorbar(1:numel(X),X,err);
        e.Color = [0.2 0.2 0.2];
            e.LineStyle = 'none';
    e.LineWidth = 2;

    end
end
if ~isempty(labs)
    a = gca;
    a.XTick = 1:numel(labs);
    a.XTickLabel = labs;
    a.XTickLabelRotation = 45;
end
grid on;
box off