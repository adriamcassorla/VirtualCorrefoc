function [freeStyle] = makeFreeStyle(frameSize,Fs)
%makeFreeStyle This function generates a freeStyle demonstration.
%It simulates the movement of a firework stik moving it randomly.
%
% -> frameSize: frame size of the movements.
% -> Fs: Sampling frequency.
%
% <- freeStyle: free-style demonstration.

    % Displays rendering information 
    disp('----- Creating FreeStyle -----')
    disp(['Creating free-style demonstration... (0','%)'])

    carretilla = makeFW(Fs,1,0); % Creates the firework
    freeStyle = zeros(length(carretilla),2); % Inizialises the freeStyle vector
    
    nParts = (randi(6)-1)+5; % Sets the number of parts between 5 and 10
    partSize = floor(length(carretilla)/nParts); % Sets the length of each part

    hFinish = 0; % Initial hortizontal point
    vFinish = 0; % Initial vertical point

    % Creates fade in and fade out lines for the crossfades
    crossLen = Fs/10;
    fadeIn = [linspace(0,1,crossLen);linspace(0,1,crossLen)]; % 0.1 second long fade in
    fadeOut = [linspace(1,0,crossLen);linspace(1,0,crossLen)]; % 0.1 Secons long fade out

    initPos = crossLen; % Initial position.

    for n=1: nParts
        
        % If it is the first part, the sound is not moving.
        if (n==1)
            
            % Pocisionates the sound at 0 degrees elevation and 0 degrees horizontal
            currentPart = moveToPointV(carretilla((n-1)*partSize+1:partSize*n),0,0,0,frameSize);
            endPos = initPos+length(currentPart)-crossLen; % Sets the end position        
        
        % For the middle parts, it moves the sound randomly
        elseif (n<nParts)

            % Sets the last part finish points to this part start points.
            hStart = hFinish;
            vStart = vFinish;
            
            % Ands set new random points to finish.
            hFinish = randi(360*2);
            vFinish = (randi(136)-1)-45;
 
            % Moves the sound randomly
            currentPart = moveToPoint3D(carretilla((n-1)*partSize+1:partSize*n),hStart,hFinish,vStart,vFinish,frameSize);
            endPos = initPos+length(currentPart)-crossLen; % Sets the end position    
        
        % If it is the last part, takes all the resting samplers of the
        % firework and it stops at the last part finish point.
        elseif (n==nParts)
            currentPart = moveToPointV(carretilla((n-1)*partSize+1:end),hStart,hStart,vStart,frameSize);
            endPos = initPos+length(currentPart)-crossLen; % Sets the end position
        end

        %Applies the crossfades to the part
        currentPart(1:Fs/10,:)=currentPart(1:Fs/10,:) .* fadeIn';
        currentPart((length(currentPart)-Fs/10)+1:end,:) = currentPart((length(currentPart)-Fs/10)+1:end,:) .* fadeOut';

        % And adds that part to the vector
        freeStyle(initPos+1-crossLen:endPos,:) = freeStyle(initPos+1-crossLen:endPos,:)+currentPart;
        
        initPos = endPos; % Sets the initial point to the current end point.

        % Displays rendering information 
        percentage = round(n/nParts*100);
        clc;
        disp('----- Creating FreeStyle -----')
        disp(['Creating free-style demonstration... (', num2str(percentage), '%)'])

    end

        clc; %Clears the command window

        % Uncoment to sound
        %sound(freeStyle,Fs);
end

