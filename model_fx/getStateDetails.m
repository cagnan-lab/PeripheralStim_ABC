function [R,m] = getStateDetails(R)
m.m = numel(R.nmsim_name); % # of sources
for nm = 1:m.m
        m.dipfit.model(nm).source = R.nmsim_name{nm};

switch R.nmsim_name{nm}
    case 'SpinCrd'
        m.x{nm} = [0 0 0 0];
        m.Gint(nm) = 3;
        m.Tint(nm) = 2;
        m.Sint(nm) = 3;
        m.outstates{nm} = [1 0 0 0]; % AMN voltage
    case 'THAL'
        m.x{nm} = [0 0 0 0];
        m.Gint(nm) = 3;
        m.Tint(nm) = 2;
        m.Sint(nm) = 3;
        m.outstates{nm} = [0 0 1 0]; % relay cell voltage
    case 'Musc1'
        m.x{nm} = [0 0 0 0];
        m.Gint(nm) = 1;
        m.Tint(nm) = 2;
        m.Sint(nm) = 3;        
        m.outstates{nm} = [0 0 1 0]; % spindle stretch
    case 'MMC'
        m.x{nm} = [0 0 0 0 0 0 0 0];
        m.Gint(nm) = 14;
        m.Tint(nm) = 4;
        m.Sint(nm) = 5;        
        m.outstates{nm} = [0 0 1 0 0 0 0 0]; % Superficial layer voltage
    case 'Cereb'
        m.x{nm} = [0 0 0 0 0 0 0 0 0 0];
        m.Gint(nm) = 8;
        m.Tint(nm) = 5;
        m.Sint(nm) = 6;        
        m.outstates{nm} = [0 0 0 0 0 0 1 0]; % Purkinje cell voltage
        
end
end

R.obs.outstates = find([m.outstates{:}]);
for i=1:numel(R.chloc_name)
    R.obs.obsstates(i) = find(strcmp(R.chloc_name{i},R.chsim_name));
end
m.n =  size([m.x{:}],2); % Number of states

% Precompute xinds to make things easier with indexing
% Compute X inds (removes need to spm_unvec which is slow)
xinds = zeros(size(m.x,2),2);
for i = 1:size(m.x,2)
    if i == 1
        xinds(i,1) = 1;
        xinds(i,2) = size(m.x{i},2);
    else
        xinds(i,1) = xinds(i-1,2)+1;
        xinds(i,2) = xinds(i,1) + (size(m.x{i},2)-1);
    end
end
m.xinds = xinds;