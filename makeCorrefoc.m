function [output, nFW] = makeCorrefoc (nSeconds, minSpace, maxSpace, Fs)
% This function creates a "correfoc" soundscape with a given length.
%
% -> nSeconds: Length of the soundscape in seconds
% -> minSpace: Minimum space between fireworks in seconds
% -> maxSpace: Maximum space between fireworks in seconds
% -> Fs: Sampling frequency
%
% <- output: Binaural stereo vector with the soundscape
% <- nFW: Number of fireworks created 
   
    % Display rendering information 
    disp('----- Creating correfoc -----')
    disp(['Creating fireworks... (0','%)'])

    duration = nSeconds*Fs; % Set the duration in samplers

    output = zeros(duration,2); % Creates the empty vector
    nFW = 0; % Number of fireworks
    time = 1; %S tarting time

    % While time is lower than the maximum duration, a new firework is added.
    while (time < duration)

        amp = (randi(7)/10)+0.3; % Set the amplitude between 0.5 and 1.
        hasWhistle = randi(4); % If the random number is 1, the curent firework will have a whistle.
        carretilla = makeFW(Fs,amp,hasWhistle); % Creates the current firework.
        
        % If the firework (plus the 512 samplers of the IR convolution) is
        % fitting in the output vector, the firework is processed.
        if (time+length(carretilla)+512 < duration)
            
            startingpoint = randi(90)+135; % Creates a random angle to start between 135 and 225 degrees.
            endpoint = randi(360); % Creates a random angle to finish.
            vpoint = randi(20)+60; % Creates a random elevation point between 60 and 80 degrees.
 
            carretilla = moveToPointV(carretilla,startingpoint,endpoint,vpoint,1024); % Moves the sound.
            
            % Adds the currrent firework to the vector
            output(time:time+length(carretilla)-1,:) = output(time:time+length(carretilla)-1,:)+carretilla;
            
            % And changes the starting point for the next firework according to the space set by the user.
            time = time + randi((maxSpace-minSpace)*Fs)+minSpace*Fs;
            
            % Count one more firework and display rendering information
            nFW = nFW+1; 
            percentage = round(time/(duration)*100);
            clc;
            disp('----- Creating correfoc -----')
            disp(['Creating fireworks... (', num2str(percentage), '%)'])
            
        % If is not fitting, exits the while
        else
            time = duration; % Forces the while exit.
            clc; %Clears the command window
        end  
    end

    clc; %Clears the command window
    
    % Uncoment to sound
    %sound(output,Fs);
end





