function output = INS_Att_renorm(Att)
%renormalize the DCM. DCM may not be orthogonal due to the uneven input
%from INS (scaling factor, bias...)

mat1 = Att(1,:);
mat2 = Att(2,:);

DP = dot(mat1,mat2);

mat3 = mat1;

%renormalize row 1 and 2
mat1 = mat1 - DP / 2 * mat2;
mat2 = mat2 - DP / 2 * mat3;

DP = dot(mat1,mat2);

%renormalize row 3;
mat3 = cross(mat1,mat2);

mag1 = norm(mat1);
mag2 = norm(mat2);
mag3 = norm(mat3);

output = [mat1/mag1 ; mat2/mag2 ; mat3/mag3];

end