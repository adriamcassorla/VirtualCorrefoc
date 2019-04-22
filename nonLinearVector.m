function [t_vector] = nonLinearVector(vectorLength,minParts,maxParts,minRand,maxRand,Fs)
%Creates a non linear vector to use to create a non periodic waveform.
%
% -> vectorLength: Length of the vector in samplers.
% -> minParts: Minimum parts in with the vector will be devided in.
% -> minParts: Maximum parts in with the vector will be devided in.
% -> minRand: Maximum offset number.
% -> minRand: Minimum offset number.
% -> Fs: Sampling frequency.
%
% <- t_vector: The non linear vector.


    % If the number of parts is correct, defines the parts in whith the line will be devided in.
    if (mod(minParts,2)==0 && mod(maxParts,2)==0)
        parts = (randi(((maxParts-minParts)/2)+1)-1)*2+minParts; 
    else
        error('The number of parts must be an even number')
    end

    t_vector = (1:vectorLength)/Fs; % Creates the line.
    x = floor(length(t_vector)/parts); %And divides it.

    for n=1 : parts   
        position(n) = floor(x*n); % Saves the position of each part in a vector.

        % The even positions are randomized.
        if mod(n,2) ~= 0
           offset = (randi(maxRand)-1)-(randi(minRand)-1);
           position(n) = floor(position(n)+offset);
        % And also its values.   
           offset = (randi(maxRand)-1)-(randi(minRand)-1);
           t_vector(position(n)) = floor(t_vector(position(n))+(offset/10));
        end

        % Finally, saves the values in a vector.
        values(n) = floor(t_vector(position(n)));
    end

    % Creates a linspace creating small lines between the randomised values and positions.
    for n=0 : parts-1

        if (n == 0)
            difference = position(1);
            currentVector = linspace(0,values(1),difference);
            t_vector(1:position)= currentVector;

        elseif (n<parts-1)
            difference = position(n+1)-position(n);
            currentVector = linspace(values(n),values(n+1),difference);
            t_vector(position(n)+1:position(n+1))= currentVector;
        end  
end

