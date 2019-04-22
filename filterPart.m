function [output] = filterPart(output,filterFreq,initPoint,endPoint,crossFade,Fs)
%filterPart This function applies a lowPass filter to a part of a vector.
%
% -> output: The complete vector to filter a part of it
% -> filterFreq: Frequency to cut off
% -> initPoint: Start point to filter in samplers
% -> endPoint: End point to filter in samplers
% -> crossFade: Length of the crossFade in seconds
% -> Fs: Sampling rate.
%
% <- output: Returns the same file with some filtered parts

    crossFade = Fs*crossFade; % Crossfade length in samplers
    filterLength = endPoint-initPoint; % Length of the filtered part

    % Creates new vectors with the clean part and the filtered part
    cleanOutput = output(initPoint:endPoint-1,:);
    filteredOutput(:,1) = aplowpass(output(initPoint:endPoint-1,1),filterFreq/Fs,crossFade,Fs);
    filteredOutput(:,2) = aplowpass(output(initPoint:endPoint-1,2),filterFreq/Fs,crossFade,Fs);

    % Creates fade in and fade out lines for the crossfades
    fadeIn = [linspace(0,1,crossFade);linspace(0,1,crossFade)]; % fade in
    fadeOut = [linspace(1,0,crossFade);linspace(1,0,crossFade)]; % fade out

    % Applies the crossfades to the part
    cleanOutput(1:crossFade,:)=cleanOutput(1:crossFade,:) .* fadeOut';
    filteredOutput(1:crossFade,:)=filteredOutput(1:crossFade,:) .* fadeIn';
    filteredOutput((filterLength-crossFade)+1:end,:) = filteredOutput((filterLength-crossFade)+1:end,:) .* fadeOut';
    cleanOutput((filterLength-crossFade)+1:end,:) = cleanOutput((filterLength-crossFade)+1:end,:) .* fadeIn';

    % Sets to zeros the central part of clean Output.
    cleanOutput(crossFade+1:filterLength-crossFade,:)=zeros(filterLength-crossFade*2,2);

    % And adds the clean and filtered output.
    filteredOutput = cleanOutput + filteredOutput;

    % Changes the filtered part to the original vector.
    output(initPoint:endPoint-1,:) = filteredOutput;

    % Uncoment to sound
    %sound(output(initPoint-2*Fs:end,:),Fs);
end

