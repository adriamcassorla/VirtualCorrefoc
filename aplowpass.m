function y = aplowpass (x, Wc, crossFade,Fs)
% y = aplowpass (x, Wc)
%
%
% Original Author: M. Holters
% Modified by the student adding a ramp from 20.000Hz to the desired frequency.
%
% Applies a lowpass filter to the input signal x.
% Wc is the normalized cut-off frequency 0<Wc<1, i.e. 2*fc/fS.
%
% -> crossFade: Ramp time in samplers.
% -> Fs: Sampling frequency.
%
%--------------------------------------------------------------------------
% This source code is provided without any warranties as published in
% DAFX book 2nd edition, copyright Wiley & Sons 2011, available at
% http://www.dafx.de. It may be used for educational purposes and not
% for commercial applications without further permission.
%--------------------------------------------------------------------------

% Part added by the student
freqD = linspace(20000*2/Fs,Wc,crossFade); % Descending ramp to the Fc
freqA = linspace(Wc,20000*2/Fs,crossFade); % Ascending ramp from the Fc
centralFreq = ones(1,length(x)-crossFade*2) * Wc; % Fc
freqs = horzcat(freqD,centralFreq,freqA); % Frequency vector
% ----------

xh = 0;
for n=1:length(x)
% Applies the filter with different frequency each time
c = (tan(pi*freqs(n)/2)-1) / (tan(pi*freqs(n)/2)+1);
xh_new = x(n) - c*xh;
ap_y = c * xh_new + xh;
xh = xh_new;
y(n) = 0.5 * (x(n) + ap_y);  % change to minus for highpass
end;
