function out = epoch2time( time )
% convert calendar day/time to gtime_t

    doy = [1,32,60,91,121,152,182,213,244,274,305,335];
    
    year = time(1); mon = time(2); day = time(3);
    
    if mod(year,4) == 0 && mon >= 3
        leapy = 1;
    else
        leapy = 0;
    end
    
    days = (year-1970)*365+(year-1969)/4+doy(mon)+day-2+leapy;            
    out  = days*86400+ time(4)*3600+ time(5)*60 + time(6);
    
end

