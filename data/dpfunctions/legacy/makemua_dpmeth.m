function data_micro_temp =  makemua_dpmeth(data_micro_temp,fs)

sr_micro    = fs;                                   % Sampling frequency of LFP/EMG data
f_hpf       = 300;                                                  % high-pass frequency
f_band1     = 1; f_band2 = 250;                                     % low-pass frequency
filterOrder = 3;

[bhigh,ahigh]  = butter(filterOrder,2*f_hpf/sr_micro,'high');       % High pass filter at defined frequency
data_micro_temp = FiltFiltM(bhigh,ahigh,data_micro_temp);

data_micro_temp = abs(data_micro_temp);        % full-wave rectification

[bband,aband]  = butter(2,[f_band1 f_band2]/sr_micro);      % Band-pass filter at defined frequency
data_micro_temp = FiltFiltM(bband,aband,data_micro_temp);
