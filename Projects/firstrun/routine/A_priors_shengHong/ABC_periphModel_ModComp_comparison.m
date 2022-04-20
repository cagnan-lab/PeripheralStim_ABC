function ABC_periphModel_ModComp_comparison(R,pSel,fresh)
close all
if fresh
R.comptype = 1;
 R.plot.flag = 1; 
modelCompMaster_160620(R,R.modcomp.modlist,[]);
end
R.modcomp.modN =  R.modcomp.modlist;
R.modcompplot.NPDsel = pSel;
R.plot.confint = 'yes';
R.plot.cmplx = 1;
cmap = linspecer(numel(R.modcomp.modN));
cmap = cmap(end:-1:1,:);
plotModComp_310520(R,cmap)
subplot(4,1,1); ylim([-0.5 0.3])
subplot(4,1,4); ylim([-0.1 4]);
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
