function [gpst, week] = time2gpst( t )
%TIME2GPST gtime_t struct to week and tow in gps time

gpst0   = [1980,1,6,0,0,0];
t0      = epoch2time(gpst0);
sec     = t - t0;
week    = floor(sec/(86400*7));

gpst = (sec-week*86400*7);
end

