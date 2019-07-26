function [ posplot, unit_v ] = skyview( time, pos, sats, Eph, COA, a, e_squared)
%GPS_SKYVIEW Calculates the coordinates to plot skyview

% identify ephemerides columns in Eph
m       = size(sats,1);
col_Eph = zeros(m,1);
for t = 1:m
    col_Eph(t) = GPS_feph(Eph,sats(t),time);
end

PosPlot = zeros(t,4);
pos     = pos';
unit_v  = NaN(m,4);

for i = 1:m %go through each pseudorange/satellite
    k = col_Eph(i);
    
    %If ephemeris data does not have SV information
    if k == 0; continue; end
        
    %%
    tx_RAW  = time;
    t0c     = Eph(21,k);
    dt      = GPS_check_t(tx_RAW-t0c);
    
    tcorr   = (Eph(2,k)*dt + Eph(20,k))*dt + Eph(19,k);
    
    for n = 1:10
        dt  = GPS_check_t(tx_RAW-t0c) - tcorr;
        tcorr = (Eph(2,k)*dt + Eph(20,k))*dt + Eph(19,k);
    end
    
    tx_GPS  = tx_RAW-tcorr;
    
    %% Calculate satellite position
    [X] = GPS_pos_Sat(tx_GPS, Eph(:,k), tcorr);
    
    % Calculate Elevation, Azimuth and Distance from receiver to satellite
    [az,el,dist] = GPS_topocent(pos(1:3,:),X-pos(1:3,:),a,e_squared);
    
    % Cut off angle is set to 15' (Changable in main file)
    if el <= COA
        if i == m
            break; else continue;
        end
    end
    
    az = az*pi/180;
    el = el*pi/180;
    
    % Calculate and save unit vector
    unit_v(i,1:4) = [sats(i) sin(az)*cos(el) cos(az)*cos(el) sin(el)];
    
    % convertion to polar coordinates
    xx = (90-el).*cos(az);
    yy = (90-el).*sin(az);
    
    PosPlot(i,:) = [sats(i),-xx,yy,dist];
    
end

n       = size(PosPlot,1);
posplot = NaN(1,32*4); %Existing Satellites 
for i = 1:n        
    if PosPlot(i,1) == 1
        posplot(1,1:4) = PosPlot(i,:);
    elseif PosPlot(i,1) == 0
    else
        st = (PosPlot(i,1)- 1)*4 + 1;
        en = st + 3;
        posplot(1,st:en) = PosPlot(i,:);
    end
end

unit_v(isnan(unit_v(:,1)),:)=[];



