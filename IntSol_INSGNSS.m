function [PVA, KF, GNSS] = IntSol_INSGNSS(PVA, KF, GNSS)
%EKF_INTSOL Calculates the integrated solution
%   Last update 11/10/2014

%update INS bias (Dynamic and static)
PVA.ebd = PVA.ebd - KF.x(16:21);    % dynamic
PVA.ebs = PVA.ebs - KF.x(10:15);    % static
PVA.eb  = PVA.ebd + PVA.ebs;          % dynamic + static

dx_att   = KF.x(7:9);
PVA.C_be = (eye(3) + INS_skew(dx_att))*PVA.C_be; %%%%

%update velocity and position
PVA.vel = PVA.vel  + KF.x(4:6);
PVA.posE= PVA.posE + KF.x(1:3);

% Ecef to Geodetic (rad)
PVA.posG        = ecef2lla(PVA.posE')';
PVA.posG(1:2)   = PVA.posG(1:2)*pi/180;

%re-calculate prh
C_EN    = INS_C_en(PVA.posG);
C_BN    = C_EN * PVA.C_be;
PVA.prh = INS_Att_C2Euler(C_BN);

%update receiver clock bias
PVA.rcb  = PVA.rcb  + KF.x(22);
PVA.rcbg = PVA.rcbg + KF.x(23);

% Reset errors 
KF.x(1:KF.nx) = 0;

PVA.C_bn = C_EN * PVA.C_be ;
PVA.C_bn = INS_Att_renorm(PVA.C_bn); % !important

PVA.prh = INS_Att_C2Euler(PVA.C_bn);

[PVA.C_be, PVA.C_bn]  = INS_Att_Initial(PVA.prh,PVA.posG);

end

