function D = recallDelayTable(R,p,nmm)
%% Converts from fx order (in compile function) to whatever arbitrary node sequence is specified in the configuration
% Starts off with canonical table based upon order of list in fx functions
%     fx{1} = @ABC_fx_periphStim_Musc;                                    % Muscle
%     fx{2} = @ABC_fx_periphStim_SpinCrd;                                 % Spinal Cord
%     fx{3} = @ABC_fx_bgc_mmc; % Motor Cortex
%     fx{4} = @ABC_fx_bgc_thal;
%     fx{5} = @ABC_fx_bgc_cerebellum;


    Dv = repmat(4/1000,5); % set all delay priors to 4ms.
    % The indices are in same
    Dv(1,1) = 0.001; % MU to MU is instantaneous
    Dv(2,1) = 15/1000; % MU to SC 50% stretch reflex latency
    Dv(3,1) = 30/1000; % MU to MMC
    Dv(4,1) = 30/1000; % MU to Thal.
    Dv(5,1) = 30/1000; % MU to Cereb
    Dv(1,2) = 15/1000; % SC to MU
    Dv(3,2) = 30/1000; % SC to MMC
    Dv(4,2) = 30/1000; % SC to Thal
    Dv(5,2) = 30/1000; % SC to Thal
    Dv(1,3) = 45/1000; % MMC to MU
    Dv(2,3) = 30/1000; % MMC to SC
    Dv(4,3) = 8/1000; % MMC to Thal (Lumer, Edelman, Tononi; 1997)
    Dv(5,3) = 5/1000; % MMC to Cereb (Baker; 2006)
    Dv(3,4) = 3/1000; % Thal to MMC (Lumer, Edelman, Tononi; 1997)
    Dv(5,4) = 3/1000; % Thal to Cereb
    Dv(2,5) = 30/1000; % Cereb to SC
    Dv(3,5) = 4/1000; % Cereb to MMC 
    
    %M1-->SC (EMG) is ~30 ms based on TMS-->leg muscle
    %emg-->cerebellum (spinocerebellar tract)
    %m1 to DCM  ~5 ms (see Baker 2006)
    %DCM to m1 4 ms (see Baker 2006)
    D = zeros(numel(nmm));
    for i = 1:numel(nmm)
        for j = 1:numel(nmm)
            if i~=j
            D(j,i) = Dv(nmm(j),nmm(i));   
            end
        end
    end
    

    D = ceil(D.*exp(p.D).*(1/R.IntP.dt)); % As expectation of priors and convert units to steps
    D(D<((1e-3)/R.IntP.dt)&D>0) = floor((2e-3)/R.IntP.dt); % Minimum 2ms
    