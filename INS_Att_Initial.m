function [C_be,C_BN] = INS_Att_Initial(PRH,PosGeo)
% Calculating the initial attitude in ECEF comprises two things
% C_be = C_ne * C_bn
% C_ne - function of Geographic coordinates
% C_bn - Initial DCM in navigation frame, function of Pitch Roll and Heading in the geographic frame

C_NE = INS_C_ne(PosGeo);
C_BN = C_bn_Initial(PRH*pi/180);

C_be = C_NE*C_BN;
% C_be = INS_Att_renorm(C_be);



end

function output = C_bn_Initial(PRH)
%C_bn - Initial DCM in navigation frame. function of pitch roll and heading

p = PRH(1);
r = PRH(2);
h = PRH(3);

cp      = cos(p); sp = sin(p); 
cr      = cos(r); sr = sin(r);
ch      = cos(h); sh = sin(h);

output = [ cp * ch     sr * sp * ch - cr * sh    cr * sp * ch + sr * sh ;
           cp * sh     sr * sp * sh + cr * ch    cr * sp * sh - sr * ch;
           -sp         sr * cp                   cr * cp];

end
