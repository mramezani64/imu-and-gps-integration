function [LS] = WLS( LS )
%WLS Summary of this function goes here
%   Detailed explanation goes here
 
if rank(LS.H) < 4 ; LS.flg = 1; return; else LS.flg = 0; end

LS.x   = (LS.H'/LS.R*LS.H)\(LS.H'/LS.R*LS.dz);
LS.Q   = inv(LS.H'/LS.R*LS.H);

end

