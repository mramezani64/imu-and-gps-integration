function [ Q ] = INS_QuatInit( C )
%INS_QUATINIT Compute initial Quaternion parameters
%   Cbn - Direction cosine matrix, rotation from body to navigation
Q = zeros(4,1);

Q(1,1) =  0.5*sqrt(1+C(1,1) + C(2,2) + C(3,3));
Q(2,1) = (C(3,2)-C(2,3))/(4*Q(1,1));
Q(3,1) = (C(1,3)-C(3,1))/(4*Q(1,1));
Q(4,1) = (C(2,1)-C(1,2))/(4*Q(1,1));

end

