function PVA = INS_MechE(PVA, INS, c)
%INS_MECH Main body for INS Mechanization in ECEF

C_EN    = INS_C_en(PVA.posG);
PVA.C_en = C_EN;
C_bn     = PVA.C_bn;
% C_EN    = INS_Att_renorm(C_EN);

% time
dt      = INS.INS(INS.i+1,1) - INS.INS(INS.i,1);

% IMU inertial measurements
f   = INS.INS(INS.i,2:4)' - PVA.eb(1:3,1);% f is force
w   = INS.INS(INS.i,5:7)' - PVA.eb(4:6,1);%w is turining rate

PVA.w = w;

%% Acceleration
%Acceleration - transform body to ECEF frame
g_n  = [0 ; 0 ; INS_gravity(PVA.posG(1), PVA.posG(3))];   %Gravity in Navigation
g_e  = C_EN' * g_n;                         %Gravity in ECEF

PVA.f_eb = PVA.C_be * f;
PVA.f_e  = PVA.f_eb + g_e; % - 2 * c.ss_E_ang_vel * PVA.vel;

% Acceleration - transform body to NED frame
PVA.f_n = PVA.C_bn * f + g_n;
PVA.g   = g_e;

%% Velocity
PVA.vel  = PVA.vel + PVA.f_e * dt;

%% Position
PVA.posE = PVA.posE + PVA.vel * dt + PVA.f_e*(dt^2)/2;

% Ecef to Geodetic (rad)
PVA.posG        = ecef2lla(PVA.posE')';
PVA.posG(1:2)   = PVA.posG(1:2)*pi/180;


%% Update Attitude

% Rotation matrix
PVA.C_be = INS_Att_det(w, c.ss_E_ang_vel, PVA.C_be, dt);

% Quaternions
% PVA.quat = Att_updateQ(dt, PVA.quat, w );
% PVA.C_bn = INS_Att_Q2C(PVA.quat);

% Pitch roll heading
% PVA.prh = Att_updatePRH(PVA.prh, w, dt);
% [PVA.C_be, PVA.C_bn] = INS_Att_Initial(PVA.prh,PVA.posG);

PVA.C_bn = C_EN * PVA.C_be ;
PVA.C_bn = INS_Att_renorm(PVA.C_bn); % !important

PVA.prh = INS_Att_C2Euler(PVA.C_bn);

[PVA.C_be, PVA.C_bn]  = INS_Att_Initial(PVA.prh,PVA.posG);
% PVA.quat = INS_QuatInit(PVA.C_bn);



end

