function [KF, GNSS] = KF_Prep_GPS(KF, PVA, GNSS, c)
%EKF_TC_PREPHDZ Prepare H, dz, and R matrices for EKF
%   H   - differentiated pseudoranges matrix
%   dz  - observed - computed pseudoranges
%   R   - Pseudoranges weighting matrix

% update 29/09/2014

time    = GNSS.Obs_data(GNSS.i,7);
n_Sat   = GNSS.Obs_data(GNSS.i,8);
n_Satp  = GNSS.Obs_data(GNSS.i,8);
n_obs   = 10+n_Satp-1;

% Simulate GPS outage
GNSS.out_s =0; % flag of complete outage
if size(GNSS.outage ,1) ~= 0
    outage_s = GNSS.outage (1,1);
    outage_e = GNSS.outage (1,1)+GNSS.outage (1,2);
    if time > outage_s && time < outage_e
        if n_Sat >= GNSS.outage (1,3)
            n_Sat = GNSS.outage (1,3);
            if n_Sat == 0; 
                GNSS.out_s = 1; 
            elseif n_Sat > 1
                GNSS.out_s = 2;
            end
            fprintf('Simulating GPS outage time: %.2f, number of sats: %i\n', time, n_Sat)
        end
    elseif time > outage_e
        GNSS.outage (1,:) = [];
    end
end

% Simulate GPS multipath
if size(GNSS.multp ,1) ~= 0
    mult_s = GNSS.multp(1,1);
    mult_e = GNSS.multp(1,1) + GNSS.multp(1,2);
    time_m   = [time, mult_s, mult_e];
    if time > mult_s && time < mult_e
        GNSS = sim_multipath(GNSS, GNSS.multp(1,3), GNSS.multp(1,4), time_m);
        fprintf('Simulating multipath\n')
    elseif time > mult_e
        GNSS.multp(1,:) = [];
        if isfield(GNSS, 'mult_mag') == 1
            GNSS = rmfield(GNSS, 'mult_mag');
        end
    end
end

sats    = GNSS.Obs_data(GNSS.i,9:9+n_Sat-1)';
obs     = GNSS.Obs_data(GNSS.i,n_obs:n_obs+n_Sat-1)';

m       = size(obs,1);  % number of satellites

% identify ephemerides columns in GNSS.Eph
col_Eph = zeros(m,1);
for t = 1:m
    col_Eph(t) = feph_GPS(GNSS.Eph,sats(t),time);
end

%% Declarations
pos     = PVA.posE;
rec_cb  = PVA.rcb;

posG      = ecef2lla(pos'); 
posG(1:2) = posG(1:2)*pi/180;

H   = zeros(m,10);
hx  = NaN(m,1);
z   = NaN(m,1); 
dz  = NaN(m,1); 
R   = NaN(m,1);
ii = 1;

% Unit vector to satellites
GNSS.unit_v  = NaN(m,5);

for i = 1:m %go through each pseudorange/satellite
   
    k = col_Eph(i);
    
    %If ephemeris data does not have SV information
    if k == 0
        strd = ['Warning - Ephmeris data for satellite ', num2str(sats(i)), ' does not exist'];
        disp(strd);
        continue;
    end
    
    %Exclude SVN
    exc_SVN = find(GNSS.Exc_SVN==GNSS.Eph(1,k));
    if exc_SVN ~= 0;continue;end    
    
    %% Correct time
    tx_RAW  = time - obs(i)/c.v_light;
    toc     = GNSS.Eph(4,k);
    dt      = check_GPSt(tx_RAW-toc);
        
    f0 = GNSS.Eph(9,k); f1 = GNSS.Eph(10,k); f2 = GNSS.Eph(11,k);
    for n = 1:3
        dt = dt - (f0+f1*dt+f2*dt^2);
    end
    dt = f0+f1*dt+f2*dt^2;
    
    tx_GPS  = tx_RAW - dt;
    
    %% Calculate satellite position
    [X, tcorr] = possat_GPS(tx_GPS, GNSS.Eph(:,k), dt);
    
    dist        = sqrt(sumsqr(X-pos));
    traveltime  = dist / c.v_light;
    Rot_X       = rot_corr(traveltime,X); % correct sat pos
    
    %% Calculate Elevation, Azimuth and Distance from receiver to satellite
    [az,el,dist] = topocent(pos(1:3),Rot_X-pos(1:3),c.a,c.e_squared);    
    az = az*pi/180;el = el*pi/180; azel = [az,el];
    
    if PVA.fst ~= 1
        % Cut off angle
        if el <= GNSS.COA * pi/180
            if i == m; break;
            else continue; end
        end
    end
    
    %% Atmospheric correction
    if PVA.fst ~= 1
        td = Atm_trosaas(posG, azel);
        Id = Atm_ionklo(tx_GPS, GNSS, posG, azel, [], c);
    else
        td = 0; Id = 0;
    end  
    
    %% Calculate unit vector in ECEF directly
    dECEF   = Rot_X-pos(1:3);
    unitvE  = dECEF/dist;
    
    GNSS.unit_v(i,1:5)   = [sats(i) unitvE' obs(i)];    
    
    %% Measuremment, computed   
    z(ii)   = obs(i) + c.v_light * tcorr - td - Id;    
    distRS  = dist - rec_cb;
    hx(ii)  = distRS;  
    
    % Jacobian Matrix H
    H(ii,1) = -(Rot_X(1)-pos(1))/dist;
    H(ii,2) = -(Rot_X(2)-pos(2))/dist;
    H(ii,3) = -(Rot_X(3)-pos(3))/dist;
    H(ii,10) = -1;
        
    % Assign weight according to their elevation
    R(ii,1) = 1/sin(el);
  
    ii = ii + 1;
end % i
dz    = z - hx;
 
% Delete empty
H((H(:,1))==0,:)    =[];
hx(isnan(hx(:,1)),:)=[];
R(isnan(R(:,1)),:)  =[];
z(isnan(z(:,1)),:)  =[];
dz(isnan(dz(:,1)),:)=[];

%Create diagonal weighting matrix
R = (diag(R));

%check if non of the satellites are usable
if isempty(R)
    GNSS.out_s = 1;
end

% Unit vector
GNSS.unit_v(isnan(GNSS.unit_v(:,1)),:)=[];
GNSS.unit_v = sortrows(GNSS.unit_v,[1 2]); % Rearrage unit vectors

%% Assign
GNSS.H  = H;
GNSS.dz = dz; 
GNSS.R  = R;
GNSS.ns = size(R,1);

KF.H    = H;
KF.hx   = hx;
KF.z    = z; 
KF.dz   = dz; 
KF.R    = R;
