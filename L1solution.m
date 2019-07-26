%% C/A L1 solution
% this programe calculate position at each time stamp 
% according to C1 code as the only measurements.
% Author: Milad Ramezani
% 30 July 2015
clear all;clc;
%WGS84 & Light speed
run('Constants.m')
% load GPSRINEX
load('OS_GNSS');

% RAIM Mode 0 - N/A; 1 - Act
raim.m  = 1;
raim.te = 100; % exclude time

raim.mu   = 0;
raim.sig2 = 10;
raim.sig  = sqrt(raim.sig2);

% +GLONASS %
PVA.mode = 'GNSS';

%% User defined simulated GPS total/partial outages
% Start time, duration (seconds), number of satellites. Example [510765,30,3; 510835,30,3; 510880,30,3];
GNSS.out_s    = 0; % Status
GNSS.outage   = [];

% simulate multipath
% Start time, duration (seconds), magnitude (m), n affected sat [1089438351,30,500,5];
GNSS.multp    = [];

% Exclude SVN. Example [11;15;32]
GNSS.Exc_SVN  = [];

%% User defined parameters
GNSS.COA     = 0;   % Satellite Cut off angle
GNSS.UERE    = 5;    % User equivalent range error

% Process time

Lat=[];
Long=[];
Alt=[];
Time=[];
tic
% for one time epoch%%%%%%%%%%
for j=1:length(GNSS.Obs_data)
    Ptime =[GNSS.Obs_data(j,7) GNSS.Obs_data(length(GNSS.Obs_data),7)];  
    GNSS.i = 1;
    if isempty(Ptime)==0
        [ GNSS.i, ~ ] = InitTime(GNSS.Obs_data, GNSS.Obs_data, 1,1,7,7, Ptime);
    end
    
    PVA.posE   = zeros(1,3)';
    PVA.posG   = zeros(1,3)';
    PVA.rcb    = zeros(1,1);
    PVA.rcbg   = zeros(1,1);
    LS.i       = [];
    
    PVA.fst    = 1;
    
    % Glonass
    if strcmp('GNSS',PVA.mode) == 0
        GNSS.Obs_data_R = [];
        pos = zeros(4,1);
    else
        pos = zeros(5,1);
    end
    % keyboard
    for i = 1:10
        [LS, GNSS] = LS_Prep_GNSS(LS, PVA, GNSS, c);
        [LS] = WLS( LS );
        
        pos  = pos + LS.x;
        posG = ecef2lla(pos(1:3)');
        
        PVA.posE   = pos(1:3);
        PVA.rcb    = pos(4);
        PVA.rcbg   = pos(size(pos,1));
    end
    GNSS.posE = PVA.posE;
    GNSS.rcb  = PVA.rcb;
    GNSS.rcbg = PVA.rcbg;
    GNSS.rem  = GNSS.ns;
%     fprintf('position from GPS ECEF: X %.3f Y %.3f Z %.3f\n',PVA.posE(1),PVA.posE(2),PVA.posE(3));
    
    % Convert to Geodetic
    GNSS.posG  = ecef2lla(PVA.posE(1:3)');percent=100*j/length(GNSS.Obs_data);
    
%     GNSS.posG(1,1:2) = GNSS.posG(1,1:2)*pi/180;
    
    if  numel(GNSS.Exc_SVN)~=0
        fprintf('Excluding SVN: ');
        for i = 1:size(GNSS.Exc_SVN,1)
            fprintf('%i ',GNSS.Exc_SVN(i));
        end
        fprintf('\n\n');
    end
    PVA.fst    = 0;
    
    % Lat, Long and Alt are to be stacked for whole epochs
    T1=GNSS.Obs_data(j,7);
    Lat1=GNSS.posG(1,1);
    Long1=GNSS.posG(1,2);
    Alt1=GNSS.posG(1,3);
    Lat=[Lat;Lat1];
    Long=[Long;Long1];
    Alt=[Alt;Alt1];
    Time=[Time;T1];
%     fprintf('position from GPS Geodetic: Lat %.6f Longitude %.6f h %.3f\n\n',GNSS.posG(1),GNSS.posG(2),GNSS.posG(3));
    fprintf('percent %.2f\n',percent);
end

toc



