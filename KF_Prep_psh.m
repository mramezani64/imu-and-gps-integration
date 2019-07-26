function [KF] = KF_Prep_psh(KF, PVA, Vh, c)
%EKF_TC_PREPHDZ Prepare H, dz, and R matrices for EKF LC

% update 17/09/2014

cLat  = cos(PVA.posG(1));sLat  = sin(PVA.posG(1));
cLon  = cos(PVA.posG(2));sLon  = sin(PVA.posG(2));
h     = PVA.posG(3);

Rn  = c.a/sqrt(1-c.e_squared*sLat^2);

H = [(c.a*c.e_squared*cLat^2*cLon*sLat)/(1 - c.e_squared*sLat^2)^(3/2) - cLon*sLat*(h + Rn), -cLat*sLon*(h + Rn), cLat*cLon;
    (c.a*c.e_squared*cLat^2*sLat*sLon)/(1 - c.e_squared*sLat^2)^(3/2) - sLat*sLon*(h + Rn), cLat*cLon*(h + Rn), cLat*sLon;
    cLat*(h - (c.a*(c.e_squared - 1))/(1 - c.e_squared*sLat^2)^(1/2)) - (c.a*c.e_squared*cLat*sLat^2*(c.e_squared - 1))/(1 - c.e_squared*sLat^2)^(3/2), 0, sLat];

H = inv(H);

%% h(x)

F_13 = zeros(1,3);
F_11 = zeros(1,1);

H   = [ F_13 F_13 -H(3,1:3) F_13 F_13 F_13 F_13 F_11];
hx  = h  ;

z   = Vh;

R   = 0.5^2;

%% Assign
KF.H    = H;
KF.hx   = hx;
KF.z    = z; 
KF.R    = R;
