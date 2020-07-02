function pQ = getModelPriors(m)
for i = 1:m.m
    switch m.dipfit.model(i).source
        case 'Musc1'
            % Muscle
            pQ(i).G  = [2]*200;   % synaptic connection strengths (coupling from unit to spindle (mechanical))
            pQ(i).T  = [12 12];       % synaptic time constants [motor unit,spindle]; (see: Rall 1957; McMahon 1984)
            pQ(i).S  = [0 0 0];     % 1st extrinsic; remainder intrinsic(s)
        case 'SpinCrd'
            % Spinal Cord
            pQ(i).G  = [2 2 2]*200;   % synaptic connection strengths; [IIN to AMN; AMN self inh; AMN to IIN];
            pQ(i).T  = [12 8];       % synaptic time constants [IIN; AMN];
            pQ(i).S  = [0 0 0];       % 1st extrinsic
        case 'MMC'
            % Motor Cortex
            pQ(i).G  = [2 4 2 2 2 2 2 2 2 2 4 2 2 2]*200;         % intrinsic connections
            pQ(i).T  = [3 2 12 18];                               % synaptic time constants [mp sp ii dp]
            pQ(i).S  = [0 0 0 0 0];     % 1st extrinsic; 2nd intrinsic(s)
        case 'THAL'
            % Thalamus
            pQ(i).G  = [2 2 2]*200;   % synaptic connection strengths [RET self; Rel to RET; RET to REL
            pQ(i).T  = [8 12];               % synaptic time constants [RET,REL];
            pQ(i).S  = [0 0 0];     % 1st extrinsic; 2nd intrinsic(s)   
        case 'Cereb'
            % Cerebellum
            pQ(i).G  = [2 2 2 2 2 2 2 2]*200;   % synaptic connection strengths
            pQ(i).T  = [8 8 8 8 12];               % synaptic time constants;
            pQ(i).S  = [0 0 0 0 0];     % 1st extrinsic; 2nd intrinsic(s)   
            
    end
    % Convert to seconds
    pQ(i).T = pQ(i).T./1000;
end
