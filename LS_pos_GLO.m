function GNSS = LS_pos_GLO(GNSS,fst,c)
% pos_LS_GLONASS Computation of receiver position from pseudoranges
%          using Least Squares. The weighting of each pseudorange is
%          dependant on their elevation angles.


% rev 07/10/2014

m   = size(GNSS.Obs,1);  % number of satellites
flg = 0; % flag for < 4SVs

% identify ephemerides columns in GNSS.Eph
col_Eph = zeros(m,1);
for t = 1:m
    col_Eph(t) = feph_GLO(GNSS.Eph_R,GNSS.sats(t),GNSS.time);
end

%% Declarations
pos     = GNSS.posE';

if fst == 1
    no_iterations = 10; else no_iterations = 2;
end

% Unit vector to satellites
unit_v  = NaN(m,5);

for iter = 1:no_iterations
    
    %Allocate matrix
    A   = [];
    omc = [];
    W   = [];

    for i = 1:m %go through each pseudorange/satellite
        
        k = col_Eph(i);
        
        %If ephemeris data does not have SV information
        if k == 0
            if iter == 1
                strd = ['Warning - Ephmeris data for satellite ', num2str(GNSS.sats(i)), ' does not exist'];
                disp(strd);
            end
            continue;
        end
        
        %% Correct time
        tx_RAW = GNSS.time - GNSS.Obs(i)/c.v_light;
        
        taun   = GNSS.Eph_R(4,k);
        gamn   = GNSS.Eph_R(7,k);
        toeU   = GNSS.Eph_R(3,k);
        
        dt     = check_GPSt(tx_RAW-toeU);
        
        for n = 1:3
            dt = dt - (taun) + gamn*dt;
        end
        tcorr  = (taun) + gamn*dt;
        tx_GPS = tx_RAW - tcorr; % corrected time
        
        %% Calculate satellite position
        [X] = possat_GLO(tx_GPS, toeU, GNSS.Eph_R(:,k));
   
        if iter > 0 && iter < no_iterations
            dist        = sqrt(sumsqr(X-pos(1:3)));
            traveltime  = dist / c.v_light;
            Rot_X       = rot_corr(traveltime,X); % correct sat pos
            
            % Calculate Elevation, Azimuth and Distance from receiver to satellite
            [az,el,dist] = topocent(pos(1:3,:),Rot_X-pos(1:3,:),c.a,c.e_squared);
            az = az*pi/180;el = el*pi/180; azel = [az,el];

        elseif iter == no_iterations
            dist        = sqrt(sumsqr(X-pos(1:3)));
            traveltime  = dist / c.v_light;
            Rot_X       = rot_corr(traveltime,X); % correct sat pos
    
            % Calculate Elevation, Azimuth and Distance from receiver to satellite
            [az,el,dist] = topocent(pos(1:3,:),Rot_X-pos(1:3,:),c.a,c.e_squared);
            az = az*pi/180;el = el*pi/180; azel = [az,el];
            
            % Cut off angle
            if el <= GNSS.COA*pi/180;
                if i == m; break;
                else continue; end
            end
          
            % calculate unit vector in ECEF directly
            dECEF   = Rot_X-pos(1:3,:);
            Rrs     = sqrt(dECEF(1)^2+dECEF(2)^2+dECEF(3)^2);
            unitvE  = dECEF/Rrs;
            
            unit_v(i,1:5)   = [GNSS.sats(i) unitvE' GNSS.Obs(i)];
        end

                    
        %% Atmospheric correction
        if iter > 3
            td = Atm_trosaas(posG, azel);
            Id = Atm_ionklo(tx_GPS, GNSS, posG, azel, [], c);
        else
            td = 0; Id = 0;
        end

        %% Measuremment, computed
        z       = GNSS.Obs(i) + c.v_light * tcorr - td - Id;
        distRS  = dist - pos(4);
        hx      = distRS;
        
        omc = [omc; z - hx];
        % Jacobian Matrix A
        A   = [A;   (-(Rot_X(1)-pos(1)))/dist,(-(Rot_X(2)-pos(2)))/dist,(-(Rot_X(3)-pos(3)))/dist -1];
        % Assign weight according to their elevation
        W   = [W;   (1/sin(el))];
                        
    end % i
   
    
    %Create diagonal weighting matrix
    W = diag(W);
    
    %If there are less than 4 satellites, BERAK!
    n_SatV = size(A,1);
    n_Sat = m;
    if n_SatV < 4
        Q = [];
        flg = 1;
        break
    end           
    
    %Least Squares with weighting matrix
    x = (A'/W*A)\(A'/W*omc);
    Q = inv(A'/W*A);
    pos = pos+x;

    posG = ecef2lla(pos(1:3)');    
    
end % iter

unit_v(isnan(unit_v(:,1)),:)=[];
unit_v = sortrows(unit_v,[1 2]); % Rearrage unit vectors

%% Assign
GNSS.posE   = pos;
GNSS.Q      = Q;
GNSS.n_SatV = n_SatV;
GNSS.n_Sat  = n_Sat;
GNSS.flg    = flg;
GNSS.unit_v = unit_v;
GNSS.rcb    = pos(4);

%%%%%%%%%%%%%%%%%%%%%  recpo_ls.m  %%%%%%%%%%%%%%%%%%%%%

end