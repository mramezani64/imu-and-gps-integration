function [rw] = possat_GLO(time, toe, eph)
%pos_SAT   Calculates position of each satellite at any particular time t

% by Azmir Hasnur Rabiain (24/09/2014)

%% Integration


t  = time - toe;

x  = eph(9);  y = eph(13);  z = eph(17);
vx = eph(10); vy = eph(14); vz = eph(18);
acc = [eph(11), eph(15), eph(19)];

x = [x;y;z;vx;vy;vz];

tstep = 60;
tt    = t;
if tt < 0; tt = -tstep;
else tt = tstep; end

while abs(t)>1e-9
    if abs(t)<tstep; tt = t; end
    t = t - tt;    
    x = glorbit(tt,x,acc);
end
    
%% Coordinate transformation

% to WGS-84
rw = x(1:3) + [-0.36;0.08;0.18];
% rw = x(1:3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = glorbit(t,x,acc)

J = acc;

k1 = diff(x, J); w  = x + k1*t/2; 
k2 = diff(w, J); w  = x + k2*t/2; 
k3 = diff(w, J); w  = x + k3*t;
k4 = diff(w, J);

x = x + t/6* (k1 + k2*2 + k3*2 + k4);

end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function out = tGE(te,ymd,w_e)
% 
% year = ymd(1); month = ymd(2); day = ymd(3);
% hour = ymd(4); minute = ymd(5); second = ymd(6);
% 
% h  = hour+minute/60+second/3600;
% 
% % Note that the time should be adjusted to UT1 not UTC (not implemented
% % here
% jd  = GPS_julday(year+2000,month,day,h);
% t1  = (jd-2451545.0)/36252.0;
% t2  = t1^2; t3 = t2*t1;
% 
% tG0 = 24110.54841 + 8640184.812866 * t1 + 0.093104 * t2 - 6.2E-6*t3;
% out = tG0 + w_e*(te - 10800);
% 
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = diff(x, acc)

R2 = x(1)^2 + x(2)^2 + x(3)^2; 
R3 = R2*sqrt(R2);

r  = x(1:3);v = x(4:6);

RE_GLO  = 6378136.0;    % Equitoria radius of earth (PZ-90)
MU_GLO  = 3.9860044E14; % Gravitational constant
J2_GLO  = 1.0826257E-3; % 2nd zonal harmonic of geopot
OMGE_GLO= 7.292115E-5;   % earth angular velocity (rad/s) 


omg2 = OMGE_GLO^2;
R    = sqrt(R2);

a = 1.5 * J2_GLO * MU_GLO * RE_GLO^2/R^5;
b = 5   * r(3)^2/R2;
c = -MU_GLO/R3 - a*(1-b);

dr(1:3) = v;
dv(1:3) = [(c + omg2) * r(1) + 2*OMGE_GLO*v(2) + acc(1);
           (c + omg2) * r(2) - 2*OMGE_GLO*v(1) + acc(2);
           (c - 2*a) * r(3) + acc(3)];

out = [dr';dv'];

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%% end satpos.m %%%%%%%%%
