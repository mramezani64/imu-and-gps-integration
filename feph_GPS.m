function icol = feph_GPS(Eph,sv,time)
%FIND_EPH  Finds the proper column in ephemeris array

% by Azmir Hasnur Rabiain (06/02/2012) Some of the codes were adopted from
% Easy Suite II by Kai Borre $31-10-2001$. codes here have been modified to
% find the closest time.

% rev 05/07/2013


icol = 0;
isat = find(Eph(1,:) == sv);
n = size(isat,2);

if n == 0
   return
end;

dt = zeros(n,1);

epht = [];

%Find the closest time!
for i = 1:n
    toc   = Eph(4,isat(i));
    epht  = [epht,Eph(:,isat(i))];
    
    dt(i) = abs(time - toc);
end

[C,I] = min(dt);

if C > 86400
    return
end

icol = isat(I);

%%%%%%%%%%%%  find_eph.m  %%%%%%%%%%%%%%%%%
