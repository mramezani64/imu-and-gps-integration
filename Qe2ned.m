function Q_ned = GPS_Qe2ned( Q, PosGeo )
%GPS_DOPE2NED Converts the DOP from ECEF to NED
%   Q_ned = C_en_t * Q * C_en_t'

lat = PosGeo(1,1);
lon = PosGeo(1,2);

C_en_t = [-sin(lat)*cos(lon), -sin(lat)*sin(lon),cos(lat)   , 0 ;
          -sin(lon)         , cos(lon)          ,0          , 0;
          -cos(lat)*cos(lon), -cos(lat)*sin(lon), -sin(lat) , 0;
          0                 ,0                  ,0          , 1];
      
Q_tmp = [Q(1:4);Q(5:8);Q(9:12);Q(13:16)];  
      
Q_ned_tmp = C_en_t * Q_tmp * C_en_t';

Q_ned = [Q_ned_tmp(1,1:4) Q_ned_tmp(2,1:4) Q_ned_tmp(3,1:4) Q_ned_tmp(4,1:4)]; 

end

