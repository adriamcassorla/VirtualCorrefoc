function [output] = makeBackground(Dur,Fs) 
% This function creates a background soundscape with a given length.
%
% -> Dur: Length of the soundscape in seconds
% -> Fs: Sampling frequency
%
% <- output: Binaural stereo vector with the soundscape

    % Displays rendering information
    disp('----- Creating background ---')
    
    duration = Dur*Fs; % Set the duration in samplers

    % Imports the background sounds
    screams = audioread('RealSounds/screams.flac');
    distantFireworks = audioread('RealSounds/backgroundFireworks.flac');
    ambience = audioread('RealSounds/ambience.flac');

    fileDur = length(screams); % File duration in samplers (All three files are equal long)

     % If the file is shorter than the duration, a random starting point per
     % each sound is set, and the vectors are redimensioned with the correct
     % length.
    if (duration<fileDur)

        initSamp = randi(fileDur-duration); % Random number to start
        screams = screams(initSamp:initSamp+duration-1,:); % Takes a sampDur part of the sound

        initSamp = randi(fileDur-duration);
        distantFireworks = distantFireworks(initSamp:initSamp+duration-1,:);

        initSamp = randi(fileDur-duration);
        ambience = ambience(initSamp:initSamp+duration-1,:);

    % If the duration is longer, a loop is created to fill all the length    
    else

        screams = loopSound(screams, duration);
        distantFireworks = loopSound(distantFireworks, duration);
        ambience = loopSound(ambience, duration);

    end


    % Creates a dynamic envelope for the screams sound.

    % Scales the number of parts (min 10 and max 20 when is 30 seconds) in even numbers
    minParts = round(duration/Fs/6)*2;
    maxParts = round(duration/Fs/6)*4;

    % Creates two non linear vectors
    t_vectorL = nonLinearVector(length(screams),minParts,maxParts,5,9,Fs);
    t_vectorR = nonLinearVector(length(screams),minParts,maxParts,5,9,Fs);

    % Creates a different sine for each ear
    sinusL = sin(0.04*pi*3*t_vectorL);
    sinusR = sin(0.03*pi*3*t_vectorR);

    % And multiplies this sine with the "screams" sound
    screams(:,1) = screams(:,1) .* sinusL';
    screams(:,2) = screams(:,2) .* sinusR';

    
    %Add the three background sounds
    output = distantFireworks*1 + ambience*0.4 + screams*0.7;

    % Creates fade in and fade out lines
    fadeIn = [linspace(0,1,Fs);linspace(0,1,Fs)]; % 1 second long fade in
    fadeOut = [linspace(1,0,Fs*5);linspace(1,0,Fs*5)]; % 5 Secons long fade out

    %And applies the fades to the final sound
    output(1:Fs,:)=output(1:Fs,:) .* fadeIn';
    output((length(output)-Fs*5)+1:end,:) = output((length(output)-Fs*5)+1:end,:) .* fadeOut';

    %Uncoment to sound
    %sound(output, 44100);
    
    % Clears the command window
    clc;
end

