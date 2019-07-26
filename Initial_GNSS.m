%% Calculate Initial Position using GPS-SPP only
% Arrange data appropriately
fprintf('Intializing... \n')
% keyboard
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

fprintf('Initial position from GPS ECEF: X %.3f Y %.3f Z %.3f\n',PVA.posE(1),PVA.posE(2),PVA.posE(3));

% Convert to Geodetic
GNSS.posG  = ecef2lla(PVA.posE(1:3)');
fprintf('Initial position from GPS Geodetic: Lat %.6f Longitude %.6f h %.3f\n\n',GNSS.posG(1),GNSS.posG(2),GNSS.posG(3));
GNSS.posG(1,1:2) = GNSS.posG(1,1:2)*pi/180;

if  numel(GNSS.Exc_SVN)~=0
    fprintf('Excluding SVN: ');
    for i = 1:size(GNSS.Exc_SVN,1)
        fprintf('%i ',GNSS.Exc_SVN(i));
    end
    fprintf('\n\n');
end

PVA.fst    = 0;
