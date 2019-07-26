function output = C_ne(PosGeo)
%C_ne - Navigation to Earth. function of Geographic coordinates

lat = PosGeo(1,1);
lon = PosGeo(1,2);

output = [-sin(lat)*cos(lon), -sin(lon) , -cos(lat)*cos(lon) ;
          -sin(lat)*sin(lon), cos(lon)  , -cos(lat)*sin(lon) ;
          cos(lat)          , 0         , -sin(lat)         ];

end
