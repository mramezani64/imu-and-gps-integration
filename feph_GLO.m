function icol = feph_GLO(Eph,sv,time)
%FIND_EPH  Finds the proper column in ephemeris array

% rev 09/2014


icol = 0;
isat = find(Eph(1,:) == sv);
n = size(isat,2);

if n == 0
   return
end;

dt = [];

%Find the closest time!
for i = 1:n
    dt = [dt; abs(time - Eph(3,isat(i)))];
end

[C,I] = min(dt);

% check if dt is more than 15 minutes
if dt > 900
    fprintf('GLONASS ephemeris more than 15 minutes \n');
    return
end

icol = isat(I);




%%%%%%%%%%%%  find_eph.m  %%%%%%%%%%%%%%%%%
