function [KF] = KF_Prep_psv(KF,PVA)
%EKF_TC_PREPHDZ Prepare H, dz, and R matrices for EKF LC

% update 17/09/2014

C_eb  = PVA.C_be';
vel_e = PVA.vel;
vel_b = C_eb * vel_e;

ss_ve = INS_skew(vel_e); 

v     = C_eb * ss_ve;

C_en  = PVA.C_en;
vel_n = C_en * vel_e;
ss_vn = INS_skew(vel_n); 

vn    = C_en * ss_vn;

%% h(x)
% F_13  = zeros(1,3);
% F_116 = zeros(1,16);
% 
% H   = [ v(2,1:3) C_eb(2,1:3) F_116;
%     v(3,1:3) C_eb(3,1:3) F_116];
% 
% hx  = [0;0]; % virtual velocity
% 
% z   = [vel_b(2);vel_b(3)];
% 
% R   = diag([0.5 0.5]).^2;

F_13  = zeros(1,3);
F_114 = zeros(1,14);
F_15 = zeros(1,5);

H   = [F_13  C_eb(2,1:3) v(2,1:3)  F_114];

hx  = 0; % virtual velocity

z   = -vel_b(2);

R   = 0.05^2;


% H   = [F_13  C_eb(2,1:3) v(2,1:3)  F_114;
%        F_13  C_en(3,1:3) vn(3,1:3) F_114];
% 
% hx  = [0;0]; % virtual velocity
% 
% z   = -[vel_b(2);vel_n(3)];
% 
% R   = eye(2)*0.5^2;

%% Assign
KF.H    = H;
KF.hx   = hx;
KF.z    = z; 
KF.R    = R;


% keyboard