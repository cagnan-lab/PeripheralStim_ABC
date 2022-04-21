function Dint = recallIntDelayTable(R,p,nmm)
%% Converts from fx order (in compile function) to whatever arbitrary node sequence is specified in the configuration
% Starts off with canonical table based upon order of list in fx functions
%     fx{1} = @ABC_fx_bgc_mmc;                                    % motor micro circuit
%     fx{2} = @ABC_fx_bgc_str;
%     fx{3} = @ABC_fx_bgc_gpe;
%     fx{4} = @ABC_fx_bgc_stn;
%     fx{5} = @ABC_fx_bgc_gpi;
%     fx{6} = @ABC_fx_bgc_thal;

for nm = nmm
    switch nm
        case 1 % MMC
               Dv = repmat(2,1,14); % set all delay priors to 4ms.
               Dv(1) = 1;
               Dv(2) = 2;
               Dv(3) = 2;
               Dv(4) = 2;
               Dv(5) = 2;
               Dv(6) = 2;
               Dv(7) = 2;
               Dv(8) = 2;
               Dv(9) = 2;
               Dv(10) = 2;
               Dv(11) = 2;
               Dv(12) = 2;
               Dv(13) = 2;
               Dv(14) = 2;
               Dv = Dv./1000; % convert to secs.
               Dint{nm} = Dv2D(Dv,R.IntP.dt,p.int{nm}.DInt);
    end
end
     
function D = Dv2D(Dv,dt,p)
    D = ceil(Dv.*exp(p).*(1/dt)); % As expectation of priors and convert units to steps
    D(D<((1e-3)/dt)&D>0) = floor((1e-3)/dt); % Minimum 1ms


% G(:,1)  mp -> mp (-ve self)  4
% G(:,2)  mp -> sp (+ve rec )  4
% G(:,3)  ii -> mp (-ve rec )  4
% G(:,4)  ii -> ii (-ve self)  4
% G(:,5)  mp -> ii (+ve rec )  4
% G(:,6)  dp -> ii (+ve rec )  2
% G(:,7)  sp -> sp (-ve self)  4
% G(:,8)  sp -> mp (+ve rec )  4
% G(:,9)  ii -> dp (-ve rec )  2 
% G(:,10) dp -> dp (-ve self)  1
% G(:,11) sp -> dp (+ve rec)  2
% G(:,12) ii -> sp (-ve rec)  4
% G(:,13) sp -> ii (+ve rec)  4
% G(:,14) dp -> sp (+ve rec)  2
%--------------------------------------------------------------------------
% Neuronal states (deviations from baseline firing)
%--------------------------------------------------------------------------
%   S(:,1) - voltage     (middle pyramidal cells)
%   S(:,2) - voltage     (superficial pyramidal cells)
%   S(:,3) - voltage     (inhibitory interneurons)
%   S(:,4) - voltage     (deep pyramidal cells)


    