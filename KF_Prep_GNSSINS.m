function [KF, GNSS] = KF_Prep_GNSSINS(KF, PVA, GNSS, c)
%KF_Prep_GNSS Prepare H, dz, and R matrices for EKF
% rev 07/10/2014

% GPS
[KFG, GPS]  = KF_Prep_GPS(KF, PVA, GNSS, c);
KFG.H(:,KF.nx-1) = KFG.H(:,10);
KFG.H(:,KF.nx)   = 0;
KFG.H(:,10)      = 0;
GNSS.out_s       = GPS.out_s;

% GLONASS
[KF, GLO]    = KF_Prep_GLO(KF, PVA, GNSS, c);
if isempty(KF.H) == 0 
KF.H(:,KF.nx) = KF.H(:,11);
KF.H(:,11)    = 0;
end

%% Reassign
KF.H    = [KFG.H;  KF.H];
KF.hx   = [KFG.hx; KF.hx];
KF.z    = [KFG.z;  KF.z];
KF.dz   = [KFG.dz; KF.dz];
KF.R    = blkdiag(KFG.R, KF.R);

GNSS.ns_GPS = GPS.ns;
GNSS.ns_GLO = GLO.ns;
GNSS.ns = GLO.ns + GPS.ns;

GNSS.out_s  = GPS.out_s;
GNSS.outage = GPS.outage;
GNSS.multp  = GPS.multp;
if isfield(GPS, 'mult_mag') == 1     
    GNSS.mult_mag  = GPS.mult_mag;
end
if isfield(GPS, 'mult_mag') == 0  && isfield(GNSS, 'mult_mag') == 1 
    GNSS = rmfield(GNSS, 'mult_mag');
end

end
