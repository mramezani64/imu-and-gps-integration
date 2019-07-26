clear all;close all;clc;tic

%% Load INS/GNSS
load PVA_wS
PVA_IG = PVA;


%% Load SPP
load('C:\Users\azmir\Documents\Sync\Dropbox\Working Folder\PhD Work\Dataset\2015\20150208\GNSS\Rover\SPP\AP_SPP.mat')
PVA_GNSS = PVA;

clear PVA

% Velocity
VelNav = zeros(PVA_GNSS.n,2);
for i = 1:PVA_GNSS.n
    vel = norm(PVA_GNSS.PVA(i,5:7)); % km/h
    VelNav(i,:) = [PVA_GNSS.PVA_Geo(i,1);   vel];
    
    sow(i,1)  = mod(PVA_GNSS.PVA_Geo(i,1),86400*7);    
    week(i,1) = floor(PVA_GNSS.PVA_Geo(i,1)/(86400*7));
end
week = week(1);


%% Load GNSS_Ref
load('C:\Users\azmir\Documents\Sync\Dropbox\Working Folder\PhD Work\Dataset\2015\20150208\GNSS\Rover\Reference\AP_GNSS.mat')
Ref = NavG.PVA;
Ref(:,1) = week*86400*7 + Ref(:,1);

% Calculate velocity from reference
n_ref = size(Ref,1);

Ref_vel = NaN(n_ref,5);

for  i = 2:n_ref
    posGeo          = Ref(i,2:4);

    % Rotate vel
    c_en    = C_en(posGeo);
    
    dt      = Ref(i,1)-Ref(i-1,1);
    
    if dt > 1
        continue
    end    
    
    vel_e   = (Ref(i,2:4) - Ref(i-1,2:4))/dt;    
    vel_n   = c_en*vel_e';   
    
    Ref_vel(i,1:5)  = [Ref(i,1) vel_n' sumsqr(vel_n(1:3))^0.5];    
end

Ref_vel(isnan(Ref_vel(:,1)),:)  = [];


%% load OBDII
load('C:\Users\azmir\Documents\Sync\Dropbox\Working Folder\PhD Work\Dataset\2015\20150208\OBDII\20150208_OBDII_TimeAligned.mat')
OBD.Speed      = Car_OBD;


%% plot

cmap = hsv(5);

% % check vel time sync
% figure('Position', [100, 100, 400, 300]);
% hold on;grid on;
% plot(OBD.Speed(:,1),OBD.Speed(:,7),'color',cmap(1,:))
% plot(PVA_IG.F_n(:,1),PVA_IG.F_n(:,9),'color',cmap(2,:))
% plot(VelNav(:,1),VelNav(:,2),'color',cmap(3,:))
% plot(Ref_vel(:,1), Ref_vel(:,5),'.-','MarkerSize', 10,'color',cmap(4,:))
% 
% xlabel('Time');ylabel('m/s');
% legend('OBD','IG','SPP','Ref')




% check vel vs f
figure('Position', [100, 100, 400, 300]);
hold on; grid on
plot(PVA_IG.Zvel(:,1),PVA_IG.Zvel(:,2),'color',cmap(1,:))
plot(PVA_IG.Zvel(:,1),PVA_IG.Zvel(:,3),'color',cmap(2,:))
plot(PVA_IG.Zvel(:,1),PVA_IG.Zvel(:,4),'color',cmap(3,:))
plot(PVA_IG.F_n(:,1),PVA_IG.F_n(:,9),'color',cmap(4,:))
plot(Ref_vel(:,1), Ref_vel(:,5),'.-','MarkerSize', 10,'color',cmap(5,:))

legend('f','w','OBD','Vel')

% sd 
% figure('Position', [100, 100, 400, 300]);
% hold on; grid on
% plot(PVA_IG.Zvel(:,1),PVA_IG.Zvel(:,5),'color',cmap(1,:))
% legend('\sigma v')
% 
% figure('Position', [100, 100, 400, 300]);
% hold on; grid on
% plot(PVA_IG.Zvel(:,1),PVA_IG.Zvel(:,6),'color',cmap(1,:))
% legend('\sigma q')
% 
% figure('Position', [100, 100, 400, 300]);
% subplot(1,2,1);hold on; grid on
% plot(PVA_IG.Zvel(:,1),PVA_IG.Zvel(:,7),'color',cmap(1,:))
% subplot(1,2,2);hold on; grid on
% plot(PVA_IG.Zvel(:,1),PVA_IG.Zvel(:,8),'color',cmap(1,:))

% % check vel vs f
% figure('Position', [100, 100, 400, 300]);
% hold on;grid on;
% plot(PVA_IG.F_n(:,1),PVA_IG.F_n(:,5),'color',cmap(1,:))
% plot(PVA_IG.F_n(:,1),PVA_IG.F_n(:,9),'color',cmap(2,:))
% plot(Ref_vel(:,1), Ref_vel(:,5),'.-','MarkerSize', 10,'color',cmap(3,:))
% 
% legend('f','v','v_{ref}')
% xlabel('Time');ylabel('m/s^2');
% 
% 
% 
% 
% figure; hold on
% % plot(OBD.Speed(:,1),OBD.Speed(:,7)/3600*1000,'r')
% plot(PVA_IG.F_n(:,1),PVA_IG.F_n(:,9),'color',[0 0 1])
% plot(VelNav(:,1),VelNav(:,2),'color',[0.5 0.0 0.5])
% % plot(Ref_vel(:,1), Ref_vel(:,5),'.-','MarkerSize', 10,'color',[0 0.5 0])
% % legend('OBD','IG','SPP','Ref')
% 
% 
% 
% 
% % figure; hold on
% % plot(PVA_INSGNSS.PVA(:,1),PVA_INSGNSS.PVA(:,2),'color',[0 0 1])
% % plot(PVA_GNSS.PVA(:,1),PVA_GNSS.PVA(:,2),'color',[1 0 0])
% % plot(Ref(:,1), Ref(:,2),'color',[0 0.5 0])