% Load the audio signal
[x, Fs] = audioread('speech_27.wav');

% Plot to find out which frequency to remove from signal
nfft = 2^10;
X = fft(x, nfft);
fstep = Fs/nfft;
fvec = fstep*(0: nfft/2-1);
fresp = 2*abs(X(1:nfft/2));
plot(fvec,fresp)
title('Single-Sided Amplitude Spectrum of x(t)')
xlabel('Frequency (Hz)')
ylabel('|X(f)|')

% Create the filter
Hd = filter;

% Apply the filter to the audio signal
filtered_signal = filter(Hd, x);

sound(x,Fs)
pause(10)
% Listen to the filtered signal
sound(filtered_signal, Fs);

% Save the filtered signal to a new file
audiowrite('filtered_speech_27.wav', filtered_signal, Fs);

% Perform FFT on the filtered signal to check if the noise is removed
nfft = 2^10;
X_filtered = fft(filtered_signal, nfft);
fstep = Fs/nfft;
fvec = fstep*(0:nfft/2-1);
fresp_filtered = 2*abs(X_filtered(1:nfft/2));

% Plot the filtered signal's frequency spectrum
figure;
plot(fvec, fresp_filtered);
title('Single-Sided Amplitude Spectrum of Filtered Signal');
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
