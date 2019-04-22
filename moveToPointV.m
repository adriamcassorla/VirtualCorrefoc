function [output] = moveToPointV (x, hloc1 , hloc2, vloc, frameSize)
% This function moves the passed file from one horizonal point to another at a fix elevation point.
% It is using interpolation between the given IR angles.
%
% -> x: The file to process.
% -> hloc1: Orign angle.
% -> hloc2: Destination angle.
% -> vloc: Elevation point.
% <- output: Binaural stereo vector whith the movement processed.
%
% Function adapted from several Frank Stevens lectures examples.

minVAngle = -45;
maxVAngle = 90;
vResolution = 15;

% Loads the IR database (Subject 1059: http://recherche.ircam.fr/equipes/salles/listen/download.html)
load('IRC_1059_C_HRIR.mat');

if (vloc >= minVAngle && vloc <= maxVAngle) % If the entered value is not between -45 and +90 it will crash and give an error.      
    if (mod(vloc,vResolution) ~= 0) % If the entered angle is not in the database, it searches the closests to interpolate them. 
        
        % Searches for the very closest point.
        [~,index] = min(abs(vloc - l_eq_hrir_S.elev_v)); 
        VclosestPoint = l_eq_hrir_S.elev_v(index,:);
    
        % And sets the second closest point
        if (vloc>VclosestPoint)
            VsecClosestPoint = VclosestPoint+vResolution;
        else
            VsecClosestPoint = VclosestPoint-vResolution;
        end
    end
else
    error(['The elevation point must be between '  num2str(minVAngle) ' and ' num2str(maxVAngle) '.']);
end

x = x(:, 1);  % (If necessary) this reduces a stereo input to mono

frame_size = frameSize; 
step_size = frame_size/2; % Step size for 50% overlap-add
Ninput = length(x); % The number of samples in the input signal
NIR = length(l_eq_hrir_S.content_m); % The number of samples in the impulse response
y_length = Ninput+NIR-1;
Noutput = y_length; % and therefore the number of output samples

Nframes = floor(Ninput / step_size) - 1; % -1 prevents input overrun in the final frame
frame_conv_len = frame_size+NIR-1; %  The number of samples created by convolving a frame of x and IR
w = hann(frame_size, 'periodic');  % Generate the Hann function to window a frame

y1 = zeros(y_length,1); % Inicializes the vectors with zeros
y2 = y1;

ideal_az = linspace(hloc1,hloc2,Nframes); % Creates a line between the two horizontal points in Nframes steps.


% Convolves each frame of the input vector with the impulse response
frame_start = 1;
for n = 1 : Nframes
    % Applies the window to the current frame of the input vector x
    Y1 = w .* x(frame_start : frame_start+frame_size-1);
    Y2 = w .* x(frame_start : frame_start+frame_size-1);
   
    % Easy way: if the desired vertical point is in the database.
    if (mod(vloc,vResolution) == 0)
        
        [IRL, IRR] = getIRs(vloc, ideal_az(n));
    
    % If the desired point is not in the database, then a vertical interpolation is needed.
    else 
        
        % Setting the IRs for the two vertical points
        [IRL1, IRR1] = getIRs (VclosestPoint, ideal_az(n));
        [IRL2, IRR2] = getIRs (VsecClosestPoint, ideal_az(n));

        % Interpolation of the two closests IRs
        IRL = IRL1*abs((abs(vloc-VclosestPoint)/vResolution)-1)+IRL2*abs((abs(vloc-VsecClosestPoint)/vResolution)-1);
        IRR = IRR1*abs((abs(vloc-VclosestPoint)/vResolution)-1)+IRR2*abs((abs(vloc-VsecClosestPoint)/vResolution)-1);
    end

    %Convolves the window with the IR
    Y1 = conv(Y1,IRL');
    Y2 = conv(Y2,IRR'); 
    % Add the convolution result for this frame into the output vector y
    y1(frame_start:frame_start+frame_conv_len-1) = y1(frame_start:frame_start+frame_conv_len-1)+Y1;
    y2(frame_start:frame_start+frame_conv_len-1) = y2(frame_start:frame_start+frame_conv_len-1)+Y2;
    % Advance to the start of the next frame
    frame_start = frame_start+step_size;
end

output=horzcat(y1,y2); %Creates the output vector (stereo)

%sound(output, r_eq_hrir_S.sampling_hz)


    