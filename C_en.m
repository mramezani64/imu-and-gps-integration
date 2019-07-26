function output = C_en(PosGeo)
%C_en - Earth to navigation. calls the C_ne and transpose

lat = PosGeo(1);
lon = PosGeo(2);

output = [-sin(lat)*cos(lon), -sin(lat)*sin(lon),cos(lat) ;
          -sin(lon)         , cos(lon)          , 0;
          -cos(lat)*cos(lon), -cos(lat)*sin(lon), -sin(lat)];
end
