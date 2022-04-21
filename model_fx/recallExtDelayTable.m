function DExt = recallExtDelayTable(R,p,nmm)
%% Converts from fx order (in compile function) to whatever arbitrary node sequence is specified in the configuration
% Starts off with canonical table based upon order of list in fx functions
%     fx{1} = @ABC_fx_periphStim_Musc;                                    % Muscle
%     fx{2} = @ABC_fx_periphStim_SpinCrd;                                 % Spinal Cord
%     fx{3} = @ABC_fx_bgc_mmc; % Motor Cortex
%     fx{4} = @ABC_fx_bgc_thal;
%     fx{5} = @ABC_fx_bgc_cerebellum;

    Dv = repmat(4/1000,5); % set all delay priors to 4ms.
    
    % The indices are in same 
    Dv(1,3) = 15/1000;  % cord to MotorUnit (efferent)
    Dv(1,4) = 3/1000;   % Thal to M1 (Lumer, Edelman, Tononi; 1997)
    Dv(3,1) = 15/1000;   % spindle to cord (afferent)
    Dv(4,1) = 30/1000;  % spindle to Thal (afferent)
    Dv(4,3) = 8/1000;   % M1 to Thal (Lumer, Edelman, Tononi; 1997)
    Dv(2,3) = 30/1000;   % M1 to cord 
    Dv(5,1) = 30/1000;  % spindle to Cereb (afferent)
    
    DExt = zeros(numel(nmm));
    for i = 1:numel(nmm)
        for j = 1:numel(nmm)
            if i~=j
             DExt(j,i) = Dv2D(Dv(nmm(j),nmm(i)),R.IntP.dt,p.DExt(j,i));   
            end
        end
    end
    
    

function D = Dv2D(Dv,dt,p)
    D = ceil(Dv.*exp(p).*(1/dt)); % As expectation of priors and convert units to steps
    D(D<((1e-3)/dt)&D>0) = floor((1e-3)/dt); % Minimum 1ms
    