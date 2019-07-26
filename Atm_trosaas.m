function [ Td ] = Atm_trosaas( pos, azel )

temp0 = 15;
humi  = 0.7;

az = azel(1);% in rad
el = azel(2);% in rad
lat   = pos(1);
longi = pos(2);
h     = pos(3);

% standard atmosphere
if h < 0; h = 0; end

pres = 1013.25 * (1.0-2.2557E-5*h)^5.2568;
temp = temp0 - 6.5E-3 * h + 273.16;
e    = 6.108 * humi * exp((17.15*temp-4684.0)/(temp-38.45));

% saastamoninen model
z    = pi/2.0 - el;
trph = 0.0022768 * pres / (1.0 - 0.00266 * cos(2.0*lat) - 0.00028 * h /1E3)/cos(z);
trpw = 0.002277 * (1255.0/temp+0.05)*e/cos(z);

Td   = trph+trpw;
end

