function [ pos_ref ] = Ref_Station( str, a, e_squared)
%REF_STATION Lists coordinates of reference stations in geo and ecef

if strcmp(str,'MOBS') == 1
    % MOBS
    lat = -37.82941634*pi/180;
    lon = 144.9753351*pi/180;
    h   = 40.674;
elseif strcmp(str,'Parkville') == 1
    % Parkville
    lat = -37.79982269  *pi/180;
    lon = 144.9609131   *pi/180;
    h   = 67.494;    
else
    return
end

% Convert Ref data
[x, y, z]   = geodetic2ecef(lat, lon, h, [a sqrt(e_squared)]);
pos_ref     = [lat lon h; x, y, z];

end

