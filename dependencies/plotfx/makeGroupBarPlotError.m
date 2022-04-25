function [B,E] = makeGroupBarPlotError(Y,err,cmap)

B = bar(Y);
hold on
x = [];
for i = 1:numel(B)
    x(i,:) = B(i).XEndPoints;
    B(i).FaceColor = cmap(i,:);
end

E = errorbar(x,Y',err');
for i = 1:numel(E)
    E(i).LineStyle = 'none';
    E(i).Color = 'k';
    E(i).LineWidth = 1;
    E(i).CapSize = 0;
end


