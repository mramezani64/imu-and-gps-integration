function KF = KF_Update(KF)
%EKF_TC_UPDATE 
%   3. Compute Kalman Gain 
%   4. Update estimate with measurement z
%   5. Update error covariance

%% 3. Compute Kalman gain
KF.K = KF.p * KF.H' / (KF.H * KF.p * KF.H' + KF.R);
 
%% 4. Update estimate with measurement z
KF.omc = KF.z - KF.hx;
% KF.omc = KF.dz - KF.H * KF.x;
KF.x   = KF.x + KF.K * KF.omc;

%% 5. Update error covariance
n = size(KF.p,1);
KF.p = (eye(n)-KF.K * KF.H) * KF.p;
    
end

