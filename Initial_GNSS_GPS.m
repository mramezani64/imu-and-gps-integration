%% Calculate Initial Position using GPS-SPP only
% Arrange data appropriately
fprintf('Intializing... \n')

GNSS.i = 1;
if isempty(Ptime)==0
    [ GNSS.i, ~ ] = InitTime(GNSS.Obs_data, GNSS.Obs_data, 1,1,7,7, Ptime);
end

GNSS.posE   = zeros(1,4);
GNSS.posG   = zeros(1,4);
GNSS.time   = GNSS.Obs_data(GNSS.i,7);
GNSS.n_Sat  = GNSS.Obs_data(GNSS.i,8);
GNSS.sats   = GNSS.Obs_data(GNSS.i,9:9+GNSS.n_Sat-1)';
GNSS.Obs    = GNSS.Obs_data(GNSS.i,10+GNSS.n_Sat-1:10+GNSS.n_Sat*2-2)';
GNSS.Q      = [];
GNSS.n_SatV = [];
GNSS.n_Sat  = [];
GNSS.flg    = [];
GNSS.unit_v = [];
GNSS.rcb    = [];
GNSS.n      = size(GNSS.Obs_data,1);

% Ready to compute GPS-SPP.
GNSS = LS_pos_GPS(GNSS, 1, c);

fprintf('Initial position from GPS ECEF: X %.3f Y %.3f Z %.3f\n',GNSS.posE(1),GNSS.posE(2),GNSS.posE(3));

% Convert to Geodetic
GNSS.posG  = ecef2lla(GNSS.posE(1:3)');
fprintf('Initial position from GPS Geodetic: Lat %.6f Longitude %.6f h %.3f\n\n',GNSS.posG(1),GNSS.posG(2),GNSS.posG(3));
GNSS.posG(1,1:2) = GNSS.posG(1,1:2)*pi/180;

if  numel(GNSS.Exc_SVN)~=0
    fprintf('Exluding SVN: ');
    for i = 1:size(GNSS.Exc_SVN,1)
        fprintf('%i ',GNSS.Exc_SVN(i));
    end
    fprintf('\n\n');
end