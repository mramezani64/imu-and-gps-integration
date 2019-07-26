function output = INS_Att_C2Euler(DCM)
%convert get euler angles from Cbn
% DCM: Direction Cosine Matrix
mat_1 = [-asin(DCM(3, 1));
    atan2(DCM(3, 2), DCM(3, 3));
    atan2(DCM(2, 1), DCM(1, 1))];

mat_1 = mat_1*180/pi;

if mat_1(3, 1) < 0
    mat_1(3, 1) = mat_1(3, 1) + 360;
elseif  mat_1(3, 1) >= 360
    mat_1(3, 1) = mat_1(3, 1) - 360;
end

output = mat_1;

end