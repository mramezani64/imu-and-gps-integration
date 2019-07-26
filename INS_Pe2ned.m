function P_ned = INS_Pe2ned( P, C_en)
%INS_PE2NED Converts the Covariance P from ECEF to NED
%   P = C_en * P * C_en'

% Attitude, Velocity, Position
P_A = diag(C_en*P(1:3,1:3)*C_en')';
P_V = diag(C_en*P(4:6,4:6)*C_en')';
P_P = diag(C_en*P(7:9,7:9)*C_en')';

%Bias (acc,gyro) dynamic static
P_bad = diag(C_en*P(10:12,10:12)*C_en')';
P_bgd = diag(C_en*P(13:15,13:15)*C_en')';

P_bas = diag(C_en*P(16:18,16:18)*C_en')';
P_bgs = diag(C_en*P(19:21,19:21)*C_en')';

%Bias receiver clock
P_brcv = P(22,22);

P_ned = [P_A P_V P_P P_bad P_bgd P_bas P_bgs P_brcv]; 

end

