function [IRL, IRR] = getIRs (elevation, azimuth)
% Function to get the horitzontally interpoled IRs at any azimuth and a known elevation

% Values given by the HRIR database
minVAngle = -45;
maxVAngle = 90;
vResolution = 15;

if (mod(elevation,vResolution) == 0 && elevation >= minVAngle && elevation <= maxVAngle)

    % Loads the IR database (Subject 1059: http://recherche.ircam.fr/equipes/salles/listen/download.html)
    load('IRC_1059_C_HRIR.mat');

    % The database has different less azimuth resolution at higher
    % elevation points. Thus, the offset will be different in that
    % cases.

    %This allows the function to round more than once.
    if (azimuth > 360) 
        nRounds=fix(azimuth/360);
        azimuth = azimuth-360*nRounds;
    end
    
    if (elevation <= 45)  % From -45 to 45, there are 24 azimuth angles.

       [~,index1] = min(abs(azimuth - l_eq_hrir_S.azim_v(1:24))); % Search the horitzonal very closest point 
       verticalOffset = (elevation/15+3)*24; % The vertical offset will be 24 multiplyed by the number of steps 
       hResolution = 15;

    elseif (elevation == 60) 

       [~,index1] = min(abs(azimuth - l_eq_hrir_S.azim_v(169:180))); % Search the horizonal very closest point
       verticalOffset = 168;  % 60 degrees data is starting at index 169
       hResolution = 30;

    elseif (elevation == 75) 

        [~,index1] = min(abs(azimuth - l_eq_hrir_S.azim_v(181:186)));  
        verticalOffset = 180; % 75 degrees data is starting at index 181 
        hResolution = 60;

    elseif (elevation == 90) 
        % If the elevation is 90 degrees, set the IRs to the unique point.
        IRL = l_eq_hrir_S.content_m(187,:);
        IRR = r_eq_hrir_S.content_m(187,:);  
    end

    if (elevation ~= 90) % If the elevation is 90 this step can be omitted.

        % Set the horitzonal very closest point
        HclosestPoint = l_eq_hrir_S.azim_v(index1+verticalOffset,:);  

        % Searching the second closest point

        % If it is not at the ends, it will sum or rest a position in the table
        if (azimuth>HclosestPoint && HclosestPoint ~= 360-hResolution)
            HsecClosestPoint = l_eq_hrir_S.azim_v(index1+verticalOffset+1,:);
        elseif (azimuth<HclosestPoint && azimuth ~= 0) 
            HsecClosestPoint = l_eq_hrir_S.azim_v(index1+verticalOffset-1,:);

        % If the azimuth is 0 or the biggest, sets the second closest
        % point at the same position and the IRs at that point
        else
             HsecClosestPoint = l_eq_hrir_S.azim_v(index1+verticalOffset,:);
             IRL = l_eq_hrir_S.content_m(index1+verticalOffset,:);
             IRR = r_eq_hrir_S.content_m(index1+verticalOffset,:);
        end

        % If the points are the same this step can be omitted.
        if (HsecClosestPoint ~= HclosestPoint)

        % Searching the index for the second closest point
            if (elevation <= 45)  
                [~,index2] = min(abs(HsecClosestPoint - l_eq_hrir_S.azim_v(1:24)));
            elseif (elevation == 60) 
                [~,index2] = min(abs(HsecClosestPoint - l_eq_hrir_S.azim_v(169:180)));
            elseif (elevation == 75) 
                [~,index2] = min(abs(HsecClosestPoint - l_eq_hrir_S.azim_v(181:186)));
            end           

            % Setting the IRs for the two points
            IRL1 = l_eq_hrir_S.content_m(index1+verticalOffset,:);
            IRR1 = r_eq_hrir_S.content_m(index1+verticalOffset,:);
            IRL2 = l_eq_hrir_S.content_m(index2+verticalOffset,:);
            IRR2 = r_eq_hrir_S.content_m(index2+verticalOffset,:);

            % Interpolation of the two closests IRs
            IRL = IRL1*abs((abs(azimuth-HclosestPoint)/hResolution)-1)+IRL2*abs((abs(azimuth-HsecClosestPoint)/hResolution)-1);
            IRR = IRR1*abs((abs(azimuth-HclosestPoint)/hResolution)-1)+IRR2*abs((abs(azimuth-HsecClosestPoint)/hResolution)-1);            
         end
    end
        
else
    error('The elevation value must be between -45 and +90 in steps of 15 degrees')
end
