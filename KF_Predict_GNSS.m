function [KF, PVA] = KF_Predict_GNSS(KF, PVA)
%EKF_PREDICT
%   Predict state and covariance ahead
%   Estimation includes: Pos, Vel, Acc, rcb

%% 1. Predict State ahead x(k) = phi(k|k-1)x(k-1) + w(k)

% Define dynamic linear system - x^{dot} = F(t)x(t) + G(t)w(t), where F is
% the linearized dynamic model
% Need to transform the dynamic linear system from continuous to discrete
% time equations, x(k) = phi(k|k-1)x(k-1) + w(k),  achievable using:
% phi = I + F*dt
% w(k) - system noise with covariance matrix Q(k)
% Q(k) = G(tk) * Q.dt * G(tk)'
% G(tk) - coefficient matrix to shape the noise input at time t


%% predict f(x)
c_ne = C_en(PVA.posG)'; 

gn = [0; 0; 9.8065];
ge = c_ne * gn;

F0_33 = zeros(3,3);
F0_31 = zeros(3,1);
F0_13 = zeros(1,3);
 
F = [eye(3) eye(3)*PVA.dt   eye(3)*PVA.dt^2/2   F0_31 F0_31;
    F0_33   eye(3)          eye(3)*PVA.dt       F0_31 F0_31;
    F0_33   F0_33           eye(3)              F0_31 F0_31;
    F0_13   F0_13           F0_13               1     0;
    F0_13   F0_13           F0_13               0     1];

c = [ge*PVA.dt^2/2;
    ge*PVA.dt;
    F0_31;
    0;
    0];

KF.x = F*KF.x + c;

%% 2. Predict error covariance P(k) = phi(k|k-1) P(k-1) phi(k|k-1)' + Q(k)

% Q(k) = G(tk) * Q.dt * G(tk)'
% G(tk) - coefficient matrix to shape the noise input at time t

G   = [F0_33    F0_31 F0_31;
       F0_33    F0_31 F0_31;
       eye(3)   F0_31 F0_31;
       F0_13    1     0;
       F0_13    0     1];
       
%%   
Qk   = G * KF.q * G' * PVA.dt;
KF.p = F * KF.p * F' + Qk;

PVA.posE = KF.x(1:3);
PVA.rcb  = KF.x(10);
PVA.rcbg = KF.x(11);

end

