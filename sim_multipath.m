function GNSS = sim_multipath(GNSS, mag, nsatmul, time_m)
%sim_multipath  

i = GNSS.i;
nsat  = GNSS.Obs_data(i,8);
if isempty(nsatmul) == 1 || nsatmul > nsat
    nsatmul = nsat;
end

t  = time_m(1); % current time
ts = time_m(2); % start time
te = time_m(3); % end time

ti = (te-ts)/3;

tp  = floor((te-ts)*0.1);
stp = log(1:tp+1); stp = stp./max(stp);
stp2 = sort(stp,'descend');
tp  = [ts+tp, te-tp];


if t > ts && isfield(GNSS, 'mult_mag') == 0 % 1/3
    mult_mag = randn(nsatmul,1)*mag;
    GNSS.mult_mag{1} = mult_mag;
    GNSS.mult_mag{2} = 1;
    mult_mag = stp(1)*mult_mag;
elseif t > ts && t > ts + ti*2 && t < ts + ti*2+1 % 3/3
    mult_mag = randn(nsatmul,1)*mag;
    GNSS.mult_mag{1} = mult_mag;
    GNSS.mult_mag{2} = 1;
elseif t > ts && t > ts + ti*1 && t < ts + ti*1+1 % 2/3
    mult_mag = randn(nsatmul,1)*mag;
    GNSS.mult_mag{1} = mult_mag;    
    GNSS.mult_mag{2} = 1;
elseif t > ts && t <= te  % 1/3
    mult_mag = GNSS.mult_mag{1};   
    
    if t <= tp(1)
        ii = GNSS.mult_mag{2};
        mult_mag = stp(ii)*mult_mag;
        ii = ii + 1;
        GNSS.mult_mag{2} = ii;        
    elseif t >= tp(2)
        ii = GNSS.mult_mag{2};
        mult_mag = stp2(ii)*mult_mag;
        ii = ii + 1;
        GNSS.mult_mag{2} = ii;
    end    
    
end

obsori   = GNSS.Obs_data(i,9+nsat:8+nsat*2);
obsmultp = obsori(1:nsatmul)+mult_mag';

for ii = 1:nsatmul
    obsori(ii) = obsmultp(ii);
end

GNSS.Obs_data(i,9+nsat:8+nsat*2) = obsori;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
