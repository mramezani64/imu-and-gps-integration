function output = INS_gravity(lat, height)
% Calculates the gravity, as a function of latitude and height
format long

    output = 9.780327 * (1 + 0.0053024 * sin(lat) ^ 2 - 0.0000058 * sin(2 * lat) ^ 2) - (3.086 * 10 ^ -6) * height;

end

