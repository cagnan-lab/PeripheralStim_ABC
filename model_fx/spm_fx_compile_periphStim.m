function [xstore_cond,tvec,wflag,J,Es] = spm_fx_compile_periphStim(R,x,uc,pc,m)
% If you want to estimate the noise floor - then use 'decon' to deconnect
% both intrinsic/extrinsic couplings.
if isfield(R.IntP,'getNoise') && R.IntP.getNoise == 1
    decon = 0;
else
    decon = 1;
end

cs = 0; % cond counter
wflag= 0; tvec = [];
for condsel = 1:numel(R.condnames)
    cs = cs+1;
    us = uc{cs};
    p = pc;
    % Compiles NMM functions with delays, seperates intrinsic and extrinsic
    % dynamics then summates
    xinds = m.xinds;
    % model-specific parameters
    %==========================================================================
    % model or node-specific state equations of motions
    %--------------------------------------------------------------------------
    fx{1} = @ABC_fx_periphStim_Musc;                                    % Muscle
    fx{2} = @ABC_fx_periphStim_SpinCrd;                                 % Spinal Cord
    fx{3} = @ABC_fx_bgc_mmc; % Motor Cortex
    fx{4} = @ABC_fx_bgc_thal;
    fx{5} = @ABC_fx_bgc_cerebellum;
    
    % indices of extrinsically coupled hidden states
    %--------------------------------------------------------------------------
    efferent(1,:) = [3 3 3 3];               % sources of Musc connections (spindle voltage)
    efferent(2,:) = [1 1 1 1];               % sources of spinCord connections
    efferent(3,:) = [3 3 6 7];               % ORIG sources of MMC connections
    efferent(4,:) = [3 3 3 3];               % sources of THAL connections
    efferent(5,:) = [9 9 9 9];               % sources of Cereb connections
    
    % scaling of afferent extrinsic connectivity (Hz)
    %--------------------------------------------------------------------------
    E(1,:) = [.4 .4 -.4 -.4]*2000;             % Muscle connections
    E(2,:) = [.6 .6 -.6 -.6]*2000;             % spinCord connections
    E(3,:) = [.2 .2 -.2 -.2]*8000;            % MMC connections
    E(4,:) = [.2 .2 -.2 -.2]*2000;  %500       % THAL connections    
    E(5,:) = [.2 .2 -.2 -.2]*2000;  %500       % Cereb connections    
    
    % get the neural mass models {'ERP','CMC'}
    %--------------------------------------------------------------------------
    n     = m.m;
    model = m.dipfit.model;
    for i = 1:n
        if  strcmp(model(i).source,'Musc1')
            nmm(i) = 1;
        elseif strcmp(model(i).source,'SpinCrd')
            nmm(i) = 2;
        elseif strcmp(model(i).source,'MMC')
            nmm(i) = 3;
        elseif strcmp(model(i).source,'THAL')
            nmm(i) = 4;
        elseif strcmp(model(i).source,'Cereb')
            nmm(i) = 5;
        end
    end
    
    %% Pre-integration extrinsic connection parameters
    % Compute value of delays from lognormal mean
    DExt = recallExtDelayTable(R,p,nmm);
    
    if (R.IntP.bufferExt-max(max(DExt)))<=0
        R.IntP.bufferExt = max(max(DExt)) + 2;
        disp(['Delay is bigger than buffer, increasing buffer to: ' num2str(R.IntP.bufferExt)])
    end
    if R.IntP.bufferExt > 1e3
        disp('Delays are implausibly large!')
        wflag = 1;
        break
    end
    
    Ds = zeros(size(DExt));
    % Now find indices of inputs
    % Currently no seperation between inh and excitatory
    for i = 1:length(nmm) % target
        for j = 1:length(DExt(i,:)) % source
            if DExt(i,j)>0
                Ds(i,j) = efferent(nmm(j),1); % input sources
                Ds(i,j) = (m.xinds(j,1)-1)+Ds(i,j);
            end
        end
    end
       
    % Condition Dependent Modulation of Synaptic gains
    %-----------------------------------------
    for i = 1:m.m
        if cs ~= R.Bcond
            p.int{i}.T = p.int{i}.T;
        else
            p.int{i}.T = p.int{i}.T;% + p.int{i}.BT;
        end
    end
    
    % Rescale background Input
    for i = 1:m.m
        C    = exp(p.C(i));
        us(:,i) = C*us(:,i); %*0.01;
    end
    
    % Extrinsic connections
    %--------------------------------------------------------------------------
    %
    % alist = [1 2; 3 4];
    alist = [1; 3]; A = [];
    for i = 1:numel(p.A)
        if cs ~= R.Bcond
            A{i} = decon*exp(p.A{i});
        else
            A{i} = decon*(exp(p.A{i})+ exp(p.B{i})); % Add the second condition
        end
        %     A{alist(i,2)} = exp(p.A{i});
    end
        
    % and scale of extrinsic connectivity (Hz)
    %--------------------------------------------------------------------------
    for j = 1:n
        for i = 1:n
            for k = 1:numel(p.A)
                A{k}(i,j) = E(nmm(i),alist(k,1))*A{k}(i,j);
            end
        end
    end
    
    % synaptic activation function priors
    %--------------------------------------------------------------------------
    Rz_base     = 2/3;                      % gain of sigmoid activation function   
    B = 0;
    %% Precompute parameter expectations
    % Parameter Priors
    pQ = getModelPriors(m);
    
    nbank = cell(1,n); qbank = cell(1,n);
    for i = 1:n
        N.x  = m.x{i};
        nbank{i} = N;
        Q = p.int{i};
        Q.T = pQ(i).T.*exp(Q.T);
        Q.G = decon*pQ(i).G.*exp(Q.G);
        Q.Rz = Rz_base.*exp(Q.S);
        Rz(i) = Q.Rz(1);
        qbank{i} = Q;
    end
    
    %% TIME INTEGRATION STARTS HERE ===========================================
    f = zeros(xinds(end),1); dt = R.IntP.dt;
    if iscell(x)
        xstore= full(repmat(spm_vec(x),1,R.IntP.bufferExt));
    else
        xstore = x;
    end
    
    xint = zeros(m.n,1);
    TOL = exp(-4);
    for tstep = R.IntP.bufferExt:R.IntP.nt
        % assemble flow
        %==========================================================================
        N     = m;
        for i = 1:n % targets
            fA = [];
            % extrinsic flow
            %----------------------------------------------------------------------
            for j = 1:n % sources
                for k = 1:numel(p.A) % connection type
                    if abs(A{k}(i,j)) > TOL
                        xD = xstore(Ds(i,j),tstep-DExt(i,j));
                        fA = [fA  A{k}(i,j)*sigmoidin(xD,Rz(j),B)]; % 1st Rz is slope!
                    end
                end
            end
            % intrinsic flow at target
            %----------------------------------------------------------------------
            ue   = us(tstep,i); % exogenous input (noise or structured inputs)
            ui = sum(fA); % within model connectivity
            xi = xstore(m.xinds(i,1):m.xinds(i,2),tstep)';
            f(m.xinds(i,1):m.xinds(i,2)) = fx{nmm(i)}(xi,ui,ue,qbank{i});
            %             f(Dt(1,i))  = f(Dt(1,i)) + sum(fA) ;
        end
        xint = xint + (f.*dt);
        xstore = [xstore xint]; % This is done for speed reasons! Faster than indexing (!!)

        if tstep >R.IntP.bufferExt*10
            if any(xint>1e4) || any(isnan(xint))
                wflag= 1;
                break
            end
        end
    end
    
    
    if wflag == 1
        xstore_cond{condsel} = NaN;
    end
    xstore_cond{condsel} = xstore;
    
    
    if nargout>3
        [J{condsel},Es{condsel}] = findJacobian(R,xstore(:,end-R.IntP.bufferExt:end),uc,p,m);
    end 
end

