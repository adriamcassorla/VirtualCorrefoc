function [output, nDragons] = makeDragonImmersions(output,firstIm,minSpace,maxSpace,Fs)
%makeDragonImmersions This function filters some parts of the output to simulate dragon immersions.
%
% -> output: File to apply the filters.
% -> firstIm: Time of the first immersion in seconds.
% -> minSpace: Minimum space between immersions in seconds.
% -> maxSpace: Maximum space between immersions in seconds.
% -> Fs: Sampling frequency.
%
% <- output: Returns the same vector with the filters applyed.
% <- nDragons: Number of immersions done.
%

    duration = length(output); % Duration of the output in samplers
    nDragons = 0; % Sets the counter at 0
    time = firstIm*Fs; % Starting time

    % While time is lower than the maximum duration, a new immersion is added.
    while (time < duration)
           
        filterDur = (randi(5)+3)*Fs; % Length of the immersion.
        
        % If the length of the immersion added to the time is fitting, then it filters that part.
        if (time+filterDur < duration)
            
            % Filters the part
            output = filterPart(output,400,time,time+filterDur,1,Fs);
         
            % Count one more immersion and displays rendering information
            nDragons = nDragons + 1;
            percentage = round(time/(duration)*100);
            clc;
            disp('----- Creating dragon immersions -----')
            disp(['Applying filters... (', num2str(percentage), '%)'])
            
            % Changes the starting point for the next immersion according to the space set by the user.
            time = time + (randi(maxSpace+1-minSpace)+minSpace-1)*Fs;
            
        % If is not fitting, exits the while
        else
            time = duration; % Forces the while exit.
        end  
    
    end
    
    clc; %Clears the command window
       
    % Uncoment to sound
    % sound(output,Fs);
end

