function [satp, tcorr] = possat_GPS(t, eph, tcorr)
%pos_SAT   Calculates position of each satellite at any particular time t

% by Azmir Hasnur Rabiain (06/02/2012) Some of the codes were adopted from
% Easy Suite II by Kai Borre $31-10-2001

GM = 3.9860050E14;             % earth's universal gravitational parameter m^3/s^2
Omega_dotE = 7.2921151467e-5; % earth rotation rate, rad/s
v_light = 299792458;


%% Corrected mean anomaly
M0      =  eph(18);
roota   =  eph(12);
Delta_n =  eph(19);
toes    =  eph(3);
toc     =  eph(4);
% toe     =  eph(2)-86400*.5;
% toe     =  eph(2);

% eph = [svprn;   toe;        toes;   toc;    ttr;
%     iode;       iodc;       tgd;    af0;    af1;    
%     af2;        roota;      ecc;    i0;     OMEGA0; 
%     omega;      Omegadot;   M0;     deltan; idot;   
%     crc;        crs;        cuc;    cus;    cic;    
%     cis;        svhealth];

A = roota^2;
tk = check_GPSt(t-toc);
M = Corr_Mean_Anomaly(A, GM, M0, Delta_n, tk);


%% Eccentric anomaly
ecc      = eph(13);
Ecc_anom = Ecc_anomaly(M, ecc);

%% True Anomaly
True_Anom = True_anomaly(ecc, Ecc_anom);

%% Argument of Latitude
omega   =   eph(16);
Lat     =   Arg_Lat(True_Anom, omega);

%% second harmonic pertubations
crc     =   eph(21);
crs     =   eph(22);     
cuc     =   eph(23);     
cus     =   eph(24);       
cic     =   eph(25);       
cis     =   eph(26);     

second_harmonic_pertubations = Second_Harmonic_Pertubations_corr(cus, cuc, crs, crc, cis, cic, Lat);

%% Correction
i0      =  eph(14);
IDOT    =  eph(20);

corrected = Correctedd(second_harmonic_pertubations, Lat, A, ecc, Ecc_anom, i0, IDOT, tk);
Pos_Orb = Orbital_plane(corrected(2, 1), corrected(1, 1));

Omega0     =  eph(15);
Omega_dot  =  eph(17);

lon_asc_node = Corr_long_asc_node(Omega0, Omega_dot, Omega_dotE, tk, toes);
lon_asc_node = rem(lon_asc_node+2*pi,2*pi);

satp = Satpos_ECEF(Pos_Orb, lon_asc_node, corrected(3, 1));

%% new tcorr
tgd   = eph(8);
tcorr = tcorr - 2 * sqrt(GM * A) * ecc * sin(Ecc_anom) / v_light^2 - tgd;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Subfunctions
%%
function output = Corr_Mean_Anomaly(A, GM, M0, Delta_n, tk)
output = M0 + (sqrt(GM / (A ^ 3)) + Delta_n) * tk;
end

%%
function output = Ecc_anomaly(M, e)
E_ano = M;
for i = 1:10
    E_old = E_ano;
    E_ano = M+e*sin(E_ano);
    dE_ano = rem(E_ano-E_old,2*pi);
    if abs(dE_ano) < 1.e-12
        break;
    end
end
output = rem(E_ano+2*pi,2*pi);
end

%%
function output = True_anomaly(e, E_ano)
v = atan2((sqrt(1 - e ^ 2) * sin(E_ano)), (cos(E_ano) - e));
if v < 0
    v = v + 2 * pi;
end
output = v;
end

%%
function output = Arg_Lat(v, omega)
output = v+omega;
end

%%
function output = Second_Harmonic_Pertubations_corr(cus, cuc, crs, crc, cis, cic, Lat)
output = [cuc*cos(2*Lat)+cus*sin(2*Lat);
    crc*cos(2*Lat)+crs*sin(2*Lat);
    cic*cos(2*Lat)+cis*sin(2*Lat)];
end

%%
function output = Correctedd(correction, Lat, A, e, E_ano, i0, IDOT, tk)
output = [Lat + correction(1, 1);
    A * (1 - e * cos(E_ano)) + correction(2, 1);
    i0 + correction(3, 1) + IDOT * tk];
end

%%
function output = Orbital_plane(radius, arg_lat)
output = [radius * cos(arg_lat);
    radius * sin(arg_lat)];
end

%%
function output = Corr_long_asc_node(Omega0, Omega_dot, Omega_dotE, tk, toe)
output = Omega0 + (Omega_dot - Omega_dotE) * tk - Omega_dotE * toe;
end

%%
function output = Satpos_ECEF(pos, Corr_long, corr_radius)
output = [pos(1, 1) * cos(Corr_long) - pos(2, 1) * cos(corr_radius) * sin(Corr_long);
    pos(1, 1) * sin(Corr_long) + pos(2, 1) * cos(corr_radius) * cos(Corr_long);
    pos(2, 1) * sin(corr_radius)];
end




%%%%%%%%% end satpos.m %%%%%%%%%
