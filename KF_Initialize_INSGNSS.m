function KF = KF_Initialize_INSGNSS(PVA, INS)
%EKF_INITIALIZE Initialize parameters

KF.nx = size(PVA.sd_Init,2);

x = zeros(KF.nx,1);
P = diag(PVA.sd_Init).^2;

%% Q = 13 x 13
% PSD 

% Velocity random walk
VRW = diag(INS.rw(1:3)).^2;

% Angle Random walk
ARW = diag(INS.rw(4:6)*pi/180).^2;

% Acceleration Bias dynamic
Qbd = zeros(6,1);
for i = 1:3
    Qbd(i,1) = sqrt(2 * INS.bs(i,1)^2 / INS.bs(i,2));
end
ABd = diag(Qbd(1:3));

% Turning rate Bias dynamic
for i = 4:6
    Qbd(i,1) = sqrt(2 * (INS.bs(i,1)*pi/180)^2 / INS.bs(i,2));
end
GBd = diag(Qbd(4:6));

sd_rcb  = 1;

% Construct Q matrix
Q = blkdiag(VRW, ARW, ABd, GBd, sd_rcb^2, sd_rcb^2);

%% Assign
KF.x = x;
KF.p = P;
KF.q = Q;


end

