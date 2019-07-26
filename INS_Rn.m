function output = INS_Rn(lat,a,e_squared)
% Meridian radius of curvature. (Normal) in the North-South Direction
format long
    
    output = (a * (1 - e_squared)) / ((1 - e_squared * sin(lat) ^ 2) ^ (3 / 2));

end

