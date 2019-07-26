function output = INS_Re(lat,a,e_squared)
% Tranverse radius of curvature. (Normal) in the East-West Direction
    
    output = a / ((1 - e_squared * sin(lat) ^ 2) ^ (1 / 2));

end

