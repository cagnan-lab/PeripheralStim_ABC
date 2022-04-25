function [intpow,peak,freq] = findSpectralStats(Hz,spec,band)
intpow = sum(spec(Hz>band(1) & Hz<band(2)));
[peak,id] = max(spec(Hz>band(1) & Hz<band(2)));
frang = Hz(Hz>band(1) & Hz<band(2));
freq = frang(id);