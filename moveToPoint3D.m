function [output] = moveToPoint3D (x, hloc1 , hloc2, vloc1, vloc2, frame_size)
% This function moves the passed file from one horizonal point to another and from a vertical point to another at the same time.
% It is using interpolation between the given IR angles.
%
% -> x: The file to process
% -> hloc1: Orign azimuth angle
% -> hloc2: Destination azimuth angle
% -> vloc1: Orign vertical angle
% -> vloc2: Destination vertical angle
% <- output: Binaural stereo vector whith the movement processed
%
% Function adapted from several Frank Stevens lecture examples.

minVAngle = -45;
maxVAngle = 90;
vResolution = 15;

% Loads the IR database (Subject 1059: http://recherche.ircam.fr/equipes/salles/listen/download.html)
load('IRC_1059_C_HRIR.mat');

x = x(:, 1);  % (If necessary) this reduces a stereo input to mono

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

ideal_az = linspace(hloc1,hloc2,Nframes); % Creates a line between the two horitzontal points in Nframes steps.
ideal_v = linspace(vloc1,vloc2,Nframes); % Creates a line between the two horitzontal points in Nframes steps.

% Convolves each frame of the input vector with the impulse response
frame_start = 1;
for n = 1 : Nframes
    
    % Applies the window to the current frame of the input vector x
    Y1 = w .* x(frame_start : frame_start+frame_size-1);
    Y2 = w .* x(frame_start : frame_start+frame_size-1);
   
    % If the entered angle is not in the database, it searches the closests to interpolate them.
    if (mod(ideal_v(n),vResolution) ~= 0)  
        
        % Searches for the very closest point.
        [~,index] = min(abs(ideal_v(n) - l_eq_hrir_S.elev_v)); 
        VclosestPoint = l_eq_hrir_S.elev_v(index,:);
    
        % And sets the second closest point
        if (ideal_v(n)>VclosestPoint)
            VsecClosestPoint = VclosestPoint+vResolution;
        else
            VsecClosestPoint = VclosestPoint-vResolution;
        end
        
         % Setting the IRs for the two vertical points
        [IRL1, IRR1] = getIRs (VclosestPoint, ideal_az(n));
        [IRL2, IRR2] = getIRs (VsecClosestPoint, ideal_az(n));

        % Interpolation of the two closests IRs
        IRL = IRL1*abs((abs(ideal_v(n)-VclosestPoint)/vResolution)-1)+IRL2*abs((abs(ideal_v(n)-VsecClosestPoint)/vResolution)-1);
        IRR = IRR1*abs((abs(ideal_v(n)-VclosestPoint)/vResolution)-1)+IRR2*abs((abs(ideal_v(n)-VsecClosestPoint)/vResolution)-1);
    else
        [IRL, IRR] = getIRs(ideal_v(n), ideal_az(n));
    end
    
    %Applies zero padding to the frames and the IRs
    zerosIR=zeros(frame_conv_len-frame_size,1);
    zerosFrame=zeros(frame_conv_len-NIR,1);
    Y1=vertcat(Y1,zerosIR);
    Y2=vertcat(Y2,zerosIR);
    IRL = vertcat(IRL',zerosFrame);
    IRR = vertcat(IRR',zerosFrame);
    
    % Multiplies the frame and the IR in the frequency domain
    Y1 = ifft(fft(Y1).*fft(IRL));
    Y2 = ifft(fft(Y2).*fft(IRR));
    
    % Adds the convolution result for this frame into the output vector y
    y1(frame_start:frame_start+frame_conv_len-1) = y1(frame_start:frame_start+frame_conv_len-1)+Y1;
    y2(frame_start:frame_start+frame_conv_len-1) = y2(frame_start:frame_start+frame_conv_len-1)+Y2;
    
    % Advance to the start of the next frame
    frame_start = frame_start+step_size;
end


output=horzcat(y1,y2); % Creates the output vector (stereo)
%sound(output, r_eq_hrir_S.sampling_hz)    