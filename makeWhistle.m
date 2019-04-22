function [whistle] = makeWhistle(duration,Fs)
% makeWhistle Creates the whistle of a firework.
% Creates a descending sweep using additive synthesis.
% Function based on LAB3 additive synthesis exercice
%
% -> duration: the length of the whistle in samplers.
% -> Fs: Sampling rate.
%
% <- whistle: The resulting whistle.

    preBlank = zeros(1,randi(2*Fs)); % Adds some time before the whistle starts.
    rampDur = randi(3)/10; % Set the duration of the final ramp in seconds.
    whistleDur = floor(((duration-length(preBlank))/Fs)-rampDur); % Sets the length of the descending whistle.
    
    startFreq = randi(300)+2000; % Starting frequency.
    endFreq = randi(100)+950; % End frequency.
    rampOffset = randi(100)+150; % Frequency that the final ramp ups.
    
    % Create the time vectors for the whistle and the ramp.
    whistleTime = 0:1/Fs:whistleDur;
    rampTime = 0:1/Fs:rampDur;
    
    bAmps = [0,15,0,13,0,4,0,2,0]; % Stores the amplitudes for each harmonic of the first part
    Amps = [2,15,2,12,2,3,1,1,1]; % Stores the amplitudes for each harmonic.
    
    % Inicialise the vectors.
    begining = zeros(1,whistleDur*Fs+1);
    whistle = zeros(1,whistleDur*Fs+1);
    ramp = zeros(1,rampDur*Fs+1);
    
    for n=1: length(Amps)      
        % Creates the current linear sweep with the fase at 90 degrees.
        beginingSin = chirp(whistleTime,n*startFreq,whistleDur,n*endFreq,'linear',90);
        whistleSin = chirp(whistleTime,n*startFreq,whistleDur,n*endFreq,'linear',90);
        rampSin = chirp(rampTime,n*endFreq,rampDur,n*(endFreq+rampOffset),'linear',90);
        
        % Add the current sweep to the vector with the corresponding amplitude.
        begining = begining + beginingSin*bAmps(n);
        whistle = whistle + whistleSin*Amps(n);
        ramp = ramp + rampSin*Amps(n);
    end
    
    % Creates fade-in, fade-out and crossfade lines
    fadeIn = linspace(0,1,Fs/50); % 0.05 second long fade in 
    crossFadeOut = linspace(1,0,Fs/100); % 0.01 Secons long crossfade
    crossFadeIn = linspace(0,1,Fs/100); % 0.01 second long crossfade
    fadeOut = linspace(1,0,Fs/50); % 0.05 Secons long fade out
    
    
    % Normalises the sweeps.
    begining = begining/max(begining);
    whistle = whistle/max(whistle);
    ramp = ramp/max(ramp);
    
    % And applys the fades to the parts sound
    begining(1:Fs/50) = begining(1:Fs/50) .* fadeIn;
    begining(Fs:Fs+Fs/100-1) = begining(Fs:Fs+Fs/100-1) .* crossFadeOut;
    whistle(Fs:Fs+Fs/100-1) = whistle(Fs:Fs+Fs/100-1) .* crossFadeIn;
    whistle((length(whistle)-Fs/100)+1:end) = whistle((length(whistle)-Fs/100)+1:end) .* crossFadeOut;
    ramp(1:Fs/100) = ramp(1:Fs/100) .* crossFadeIn;
    ramp((length(ramp)-Fs/50)+1:end) = ramp((length(ramp)-Fs/50)+1:end) .* fadeOut;
    
    % Changes the begining
    whistle(Fs:Fs+Fs/100-1) = whistle(Fs:Fs+Fs/100-1) + begining(Fs:Fs+Fs/100-1);
    whistle(1:Fs) = begining(1:Fs);
    
    
    % Equilibrates the lengths adding zeros
    zeroos1 = zeros(1,length(whistle)-(Fs/100));
    zeroos2 = zeros(1,length(ramp)-(Fs/100));
    
    whistle = horzcat(whistle,zeroos2);
    ramp = horzcat(zeroos1,ramp);
    
    % And adds the descending sweep with the final ramp.
    whistle = whistle + ramp; 
    
    % Adds the preBlank and the whistle.
    whistle = horzcat(preBlank,whistle);
    
    
    % Uncoment to sound
    %sound(whistle*0.1,Fs);
    
end

