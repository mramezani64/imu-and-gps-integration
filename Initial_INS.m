%% Initial INS Condition
%Modified by Milad Ramezani, 29/06/2015

% Initial Position - From GNSS
PVA.posE = GNSS.posE(1:3);
PVA.posG = GNSS.posG;

% Initial Attitude - User determined
%Milad%
% PVA.prh                 = [0 0 300]'; 
%for urban test
% PVA.prh                 = [0 0 160]';
% PVA.prh                 = [0 0 205]'; 
% PVA.prh                 = [0 0 340]'; 
PVA.prh                 = [0 0 340]'; 
[PVA.C_be, PVA.C_bn]    = INS_Att_Initial(PVA.prh,GNSS.posG);

% Initial Velocity - User determined
% PVA.vel = [.20 0.05 0.10]';% the velocity for urban test
PVA.vel = [0.00 0.00 0.00]';% the velocity for open-sky test
% Filtering - Initialize
% Define Initial sd for pos,vel,att,bias...
PVA.sd_pos  = [1 1 1]*5;
PVA.sd_vel  = [0.1 0.1 0.1]*5; %in metres
PVA.sd_att  = [1 1 1]*pi/180; %in radian (PRH)
PVA.sd_Bsag = [0.01 0.01 0.01 0.001 0.001 0.001]; % m/s/s, deg/s
% Milad%Dynamic bias is typically 10% of static one(Paul Groves)
PVA.sd_Bdag = [0.0001 0.0001 0.0001 0.000001 0.000001 0.000001]; % m/s/s, deg/s
% PVA.sd_Bdag = [0.0001 0.0001 0.0001 0.000001 0.000001 0.000001]; % m/s/s, deg/s
PVA.sd_RecClck = 1; %in metres

% Rearrange in blocks
PVA.sd_Init = [PVA.sd_pos,PVA.sd_vel,PVA.sd_att,PVA.sd_Bsag,PVA.sd_Bdag,PVA.sd_RecClck,PVA.sd_RecClck];

INS.n = size(INS.INS,1);

% Acceleration unit
% For INS MMQG we have got time integral of velocity(Delta_V_X,Y,Z:m/s)
% and time integral of angular rate(Delta_theta_X,Y,Z:degree)
% 100 is the rate of observation(100Hz)
INS.INS(:,2:4)  = INS.INS(:,2:4) * 100;
INS.INS(:,5:7)  = INS.INS(:,5:7) * 100 * pi/180;

% For INS 3DM_GX3_45 we have got acceleration in g unit
% and angular rate(turning rate) in radians/s
% INS.INS(:,2:4)  = INS.INS(:,2:4) * 9.806655;


% calculated bias
INS.INS(:,2:7)  = INS.INS(:,2:7) - repmat(INS.cb,INS.n,1);

% height during outage
h_out   = 0;
i_h     = 1;

% Initial receiver clock bias
PVA.rcb = GNSS.rcb;
if strcmp('GNSS',PVA.mode) == 1 && isempty(GNSS.Obs_data_R) == 0;
    PVA.rcbg = GNSS.rcbg;
else
    PVA.rcbg = 0;
end