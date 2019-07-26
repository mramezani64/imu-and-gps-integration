% Modified by Milad Ramezani 29/06/2015
% This script applied for open sky area

clear all;close all;clc;tic
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%% Error State INS/GPS Integration %%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')

warning('off','all')

run('Constants.m')


%% Load INS, GPS, OBD

% load INS
load('OS_INS.mat');

INS.rw = INS.bw;
INS.INS(:,1) = INS.INS(:,1);

% load GPSRINEX
load('OS_GNSS.mat');



%% Mode
% Constrain mode 0 - N/A; 1 - vel; 2 - vel & height
Cmode = 1;

% Vel sensor mode 0 - N/A; 1 - Act
Vmode = 1;

% RAIM Mode 0 - N/A; 1 - Act
raim.m  = 1;
%1000 for UA
raim.te = 100; % exclude time

% +GLONASS %
PVA.mode = 'GNSS';

% output name
run('OutName.m')


%% Correct INS time
INS = Time_correct(INS, GNSS);


%% User defined parameters
GNSS.COA     = 0;   % Satellite Cut off angle
GNSS.UERE    = 5;    % User equivalent range error
%for UA
% Ptime   = [INS.INS(2100,1)  INS.INS(size(INS.INS,1),1)];   % Process time
Ptime   = [INS.INS(1,1)  INS.INS(size(INS.INS,1),1)];   % Process time

%% INS bias (calculated)
INS.cb = [0,0,0,0,0,0];
% keyboard

%% User defined simulated GPS total/partial outages
% Start time, duration (seconds), number of satellites. Example [510765,30,3; 510835,30,3; 510880,30,3];
GNSS.out_s    = 0; % Status
GNSS.outage   = [];

% simulate multipath
% Start time, duration (seconds), magnitude (m), n affected sat [1089438351,30,500,5];
GNSS.multp    = [];

% Exclude SVN. Example [11;15;32]
GNSS.Exc_SVN  = [];


%% Start to match GPS, INS, OBDII time
% return the ith position of arrays
INS.i = 1; GNSS.i = 1; OBD.i = 1;
[INS.i, GNSS.i] = InitTime( INS.INS,   GNSS.Obs_data, INS.i, GNSS.i, 1 , 7, Ptime);
[INS.i, GNSS.i] = InitTime( INS.INS,   GNSS.Obs_data, INS.i, GNSS.i, 1 , 7, Ptime);

% keyboard
%% Initial Condition
run('Initial_GNSS.m')
run('Initial_INS.m')

raim.mu   = 0;
raim.sig2 = 10;
raim.sig  = sqrt(raim.sig2);

KF = KF_Initialize_INSGNSS(PVA,INS);


%% Initialize arrays
PVA.PVA     = NaN(size(INS.INS,1)-INS.i, 7);
PVA.P       = NaN(INS.n-INS.i, (KF.nx-2)*3+3);
PVA.PVA_Geo = NaN(INS.n-INS.i, 10);
PVA.P_Geo   = NaN(INS.n-INS.i, 16); % KF.nx+1);
PVA.Ns      = NaN(INS.n-INS.i, 5);

PVA.Dx      = NaN(INS.n-INS.i, KF.nx);
PVA.Eb      = NaN(INS.n-INS.i, 19);
PVA.F_n     = NaN(INS.n-INS.i, 9);
PVA.SatPlot = NaN(GNSS.n-GNSS.i,32*4); % allocate space for 32 sats

PVA.ebd     = zeros(6,1);   %EKF estimated dynamic bias
PVA.ebs     = zeros(6,1);   %EKF estimated static bias
PVA.eb      = zeros(6,1);   %EKF estimated overall bias
PVA.RCB     = NaN(INS.n-INS.i, 3);

PVA.f_n     = zeros(3,1);   %EKF estimated dynamic bias
PVA.f_e     = zeros(3,1);   %EKF estimated dynamic bias

raim.dm     = NaN(INS.n-INS.i, 5);
raim.m1     = 0; % RAIM true
raim.m2     = 0; % RAIM detected
raim.m3     = 0; % norm of original innovation
raim.m4     = 0; % norm of innovation after rejection

j = 1;


%% Start Mechanizing INS and integrate with GPS
fprintf('Calculating INS/GPS Integration... \n\n')
tic; ii   = INS.i;
init_time = INS.INS(INS.i,1)+raim.te;
for i = INS.i+1:INS.n - 10
    
    perc  = i/ INS.n* 100;
%     if perc >=10.75
%         keyboard
%     end
    fprintf('%.2f %%, time - %.2f\n',perc, INS.INS(INS.i,1));
    
    INS.i = i;
    flg = check_Ptime(INS, Ptime);
    if flg == 1; break; end
    
    %% INS mechanization
    PVA = INS_MechE(PVA, INS, c);
    
    
    %% Extended Kalman Filter
    % Predict error estimates and covariances
    PVA.dt    = INS.INS(i+1,1) - INS.INS(i,1);
    [KF, PVA] = KF_Predict_INSGNSS(KF, PVA, INS, c);
    
        
    %% GNSS update & constraints
    if INS.INS(i,1) >= GNSS.Obs_data(GNSS.i,7) && GNSS.i < GNSS.n
        
        % End if reach GPS end point
        if GNSS.i == GNSS.n-1;break;end
        
        % Prepare H,dz and R matrices & simulate GPS outages
        [KF, GNSS] = KF_Prep_GNSSINS(KF, PVA, GNSS, c);
        [KF, GNSS, raim] = RAIM(KF, PVA, GNSS, raim, [INS.INS(INS.i,1), init_time]);
               
        GNSS.i = GNSS.i + 1;
        
        if GNSS.out_s == 0 || GNSS.out_s == 2;
            % Update error estimates and covariances
            KF              = KF_Update(KF);
            [PVA, KF, GNSS] = IntSol_INSGNSS(PVA, KF, GNSS);
        end
        
        
        %% Constraints
        % 0 = full ava; 1 = complete outage; 2 = partial outage
        if GNSS.out_s == 1 || GNSS.out_s == 2
            if Cmode == 1 || Cmode == 2
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % velocity constraint
                KF = KF_Prep_psv(KF, PVA);
                
                KF = KF_Update(KF);
                [PVA, KF, GNSS] = IntSol_INSGNSS(PVA, KF, GNSS);
            end
            if Cmode == 2
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % height constraint
                % record last height
                if i_h == 1;
                    h_out = PVA.posG(3);
                    i_h   = 0;
                end
                %Prepare H,dz and R matrices
                KF = KF_Prep_psh(KF, PVA, h_out, c);
                KF = KF_Update(KF);
                [PVA, KF, GNSS] = IntSol_INSGNSS(PVA, KF, GNSS);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
        end
        
        
    end
        
    
    %% Save save save!    
    time = INS.INS(INS.i,1);
    
    % Save ECEF Pos, Vel and C_be
    PVA.PVA(j,1:7) = [time PVA.posE' PVA.vel'];
    PVA.P(j,:)     = [time reshape(KF.p(1:3,1:3),1,[])      reshape(KF.p(4:6,4:6),1,[])     reshape(KF.p(7:9,7:9),1,[])...
        reshape(KF.p(10:12,10:12),1,[])  reshape(KF.p(13:15,13:15),1,[]) reshape(KF.p(16:18,16:18),1,[]),...
        reshape(KF.p(19:21,19:21),1,[])  KF.p(22,22) KF.p(23,23)];
    
    % Save Geo Pos, NED Vel, prh
    C_en            = INS_C_en(PVA.posG);
    velNED          = C_en * PVA.vel;
    
    P_Geo1          = diag(C_en*KF.p(1:3,1:3)*C_en');
    P_Geo2          = diag(C_en*KF.p(4:6,4:6)*C_en');
    P_Geo3          = diag(C_en*KF.p(7:9,7:9)*C_en');
    P_Geo4          = diag(KF.p(10:12,10:12));
    P_Geo5          = diag(KF.p(13:15,13:15));
    
    PVA.PVA_Geo(j,1:10) = [time PVA.posG' velNED' PVA.prh' ];
    PVA.P_Geo(j,:)      = [time P_Geo1' P_Geo2' P_Geo3' P_Geo4' P_Geo5'];
    
    PVA.F_n(j,:)    = [time PVA.f_n' norm(PVA.f_n) PVA.g' norm(PVA.vel)];
    
    C_eb  = PVA.C_be';
    vel_e = PVA.vel;
    vel_b = C_eb * vel_e;
    
    if  sqrt(sumsqr(C_eb(1,1:3))) ~= 1 || sqrt(sumsqr(C_eb(2,1:3))) ~= 1  || sqrt(sumsqr(C_eb(3,1:3))) ~= 1
        aa = sqrt(sumsqr(C_eb(1,1:3)))-1;
        bb = sqrt(sumsqr(C_eb(2,1:3)))-1;
        cc = sqrt(sumsqr(C_eb(3,1:3)))-1;
        if abs(aa) > 0.0000000001 || abs(bb) > 0.0000000001 || abs(cc) > 0.0000000001
            keyboard
        end
    end
    
    vel_n = PVA.C_en * vel_e;
    
    % Bias and nsat
    PVA.Eb(j,1:19)  = [time PVA.eb' vel_b' vel_n' PVA.ebs'] ; % Save estimated bias
    
    if isfield(GNSS,'ns') == 1
        PVA.Ns(i,:) = [time GNSS.ns GNSS.ns_GPS GNSS.ns_GLO GNSS.rem];
    end
    
    PVA.RCB(j,:)    = [time PVA.rcb  PVA.rcbg];
       
    
    % RAIM
    raim.dm(j,:)    = [time raim.m1  raim.m2  raim.m3  raim.m4];
    
    
    %% idx j
    j=j+1;
       
    
end
fprintf('\nFinished calculation. Calculation took %f seconds. \n', toc)


%% Delete empty cells
PVA.PVA(any(isnan(PVA.PVA),2),:)=[];
PVA.P(any(isnan(PVA.P),2),:)=[];
PVA.PVA_Geo(any(isnan(PVA.PVA_Geo),2),:)=[];
PVA.Ns(any(isnan(PVA.Ns),2),:)=[];
% PVA.Zvel(any(isnan(PVA.Zvel),2),:)=[];
PVA.raim = raim;

%% Save
save(f_out_m,'PVA' )


%% Figure
run('Plot.m')


%% Plot KML
nPVA = size(PVA.PVA_Geo,1);

st  = 1;    % start
stp = 50;   % step
en  = nPVA; % end

idx_time    = 1; %index time
idx_Lat     = 3; %index lat
idx_Long    = 2; %index long
idx_height  = 4; %index height

f_out_kc = 'red'; % colour

clear PosGeokml;
PosGeokml(:,1)  = PVA.PVA_Geo(st:stp:en,idx_time)-PVA.PVA_Geo(1,idx_time);
PosGeokml(:,2)  = PVA.PVA_Geo(st:stp:en,idx_Lat)*180/pi;
PosGeokml(:,3)  = PVA.PVA_Geo(st:stp:en,idx_Long)*180/pi;
PosGeokml(:,4)  = PVA.PVA_Geo(st:stp:en,idx_height);
PosGeokml(:,5)  = PVA.Ns(st:stp:en,5);
PosGeokml       = PosGeokml';

str = [];

export_kml_p(f_out_k, PosGeokml, str, f_out_kc , '0.3')
winopen(f_out_k);


%% Close
fclose('all');


%% profile report
% profile report
toc
