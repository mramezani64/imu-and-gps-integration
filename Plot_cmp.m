clear all; close all; clc

%% Load without Speed
load PVA_woS_out
PVA_woS = PVA;


%% Load with Speed
load PVA_wS_out
PVA_wS = PVA;

week = floor(PVA_wS.PVA_Geo(1,1)/(86400*7));


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


%% Plot
cmap = hsv(3);

% Position
figure('Position', [100, 100, 400, 300]);hold on; grid on
plot(PVA_woS.PVA_Geo(:,3)*180/pi,PVA_woS.PVA_Geo(:,2)*180/pi,'linewidth',2,'color',cmap(1,:))
plot(PVA_wS.PVA_Geo(:,3)*180/pi,PVA_wS.PVA_Geo(:,2)*180/pi,'linewidth',2,'color',cmap(2,:))
plot(NavG.PVA_Geo(:,3)*180/pi,NavG.PVA_Geo(:,2)*180/pi,'.','color',cmap(3,:))

legend('woS','wS')
daspect([1 1 1])

% check vel vs f
n_N  = size(PVA_woS.F_n,1);
idx  = 1:100:n_N;
figure('Position', [100, 100, 400, 300]);
subplot(2,1,1);grid on; hold on;
plot(PVA_woS.F_n(idx,1)-PVA_woS.F_n(1,1),PVA_woS.F_n(idx,9),'color',[1 0 0])
plot(PVA_wS.F_n(idx,1)-PVA_woS.F_n(1,1),PVA_wS.F_n(idx,9),'color',[0 0 1])
plot(Ref_vel(:,1)-PVA_woS.F_n(1,1), Ref_vel(:,5),'.-','MarkerSize', 10,'color',[0 0.5 0])
ylabel('m/s')

subplot(2,1,2);grid on; hold on;
plot(PVA_woS.F_n(idx,1)-PVA_woS.F_n(1,1),PVA_woS.F_n(idx,9),'color',[1 0 0])
plot(PVA_wS.F_n(idx,1)-PVA_woS.F_n(1,1),PVA_wS.F_n(idx,9),'color',[0 0 1])
plot(Ref_vel(:,1)-PVA_woS.F_n(1,1), Ref_vel(:,5),'.-','MarkerSize', 10,'color',[0 0.5 0])

ylabel('m/s')
xlabel('time (s)')


%% Standard deviation
% sd - Pos
figure('Position', [100, 100, 400, 300]);
n_N  = size(PVA_woS.P_Geo,1);
idx  = 1:100:n_N;
PVA_woS.sd_Pos = [PVA_woS.P_Geo(:,1), sqrt(sum(abs([PVA_woS.P_Geo(:,2).^.5, PVA_woS.P_Geo(:,3).^.5, PVA_woS.P_Geo(:,4).^.5]).^2,2))];
PVA_wS.sd_Pos = [PVA_wS.P_Geo(:,1), sqrt(sum(abs([PVA_wS.P_Geo(:,2).^.5, PVA_wS.P_Geo(:,3).^.5, PVA_wS.P_Geo(:,4).^.5]).^2,2))];

subplot(2,1,1);hold on;grid on;
plot(PVA_woS.sd_Pos(idx,1)-PVA_woS.sd_Pos(1,1),PVA_woS.sd_Pos(idx,2),'color',[1 0 0])
plot(PVA_wS.sd_Pos(idx,1)-PVA_wS.sd_Pos(1,1),PVA_wS.sd_Pos(idx,2),'color',[0 0 1])
xlabel('Time (s)');ylabel('\sigma (m)');
xlim([0 850])
% ylim([0 3])

% sd - velocity
PVA_woS.sd_Vel = [PVA_woS.P(:,1), sqrt(sum(abs([PVA_woS.P(:,3+9*1).^.5, PVA_woS.P(:,7+9*1).^.5, PVA_woS.P(:,11+9*1).^.5]).^2,2))];
PVA_wS.sd_Vel = [PVA_wS.P(:,1), sqrt(sum(abs([PVA_wS.P(:,3+9*1).^.5, PVA_wS.P(:,7+9*1).^.5, PVA_wS.P(:,11+9*1).^.5]).^2,2))];
subplot(2,1,2);hold on;grid on;
plot(PVA_woS.sd_Vel(idx,1)-PVA_woS.sd_Vel(1,1),PVA_woS.sd_Vel(idx,2),'color',[1 0 0])
plot(PVA_wS.sd_Vel(idx,1)-PVA_wS.sd_Vel(1,1),PVA_wS.sd_Vel(idx,2),'color',[0 0 1])
xlabel('Time (s)');ylabel('\sigma (m/s)');
xlim([0 850])
% ylim([0 0.3])
