function output = INS_skew(mat)
% Meridian radius of curvature. (Normal) in the North-South Direction
    
    output = [0     -mat(3)     mat(2) ;
            mat(3)  0           -mat(1);
            -mat(2) mat(1)      0 ];

end

