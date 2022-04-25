function plotBurstConstruction(fsamp,dataC,dataX,XH,burstinds)

% plot data% Run inside constructGenCrossMatrix
a(1) = subplot(5,1,1)
XC = dataC;
tvec = linspace(0,size(XC,1)/fsamp,size(XC,1));

plot(tvec,XC,'b')

a(2) = subplot(5,1,2)
plot(tvec,dataX,'b')

a(3) = subplot(5,1,3)
plot(tvec,XH,'b')
ylim([0 4])

a(4) = subplot(5,1,4)
plot(tvec,XH,'k--'); hold on
plot([0 tvec(end)],[eps eps],'r--')

XY = nan(size(XH));
XY([burstinds{:}]) = XH([burstinds{:}])

plot(tvec,XY,'b'); hold on
ylim([0 6])
linkaxes(a,'x')
xlim([5 7])

subplot(5,1,5)
plot(tvec,XY,'b'); hold on
ylim([0 4])
linkaxes(a,'x')
xlim([5 7])