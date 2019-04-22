function [loopedFile] = loopSound(file, duration)
% This function loopes a file until meet the desired duration.
%
% -> file: The file to loop
% -> duration: Desired duration
%
% <- loopedFile: Resulting looped vector

    fileDur = length(file); % Length of the file in samples.
    initSamp = randi(fileDur); %Random starting point
    loopedFile = file(initSamp:end,:); %Set the first chunk to the loopedFile.
    loopTimes = duration/fileDur-1; %Set the loop rounds
    
    % Add at the end of loopedFile, "i" times the complete file.
    for i=1: loopTimes
        
        loopedFile = vertcat(loopedFile,file);   
        
    end

    % If the duration is not a multiple of fileDur, calculates the number
    % of samples needed to fill all the length.
    if (mod(duration,fileDur) ~= 0)

       initSamp = duration-length(loopedFile);
       
    end
    
    % If the number of samples is less than a round, add that number of
    % samples at the end of the loopedFile.
    if (initSamp <= fileDur)
        loopedFile = vertcat(loopedFile,file(1:initSamp,:));
        
    %Else, add one more complete round and the rest of the samples.
    else
        loopedFile = vertcat(loopedFile,file); 
        loopedFile = vertcat(loopedFile,file(1:initSamp-fileDur,:));
    end
    
    % If the file is longer, it cuts the leftover samples.
    if (length(loopedFile) > duration)
       loopedFile = loopedFile(1:duration,:); 
    end
    
end
