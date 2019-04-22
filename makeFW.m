function [output] = makeFW(Fs,Amp,hasWhistle)
%makeFW Creates a firework with some randomized parameters
% The firework is created combining synthesis and real recordings
% 
% -> Fs: Sampling frequency.
% -> Amp: Amplitude of the firework.
% -> hasWhistle: Enter a 1 to add a whistle to the firework.
%
% <- output: Mono vector with the firework

    % Selects one of the three recordings of noise produced by the firework.
    number = randi(3);
    file = strcat('RealSounds/Carretilla-',int2str(number),'.wav');
    noise = audioread(file)';
    
    % Creates a non liniar vector
    t_vector = nonLinearVector(length(noise),2,6,1,3,Fs);
    % And a sine waveform with an offset of 0.5
    sinus = sin(2*pi*12*t_vector);
    sinus = (0.3*sinus)+0.5;

    % Multiplies the noise by the sine and scales the amplitude.
    firework = (noise .* sinus) * Amp;
    
    % If it has to have a whistle, add it to the firework.
    if (hasWhistle == 1)
        whistle=makeWhistle(length(firework),Fs);

        % Set cut exceading samplers
        if length(firework) > length(whistle)
            firework = firework(1:length(whistle));
        elseif length(firework) < length(whistle)
            whistle = whistle(1:length(firework));
        end

        firework = firework + (whistle*0.08*Amp); %Adds the whistle at a very low level
    end

    % Adds an explosion at the end of the FW, chosing randomly between 9 real explosions
    number = randi(9);
    file = strcat('RealSounds/Explosions/explosion-',int2str(number),'.wav');
    explosion = audioread(file);
    explosion = explosion*Amp*1.2;

    % Add the explosion after the noise.
    output = vertcat(firework', explosion);

    %Uncoment to sound the firework
    %sound(output,Fs);
end

