function output = INS_Att_det(TR, ss_E_ang_vel, att, dt)
% Determine the new DCM (C_be) based on ; Turning rate, Earth angular vel
% previous attitude and transition time. Note that the skew symmetric of
% earth angular velocity vector has been defined in main.

%All will be formed as skew-symm matrix (ss)
ss_TR = INS_skew(TR);               % Turning Rate

term1 = att*(eye(3)+ dt*ss_TR);
term2 = ss_E_ang_vel * att * dt;

mat = term1; %-term2;

output = mat;

end

