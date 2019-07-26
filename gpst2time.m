function [ t ] = gpst2time( week, sec )
%GPST2TIME convert week and tow in gps time to gtime_t struct

gpst0   = [1980,1,6,0,0,0];
t       = epoch2time(gpst0);
t       = t + 86400*7*week + sec;

end

