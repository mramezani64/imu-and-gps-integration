function t = adjweek( t, t0 )
%ADJWEEK adjust time considering week handover

tt = t - t0;

if tt<-302400.0 ; t = t + 604800; end
if tt> 302400.0 ; t = t - 604800; end


end

