%% Figure
close all

% load(f_out_m)


%% Position

% % time
% figure;grid on; hold on;
% plot(PVA.PVA_Geo(:,1),PVA.PVA_Geo(:,2)*180/pi,'linewidth',2)
% plot(PVA.PVA_Geo(:,1),PVA.PVA_Geo(:,3)*180/pi,'r','linewidth',2)


% Position in GEO frame
figure;grid on; hold on;
plot(PVA.PVA_Geo(:,3)*180/pi,PVA.PVA_Geo(:,2)*180/pi,'linewidth',2)
daspect([1 1 1])
% legend('Trajectory')
xlabel('longitude');ylabel('latitude');

% 
% Position in GEO frame
% figure;
% subplot(1,2,1);grid on; hold on;
% plot(PVA.PVA_Geo(:,3)*180/pi,PVA.PVA_Geo(:,2)*180/pi,'linewidth',2)
% daspect([1 1 1])

% subplot(1,2,2);grid on; hold on;
% plot(PVA.PVA_Geo(:,3)*180/pi,PVA.PVA_Geo(:,2)*180/pi,'linewidth',2)
% daspect([1 1 1])

% 
% % Height 
% figure;grid on; hold on;
% % plot(PVA.PVA_Geo(:,1)-PVA.PVA_Geo(1,1),PVA.PVA_Geo(:,4),'linewidth',2)
% plot(GNSS.PVA_Geo(:,1),GNSS.PVA_Geo(:,4),'color',[0 0.5 0])
% 
% xlabel('time');ylabel('height');


%% Attitude
figure;subplot(2,1,1);hold on;grid on;
plot(PVA.PVA_Geo(:,1)-PVA.PVA_Geo(1,1),PVA.PVA_Geo(:,8))
plot(PVA.PVA_Geo(:,1)-PVA.PVA_Geo(1,1),PVA.PVA_Geo(:,9),'r')
legend('Pitch','Roll')
title('Pitch')
xlabel('Time');ylabel('degrees');
ylabel('degrees');
ylim([-40 40])

subplot(2,1,2);hold on;grid on;
plot(PVA.PVA_Geo(:,1)-PVA.PVA_Geo(1,1),PVA.PVA_Geo(:,10));
legend('Heading')
xlabel('Time');ylabel('degrees');
ylabel('degrees');
ylim([-5 365])


%% velocity body
% figure('Position', [100, 100, 400, 300]);
% hold on;grid on;
% plot(PVA.Eb(:,1)-PVA.Eb(1,1),PVA.Eb(:,8),'color',[1 0 0])
% plot(PVA.Eb(:,1)-PVA.Eb(1,1),PVA.Eb(:,9),'color',[0 0 1])
% plot(PVA.Eb(:,1)-PVA.Eb(1,1),PVA.Eb(:,10),'color',[0 0.5 0])
% legend('X','Y','Z')
% title('Velocity body')
% xlabel('Time');ylabel('m/s');
% 
% 
% figure('Position', [100, 100, 400, 300]);
% hold on;grid on;
% plot(PVA.Eb(:,1)-PVA.Eb(1,1),PVA.Eb(:,11),'color',[1 0 0])
% plot(PVA.Eb(:,1)-PVA.Eb(1,1),PVA.Eb(:,12),'color',[0 0 1])
% plot(PVA.Eb(:,1)-PVA.Eb(1,1),PVA.Eb(:,13),'color',[0 0.5 0])
% legend('X','Y','Z')
% title('Velocity navigation')
% xlabel('Time');ylabel('m/s');


%% acceleration
% figure('Position', [100, 100, 400, 300]);
% hold on;grid on;
% plot(PVA.F_n(:,1)-PVA.F_n(1,1),PVA.F_n(:,5),'color',[1 0 0])
% plot(PVA.F_n(:,1)-PVA.F_n(1,1),PVA.F_n(:,9),'color',[0 0 1])
% legend('f','v')
% xlabel('Time');ylabel('m/s^2');


%% Bias
figure('Position', [100, 100, 400, 300]);
subplot(2,1,1);hold on;grid on;
plot(PVA.Eb(:,1)-PVA.Eb(1,1),PVA.Eb(:,2),'color',[1 0 0])
plot(PVA.Eb(:,1)-PVA.Eb(1,1),PVA.Eb(:,3),'color',[0 0 1])
plot(PVA.Eb(:,1)-PVA.Eb(1,1),PVA.Eb(:,4),'color',[0 0.5 0])
legend('X','Y','Z')
title('Bias - Acceleration')
xlabel('Time');ylabel('m/s^2');
% ylim([-0.55 0.55])

subplot(2,1,2);hold on;grid on;
plot(PVA.Eb(:,1)-PVA.Eb(1,1),PVA.Eb(:,5),'color',[1 0 0])
plot(PVA.Eb(:,1)-PVA.Eb(1,1),PVA.Eb(:,6),'color',[0 0 1])
plot(PVA.Eb(:,1)-PVA.Eb(1,1),PVA.Eb(:,7),'color',[0 0.5 0])
title('Bias - Turning Rates')
xlabel('Time');ylabel('rad/s');
% ylim([-0.03 0.03])

% figure('Position', [100, 100, 400, 300]);
% subplot(2,1,1);hold on;grid on;
% plot(PVA.Eb(:,1),PVA.Eb(:,8),'color',[1 0 0])
% plot(PVA.Eb(:,1),PVA.Eb(:,9),'color',[0 0 1])
% plot(PVA.Eb(:,1),PVA.Eb(:,10),'color',[0 0.5 0])
% legend('X','Y','Z')
% title('Bias Dynamic - Acceleration')
% xlabel('Time');ylabel('m/s^2');
% ylim([-0.55 0.55])

% subplot(2,1,2);hold on;grid on;
% plot(PVA.Eb(:,1),PVA.Eb(:,11),'color',[1 0 0])
% plot(PVA.Eb(:,1),PVA.Eb(:,12),'color',[0 0 1])
% plot(PVA.Eb(:,1),PVA.Eb(:,13),'color',[0 0.5 0])
% title('Bias Dynamic - Turning Rates')
% xlabel('Time');ylabel('rad/s');
% ylim([-0.03 0.03])
% 
% figure('Position', [100, 100, 400, 300]);
% subplot(2,1,1);hold on;grid on;
% plot(PVA.Eb(:,1),PVA.Eb(:,14),'color',[1 0 0])
% plot(PVA.Eb(:,1),PVA.Eb(:,15),'color',[0 0 1])
% plot(PVA.Eb(:,1),PVA.Eb(:,16),'color',[0 0.5 0])
% legend('X','Y','Z')
% title('Bias Static - Acceleration')
% xlabel('Time');ylabel('m/s^2');
% ylim([-0.55 0.55])
% 
% subplot(2,1,2);hold on;grid on;
% plot(PVA.Eb(:,1),PVA.Eb(:,17),'color',[1 0 0])
% plot(PVA.Eb(:,1),PVA.Eb(:,18),'color',[0 0 1])
% plot(PVA.Eb(:,1),PVA.Eb(:,19),'color',[0 0.5 0])
% title('Bias Static - Turning Rates')
% xlabel('Time');ylabel('rad/s');
% ylim([-0.03 0.03])


%% Standard Deviation
st = 1;
en = size(PVA.P_Geo(:,1));

% sd - position
figure('Position', [100, 100, 400, 300]);
hold on;grid on;
plot(PVA.P_Geo(st:100:en,1)-PVA.P_Geo(1,1),sqrt(PVA.P_Geo(st:100:en,2)),'color',[1 0 0])
plot(PVA.P_Geo(st:100:en,1)-PVA.P_Geo(1,1),sqrt(PVA.P_Geo(st:100:en,3)),'color',[0 0 1])
plot(PVA.P_Geo(st:100:en,1)-PVA.P_Geo(1,1),sqrt(PVA.P_Geo(st:100:en,4)),'color',[0 0.5 0])
legend('X','Y','Z')
title('Standard Deviation - Position')
xlabel('Time');ylabel('\sigma m');

% % sd - attitude and heading
% figure('Position', [100, 100, 400, 300]);
% hold on;grid on;
% plot(PVA.P_Geo(:,1)-PVA.P_Geo(1,1),sqrt(PVA.P_Geo(:,8)),'color',[1 0 0])
% plot(PVA.P_Geo(:,1)-PVA.P_Geo(1,1),sqrt(PVA.P_Geo(:,9)),'color',[0 0 1])
% plot(PVA.P_Geo(:,1)-PVA.P_Geo(1,1),sqrt(PVA.P_Geo(:,10)),'color',[0 0.5 0])
% legend('X','Y','Z')
% title('Standard Deviation - attitude and heading')
% xlabel('Time');ylabel('\sigma rad');

% % sd - bias 
% figure('Position', [100, 100, 400, 300]);
% hold on;grid on;
% plot(PVA.P(:,1)-PVA.P(1,1),sqrt(PVA.P(:,11)),'color',[1 0 0])
% plot(PVA.P(:,1)-PVA.P(1,1),sqrt(PVA.P(:,12)),'color',[0 0 1])
% plot(PVA.P(:,1)-PVA.P(1,1),sqrt(PVA.P(:,13)),'color',[0 0.5 0])
% legend('X','Y','Z')
% title('Standard Deviation - bias acceleration')
% xlabel('Time');ylabel('\sigma m/s^2');

% % sd - position
% figure('Position', [100, 100, 400, 300]);
% hold on;grid on;
% plot(PVA.P(:,1)-PVA.P(1,1),sqrt(PVA.P(:,2).^2),'color',[1 0 0])
% plot(PVA.P(:,1)-PVA.P(1,1),sqrt(PVA.P(:,6).^2),'color',[0 0 1])
% plot(PVA.P(:,1)-PVA.P(1,1),sqrt(PVA.P(:,10).^2),'color',[0 0.5 0])
% legend('X','Y','Z')
% title('Standard Deviation - Position')
% xlabel('Time');ylabel('rad');

% % sd - velocity
% figure('Position', [100, 100, 400, 300]);
% hold on;grid on;
% plot(PVA.P(:,1)-PVA.P(1,1),PVA.P(:,3+9*1),'color',[1 0 0])
% plot(PVA.P(:,1)-PVA.P(1,1),PVA.P(:,7+9*1),'color',[0 0 1])
% plot(PVA.P(:,1)-PVA.P(1,1),PVA.P(:,11+9*1),'color',[0 0.5 0])
% legend('X','Y','Z')
% title('Standard Deviation - velocity')
% xlabel('Time');ylabel('m/s');
% 
% % sd - acceleration
% figure('Position', [100, 100, 400, 300]);
% hold on;grid on;
% plot(PVA.P(:,1)-PVA.P(1,1),PVA.P(:,4+9*2),'color',[1 0 0])
% plot(PVA.P(:,1)-PVA.P(1,1),PVA.P(:,8+9*2),'color',[0 0 1])
% plot(PVA.P(:,1)-PVA.P(1,1),PVA.P(:,12+9*2),'color',[0 0.5 0])
% legend('X','Y','Z')
% title('Standard Deviation - acceleration')
% xlabel('Time');ylabel('m/s^2');

% % sd - bias
% figure('Position', [100, 100, 400, 300]);
% hold on;grid on;
% plot(PVA.P(:,1)-PVA.P(1,1),sqrt(PVA.P(:,5+9*3).^2),'color',[1 0 0])
% plot(PVA.P(:,1)-PVA.P(1,1),sqrt(PVA.P(:,9+9*3).^2),'color',[0 0 1])
% plot(PVA.P(:,1)-PVA.P(1,1),sqrt(PVA.P(:,13+9*3).^2),'color',[0 0.5 0])
% legend('X','Y','Z')
% title('Standard Deviation - PRH')
% xlabel('Time');ylabel('m/s^2');


%% Satellite
% % % close all
% % % 
% % % % Plot nSat GNSS
% % % figure('Position', [100, 100, 400, 250]);grid on;hold on; 
% % % if strcmp('GNSS',PVA.mode) == 1
% % %     plot(PVA.Ns(:,1)-PVA.Ns(1,1),PVA.Ns(:,3),'*','Color','b')
% % %     plot(PVA.Ns(:,1)-PVA.Ns(1,1),PVA.Ns(:,4),'^','Color','r')
% % %     plot(PVA.Ns(:,1)-PVA.Ns(1,1),PVA.Ns(:,2),'.','Color','k')
% % %     legend('nsat GPS','nsat GLO','nsat')
% % % else
% % %     plot(PVA.Ns(:,1)-PVA.Ns(1,1),PVA.Ns(:,2),'.','Color','k')
% % %     legend('nsat')
% % % end
% % % xlabel('time');ylabel('nsat')
% % % 
% % % % plot nSat full vs rejected
% % % figure('Position', [100, 100, 400, 250]);grid on;hold on; 
% % % plot(PVA.Ns(:,1)-PVA.Ns(1,1),PVA.Ns(:,2),'.-','Color','r')
% % % plot(PVA.Ns(:,1)-PVA.Ns(1,1),PVA.Ns(:,5),'.-','Color',[0 0.5 0])
% % % xlabel('time');ylabel('n sat')
% % % xlim([250 750])
% % % ylim([-0.5 10])
% % % 
% % % % raim detection
% % % figure('Position', [100, 100, 400, 250]);grid on;hold on; 
% % % plot(raim.dm(:,1)-PVA.Ns(1,1),raim.dm(:,2),'-*','Color','g')
% % % plot(raim.dm(:,1)-PVA.Ns(1,1),raim.dm(:,3),'-s','Color','b')
% % % ylim([-0.5 1.5])
% % % xlim([250 750])
% % % xlim([250 750])
% % % xlabel('time (s)')
% % % ylabel('detection')
% % % % legend('True','Detected')
% % % 
% % % % innovation before and after rejection
% % % figure('Position', [100, 100, 400, 250]);grid on;hold on; 
% % % plot(raim.dm(:,1)-PVA.Ns(1,1),raim.dm(:,4),'-','Color','r')
% % % plot(raim.dm(:,1)-PVA.Ns(1,1),raim.dm(:,5),'-','Color',[0 0.5 0])
% % % % ylim([-0.5 6])
% % % xlim([250 750])
% % % xlabel('time (s)')
% % % ylabel('|\delta z| (m)')


% GNSS.multp    = [1107416143, 300, 10, 3;
%                  1107416248, 60, 500, 3;
%                  1107416432, 60, 100, 3;
%                  1107416499, 60, 100, 3];

% line_mult1 = [GNSS.multp(1)-PVA.Ns(1,1), 0.5; GNSS.multp(1,1)-PVA.Ns(1,1)+GNSS.multp(1,2), 0.5];
% % line_mult2 = [GNSS.multp(2)-PVA.Ns(1,1), 0.5; GNSS.multp(2,1)-PVA.Ns(1,1)+GNSS.multp(2,2), 0.5];
% % line_mult3 = [GNSS.multp(3)-PVA.Ns(1,1), 0.5; GNSS.multp(3,1)-PVA.Ns(1,1)+GNSS.multp(3,2), 0.5];
% % line_mult4 = [GNSS.multp(4)-PVA.Ns(1,1), 0.5; GNSS.multp(4,1)-PVA.Ns(1,1)+GNSS.multp(4,2), 0.5];
% 
% plot(line_mult1(:,1),line_mult1(:,2),'-','LineWidth',4,'Color',[0 0 0])
% % plot(line_mult2(:,1),line_mult2(:,2),'-','LineWidth',4,'Color',[0 0 0])
% % plot(line_mult3(:,1),line_mult3(:,2),'-','LineWidth',4,'Color',[0 0 0])
% % plot(line_mult4(:,1),line_mult4(:,2),'-','LineWidth',4,'Color',[0 0 0])
% 
% figure; 
% plot(GNSS.Obs_data(:,7)-GNSS.Obs_data(1,7), GNSS.Obs_data(:,8),'.-','Color',[0 0.5 0])

% % Receiver clock bias
% figure;grid on;hold on;
% plot(PVA.RCB(:,1)-PVA.RCB(1,1),PVA.RCB(:,2),'color',[1 0 0])
% plot(PVA.RCB(:,1)-PVA.RCB(1,1),PVA.RCB(:,3),'color',[0 0 1])
% legend('c\deltat GPS','c\deltat GLO')
% xlabel('time (SFD)');ylabel('Receiver clock bias (m)')


%% Plot innovation
% figure;grid on;hold on;
% plot(KF.Inno(:,1)-KF.Inno(1,1),KF.Inno(:,2))
% 
% figure;grid on;hold on;
% hist(KF.Inno(:,2),100);
% xlim([0 6])
% 
% figure;grid on;hold on;
% hist(KF.inno(:,1),200);


