function [p,h] = plotROCCurve(ROC,cmap)
for i = 1:size(ROC,2)
   p(i) = plot(ROC(i).Xsvm,ROC(i).Ysvm,'Color',cmap(i,:),'LineWidth',1.5);
   plist{i} = ['AUC = ' num2str(ROC(i).AUCsvm,2)]
   hold on
end
[h,icons] = legend(p,plist,'Location','East','Box','off','FontSize',8)
xlabel('1-specificity: FPR'); ylabel('Sensitivity: TPR')
axis([0 1 0 1])
grid on; box off; axis square