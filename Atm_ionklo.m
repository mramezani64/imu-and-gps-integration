function Id = Atm_ionklo(t, GNSS, pos, azel, ion, c)
%IONMODEL Summary of this function goes here
%   Detailed explanation goes here

year = 2000 + GNSS.Obs_data(1,1);

if isempty(ion) == 1
    if year < 2013 || year > 2014
        ion = [0.1118E-07, -0.7451E-08, -0.5961E-07, 0.1192E-06,...
            0.1167E+06,-0.2294E+06,-0.1311E+06, 0.1049E+07];
    elseif year == 2013
        ion = [.1211E-07,   .2235E-07,  -.5960E-07,  -.1192E-06,...
            .1004E+06   .1147E+06  -.6554E+05  -.3277E+06];
    elseif year == 2014
        ion = [.1956E-07,  -.1490E-07,  -.1192E-06,   .1788E-06,...
            .1290E+06,  -.1475E+06,   .0000E+00,  -.6554E+05];
    end    
end

az = azel(1); el = azel(2); % in rad
lat = pos(1);longi = pos(2);h = pos(3);

%% earth centered angle (semi-circle) 
psi = 0.0137/(az/pi+0.11)-0.022;

%%  subionospheric latitude/longitude (semi-circle)
phi = lat/pi + psi*cos(az);

if phi > 0.416
    phi = 0.416;
elseif phi<-0.416
    phi = -0.416;        
end

lam = longi/pi + psi*sin(az)/cos(phi*pi);

%% geomagnetic latitude (semi-circle)
phi = phi + 0.064*cos((lam-1.617)*pi);
     
%% local time (s) 
tt = 43200.0 * lam + t;
tt = tt - floor(tt/86400.0)*86400.0; %/* 0<=tt<86400 */

%% slant factor 
f = 1.0 + 16.0 * (0.53-el/pi)^3;

%% ionospheric delay
amp = ion(1) + phi *(ion(2) + phi*(ion(3) + phi*ion(4)));
per = ion(5) + phi *(ion(6) + phi*(ion(7) + phi*ion(8)));
if amp < 0; amp = 0; end
if per < 72000; per = 72000; end

%% Phase of iono delay
x   = 2.0*pi*(tt-50400.0)/per;

%% Out
if abs(x)<1.57
    Id = c.v_light * f * (5E-9 + amp*(1.0+x*x*(-0.5+x*x/24.0)));
else
    Id = 5E-9;
end


end

