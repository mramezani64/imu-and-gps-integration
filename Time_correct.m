function [INS] = Time_correct(INS, GNSS)
%Initialize time

GNSSt   = GNSS.Obs_data(1,1:6);
year    = GNSSt(1,1)+2000;
month   = GNSSt(1,2);
day     = GNSSt(1,3);
hour    = GNSSt(1,4);
minute  = GNSSt(1,5);
second  = GNSSt(1,6);
jd          = julday(year,month,day,hour+minute/60+second/3600);
[week, sow] = jul2GPSt(jd);

for i = 1:size(INS.INS)   
    INS.INS(i,1) = INS.INS(i,1) + week*604800; % gpst from gpst0    
end

end

