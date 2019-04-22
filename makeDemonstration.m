function [] = makeDemonstration(seconds,Fs,outputType)
%MakeDemonstration Creates a demonstration correfoc file
%
% -> seconds: Length of the demonstration in seconds
% -> Fs: Sampling frequency
% -> outputType: 0 to reproduce the demonstration
% -> outputType: 1 to create a wav file
%


% Clears the command window to start ploting render information
clc

% Starts the counter
tic

% Creates the background part
background = makeBackground(seconds,Fs);

% Creates the freeStyle part
freeStyle = makeFreeStyle(64,Fs);

% Sets the start point for the correfoc part
difSec = floor(length(freeStyle)/Fs)-randi(5);

% Creates the correfoc part
[correfoc, nFW] = makeCorrefoc(seconds-difSec,0,2,Fs);

% Adds zeros to the two parts to mix them with the background
zeroos = zeros(length(background)-length(freeStyle),2);
freeStyle = vertcat(freeStyle,zeroos);
zeroos = zeros(length(background)-length(correfoc),2);
correfoc = vertcat(zeroos,correfoc);

% Mixes all the parts
output = background + correfoc + freeStyle;

% Creates the dragon immersions
[output, nDragons] = makeDragonImmersions(output,15,60,180,Fs);


% Normalises the final file
maxOut = max(max(abs(output)));
output = output/maxOut;


% Sounds or outputs the file
if (outputType == 0)
    sound(output,Fs);
elseif (outputType == 1)
    audiowrite('correfocDemonstration.wav',output,Fs);
else
    disp('Please, enter a valid output type')
end


% Rendering information
minutes = int2str(floor(toc/60));
if (mod(toc,60)<10)
    seconds = ['0',int2str(mod(toc,60))];
else
    seconds = int2str(mod(toc,60));
end

% Displays the information
disp('------ DONE ------')
disp(['Total time elapsed: ',minutes,':',seconds,' minutes'])
disp(['Number of correfoc fireworks: ',int2str(nFW)])
disp(['Number of dragon immersions: ',int2str(nDragons)])


end

