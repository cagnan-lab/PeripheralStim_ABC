function plotSensorChoice(locs,indM1,SNR,MOD)
az =  236; el = -2.95;

clf
set(gcf,'Position',[ 267         550        1334         406])
roi = [37 -25 62; -37 25 62];
subplot(1,3,1)
scatter3(roi(1,1),roi(1,2),roi(1,3),500,'r'); % plots all electrodes
hold on
scatter3(locs(:,1),locs(:,2),locs(:,3),25,'b'); % plots all electrodes
hold on
scatter3(locs(indM1,1),locs(indM1,2),locs(indM1,3),25,'b','filled'); % plots electrodes close to M1
box off; grid off; axis off
view(az,el)
a = gca;
title('5cm threshold on ROI')

subplot(1,3,2)
b = gca;
b.XLim = a.XLim; b.YLim = a.YLim; b.ZLim = a.ZLim;
notset = setdiff(1:size(locs,1),indM1);
s (1) = scatter3(roi(2,1),roi(2,2),roi(2,3),500,'r'); % plots all electrodes
hold on
scatter3(locs(notset,1),locs(notset,2),locs(notset,3),'MarkerEdgeColor','k'); % plots all electrodes
s (2) = scatter3(locs(indM1,1),locs(indM1,2),locs(indM1,3),(1.25.^SNR)*100,'b'); % plots all M1 electrodes with SNR
SNRsel = SNR>-1;
s (3) = scatter3(locs(indM1(SNRsel),1),locs(indM1(SNRsel),2),locs(indM1(SNRsel),3),(1.25.^SNR(SNRsel))*100,'b','filled'); % plots all electrodes with SNR >1dB
L = legend(s,{'Motor CTX ROI','Candidates','Selection'},'Location','southoutside');
L.Orientation = 'horizontal';
L.NumColumns = 3;
L.Box = 'off';
L.Position = [ 0.3686    0.0336    0.2894    0.0517];
box off; grid off; axis off
view(az,el)
title('Threshold at -1 dB SNR (14-30 Hz)')

subplot(1,3,3)
b = gca;
b.XLim = a.XLim; b.YLim = a.YLim; b.ZLim = a.ZLim;
notset = setdiff(1:size(locs,1),indM1(SNRsel));
scatter3(roi(2,1),roi(2,2),roi(2,3),500,'r'); % plots all electrodes
hold on
scatter3(locs(notset,1),locs(notset,2),locs(notset,3),'MarkerEdgeColor','k'); % plots all electrodes
scatter3(locs(indM1(SNRsel),1),locs(indM1(SNRsel),2),locs(indM1(SNRsel),3),abs(MOD(indM1(SNRsel)))*5,'b'); % plots all electrodes with SNR >1dB
[~,MODsel] = max(abs(MOD(indM1(SNRsel))));
SNRsel = find(SNRsel);
scatter3(locs(indM1(SNRsel(MODsel)),1),locs(indM1(SNRsel(MODsel)),2),locs(indM1(SNRsel(MODsel)),3),abs(MOD(indM1(SNRsel(MODsel))))*5,'b','filled'); % plots all electrodes with SNR >1dB
box off; grid off; axis off
view(az,el)
title(' Maximum modulation/beta SNR')

