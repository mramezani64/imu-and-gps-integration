%% Constants
%WGS84
c.a           = 6378137;              %radius at equator
c.b           = 6356752.314245;       %radius at polar
c.inv_flat    = 298.257223563;        %Inverse flattening
c.e_squared   = 0.00669437999014;     %e^2
c.E_ang_vel   = 0.00007292115;        %Earth angular velocity in radians
c.ss_E_ang_vel = [0 -c.E_ang_vel 0;     %Skew Symmetric matrix of E_ang_vel
                c.E_ang_vel 0 0;
                0 0 0 ];
c.v_light     = 299792458;
