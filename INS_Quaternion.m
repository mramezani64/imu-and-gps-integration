function [q, q_Cbn ] = INS_Quaternion( q, w, dt )
%INS_QUATERNION Update and normalize quaternion vector
%   DC - integration drift correction

x = w(1);
y = w(2);
z = w(3);



W = [0 -x -y -z;
    x 0 z -y;
    y -z 0 x;
    z y -x 0];

dc = [(1-(q(1)^2 + q(2)^2 + q(3)^2 + q(4)^2)) * q(1);
    (1-(q(1)^2 + q(2)^2 + q(3)^2 + q(4)^2)) * q(2);
    (1-(q(1)^2 + q(2)^2 + q(3)^2 + q(4)^2)) * q(3);
    (1-(q(1)^2 + q(2)^2 + q(3)^2 + q(4)^2)) * q(4)];

q = q + (0.5*W*q+dc)*dt;

q_Cbn = [q(1)^2+q(2)^2-q(3)^2-q(4)^2    2*(q(2)*q(3)-q(1)*q(4))         2*(q(1)*q(3)+q(2)*q(4));
    2*(q(2)*q(3)+q(1)*q(4))         q(1)^2-q(2)^2+q(3)^2-q(4)^2     2*(q(3)*q(4)-q(1)*q(2));
    2*(q(2)*q(4)-q(1)*q(3))         2*(q(3)*q(4)+q(1)*q(2))         q(1)^2-q(2)^2-q(3)^2+q(4)^2];

end

