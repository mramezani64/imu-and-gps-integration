function [LS, GNSS] = LS_Prep_GNSS(LS, PVA, GNSS, c)
%LS_PREP_GPS Summary of this function goes here
%   Detailed explanation goes here

% GPS
[LSGPS, GNSSGPS] = KF_Prep_GPS(LS, PVA, GNSS, c);
LSGPS.H(:,4) = LSGPS.H(:,10);
LSGPS.H(:,10:11) = 0;

% GLONASS
[LSGLO, GNSSGLO] = KF_Prep_GLO(LS, PVA, GNSS, c);
if isempty(LSGLO.H) == 0
    LSGLO.H(:,5)  = LSGLO.H(:,11);    
end


%% Reassign
LS.H    = [LSGPS.H;  LSGLO.H];
LS.hx   = [LSGPS.hx; LSGLO.hx];
LS.z    = [LSGPS.z;  LSGLO.z];
LS.dz   = [LSGPS.dz; LSGLO.dz];
LS.R    = blkdiag(LSGPS.R, LSGLO.R);

GNSS.ns_GPS = GNSSGPS.ns;
GNSS.ns_GLO = GNSSGLO.ns;
GNSS.ns     = GNSSGLO.ns + GNSSGPS.ns;
GNSS.outage = GNSSGPS.outage;

if isempty(LSGLO.H) == 0
    LS.H(:,6:11) = [];
else
    LS.H(:,5:11) = [];
end

if rank(LS.H) < 4 
    LS.flg = 1;
else
    LS.flg = 0;
end

end

