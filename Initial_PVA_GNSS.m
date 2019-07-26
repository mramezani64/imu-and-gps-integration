% Initial Position from GNSS
% PVA.posE = GNSS.posE(1:3);
% PVA.posG = GNSS.posG(1:3);

% Initial receiver clock bias
% PVA.rcb = GNSS.posE(4);


% Initial Velocity and acceleration - User determined
PVA.vel = [0 0 0];

c_ne = C_en(PVA.posG)';
gn   = [0; 0; 9.8065];
ge   = c_ne * gn;
PVA.acc  = (c_ne * [0 0 -9.8065]')';


% Filtering - Initialize
PVA.sd_pos  = [5 5 5];
PVA.sd_vel  = [0.1 0.1 0.1]; %in metres
PVA.sd_a    = [0.01 0.01 0.01]; % acc tr
PVA.sd_RecClck  = 1;

% Rearrange in blocks
PVA.sd_Init = [PVA.sd_pos,PVA.sd_vel,PVA.sd_a,PVA.sd_RecClck,PVA.sd_RecClck];

PVA.n = GNSS.n;

PVA.fst = 0;