function KF = KF_Initialize_GNSS(PVA)
%EKF_INITIALIZE Initialize parameters

% Initial Pos, vel, att(PRH)
x(1:3)  = PVA.posE;
x(4:6)  = PVA.vel;
x(7:9)  = PVA.acc;
x(10)   = PVA.rcb;
x(11)   = PVA.rcbg;

P       = diag(PVA.sd_Init).^2;

%% Q = 6 x 6
% PSD 

sd_a    = eye(3)*10 ;      % acceleration 
sd_rcb  = 0.05;

% Construct Q matrix
Q = blkdiag(sd_a,sd_rcb,sd_rcb).^2;

%% Assign
KF.x = x';
KF.p = P;
KF.q = Q;

end

