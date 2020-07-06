function ABC_periphModel_ModComp_comparison(R,fresh)
if fresh
R.comptype = 1;
 R.plot.flag = 1; 
modelCompMaster_160620(R,1:7,[]);
end
R.modcomp.modN = [1:7];
R.modcompplot.NPDsel = [7]; %[6 9 10];
R.plot.confint = 'yes';
R.plot.cmplx = 1;
cmap = linspecer(numel(R.modcomp.modN));
cmap = cmap(end:-1:1,:);
plotModComp_310520(R,cmap)

for i = 1:4
    for j = 1:4
        subplot(4,4,sub2ind([4 4],i,j))
        if i == j
            ylim([0 6])
        else
            ylim([-5 5])
        end
    end
end



figure(2)
subplot(3,1,1); ylim([-8 1])

% % Get sample Data
% uc = innovate_timeseries(R,m);
% uc{1} = uc{1}.*sqrt(R.IntP.dt);
% [~,~,feat_sim{1},~,xsim_ip{1}] = computeSimData(R,m,uc_ip{1},Pbase,0);
