function [KF, GNSS] = KF_Prep_GNSS(KF, PVA, GNSS, c)
%KF_Prep_GNSS Prepare H, dz, and R matrices for EKF

% rev 07/10/2014

% GPS
[KFG, GNSSG]  = KF_Prep_GPS(KF, PVA, GNSS, c);
KFG.H(:,11) = 0;

% GLONASS
[KF, GNSS] = KF_Prep_GLO(KF, PVA, GNSS, c);

%% Reassign
KF.H    = [KFG.H;  KF.H];
KF.hx   = [KFG.hx; KF.hx];
KF.z    = [KFG.z;  KF.z];
KF.dz   = [KFG.dz; KF.dz];
KF.R    = blkdiag(KFG.R, KF.R);

GNSS.ns_GPS = GNSSG.ns;
GNSS.ns_GLO = GNSS.ns;
GNSS.ns = GNSS.ns + GNSSG.ns;
GNSS.outage = GNSSG.outage;

end
