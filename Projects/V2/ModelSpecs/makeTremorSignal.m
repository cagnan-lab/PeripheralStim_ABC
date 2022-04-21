function [tx,px,ax] = makeTremorSignal(R,hz,wd)
fsamp = 1./R.IntP.dt;
% Create background beta oscillation
lorentzian = @(x,kx,gamma)((1/(pi*gamma))*((gamma^2)./((x-kx).^2 + (gamma^2))));
% x = 0:fsamp/N:fsamp/2;
x = 0:0.025:(fsamp); % support
kx = hz(1); % centre
gamma = wd(1); %FWHM
fx = lorentzian(x,kx,gamma) .*exp(1i.*rand(size(x)));

% And Gamma oscillations
lorentzian = @(x,kx,gamma)((1/(pi*gamma))*((gamma^2)./((x-kx).^2 + (gamma^2))));
% x = 0:fsamp/N:fsamp/2;
x = 0:0.025:(fsamp); % support
kx = hz(2); % centre
gamma = wd(2); %FWHM
fx = fx+ 2.*lorentzian(x,kx,gamma) .*exp(1i.*rand(size(x)));

% figure
% subplot(2,1,1)
% plot(x,abs(fx));
% xlim([0 98]);
% xlabel('Hz'); ylabel('Amplitude')

tx = ifft(fx);
tx = real(tx(fsamp+1:end-fsamp-1));

trncval(1) = size(R.IntP.tvec,2)-1;
trncval(2) = round(0.8.*size(tx,2));
tx = tx(trncval(2)-trncval(1):trncval(2));
tx = (tx-mean(tx))./std(tx);

px = wrapToPi(angle(hilbert(tx)));
ax = abs(hilbert(tx));

% subplot(2,1,2)
% plot(t,tx);
% xlabel('Time'); ylabel('Amplitude')
% xlim([5 6])
% a= 1;