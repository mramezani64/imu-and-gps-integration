function [KF, PVA] = KF_Predict_INSGNSS(KF, PVA, INS, c)
%EKF_PREDICT 
%   Predict state and covariance ahead

%% 1. Predict State ahead x(k) = phi(k|k-1)x(k-1) + w(k)
  
lat     = PVA.posG(1);
pos     = PVA.posE;

%Gravity components
G0 = 9.7803253359 * (1 + 0.001931853 * sin(lat) ^ 2) / sqrt(1 - c.e_squared * sin(lat) ^ 2);
r_es = INS_Re(lat,c.a,c.e_squared) * sqrt(cos(lat) ^ 2 + (1 - c.E_ang_vel) ^ 2 * sin(lat) ^ 2);

r_mag  = sqrt(pos(1)^2 + pos(2)^2 + pos(3)^2);
r_r_mag = (2 * G0 / r_es) * pos / (r_mag ^ 2);

gtensor = r_r_mag*pos';

% Initialize transition (F) matrix
F0_33 = zeros(3,3);
F0_13 = zeros(1,3);
F0_31 = zeros(3,1);

% Position, Velocity and Attitude
%Position
Frv = eye(3);

%Velocity
Fvr = gtensor;              % position
Fvv = -2*c.ss_E_ang_vel;    % velocity
% Fvv = F0_33;    % velocity
Fva = -INS_skew(PVA.f_eb);  % attitude

Fvbf  = PVA.C_be;
Fvbfd = PVA.C_be;

%attitude
Faa = -c.ss_E_ang_vel;
% Faa = F0_33;
Fabw  = PVA.C_be;
Fabwd = PVA.C_be;

%bias dynamic, Acceleration - Gauss Markov
Fbfd = -diag(INS.bs(1:3,2).^-1);
% Fbfd = zeros(3,3);

%bias dynamic, turning rate - Gauss Markov
Fbwd = -diag(INS.bs(4:6,2).^-1);
% Fbwd = zeros(3,3);

% Construct F matrix
F = [F0_33  Frv     F0_33   F0_33   F0_33   F0_33 	F0_33	F0_31 F0_31; %Pos
     Fvr    Fvv     Fva     Fvbf    F0_33   Fvbfd 	F0_33	F0_31 F0_31; %Vel
     F0_33	F0_33   Faa     F0_33   Fabw   	F0_33   Fabwd  	F0_31 F0_31; %Att
     F0_33  F0_33   F0_33   F0_33   F0_33   F0_33   F0_33 	F0_31 F0_31; %bf
     F0_33  F0_33   F0_33   F0_33   F0_33   F0_33   F0_33 	F0_31 F0_31; %bw
     F0_33  F0_33   F0_33   F0_33   F0_33   Fbfd    F0_33  	F0_31 F0_31; %bfd
     F0_33  F0_33   F0_33   F0_33   F0_33   F0_33   Fbwd    F0_31 F0_31; %bwd
     F0_13  F0_13   F0_13   F0_13   F0_13   F0_13   F0_13   0     0; %RecBias
     F0_13  F0_13   F0_13   F0_13   F0_13   F0_13   F0_13   0     0];    %RecBias

% Transform the dynamic linear system from continuous to discrete-time equation
phi = eye(KF.nx,KF.nx) + F*PVA.dt;

% Predict State ahead x(k) = phi(k|k-1)x(k-1)
KF.x = phi*KF.x;

%% 2. Predict error covariance P(k) = phi(k|k-1) P(k-1) phi(k|k-1)' + Q(k)

% Q(k) = G(tk) * Q.dt * G(tk)'
% G(tk) - coefficient matrix to shape the noise input at time t

% G = 22 x 13
G = [F0_33      F0_33       F0_33       F0_33   F0_31	F0_31;
    PVA.C_be    F0_33       F0_33       F0_33   F0_31	F0_31;
    F0_33       PVA.C_be    F0_33       F0_33   F0_31	F0_31;
    F0_33       F0_33       F0_33       F0_33   F0_31	F0_31;
    F0_33       F0_33       F0_33       F0_33   F0_31	F0_31;
    F0_33       F0_33       eye(3)      F0_33   F0_31	F0_31;
    F0_33       F0_33       F0_33       eye(3)  F0_31	F0_31;
    F0_13       F0_13       F0_13       F0_13   1    	0;
    F0_13       F0_13       F0_13       F0_13   0       1    ];

Qk = G * (KF.q * PVA.dt) * G';

KF.p = phi * KF.p * phi' + Qk;

end

