function [KF, GNSS, raim] = RAIM(KF, PVA, GNSS, raim, time)
%RAIM(Receiver Autonomous Integrity Monitoring)
%   rev 12/10/2014

I = [];
I1= [];
raim.m1 = 0; % RAIM true
raim.m2 = 0; % RAIM detected
raim.m3 = 0; % norm of original innovation
raim.m4 = 0; % norm of innovation after rejection


if isempty(GNSS.multp) == 0
    if time(1) > GNSS.multp(1,1) && time(1) < GNSS.multp(1,1)+GNSS.multp(1,2);
        raim.m1 = 1;
    end
end

if raim.m == 1 && time(2) < time(1);
    H = KF.H;
    R = KF.R;
    P = KF.p;
    z  = KF.z;
    dz = KF.dz;
    dzo=dz;
    hx = KF.hx;
    
    %% KF method     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
%     v = sqrt(dz.^2); vo = v;
%     S = H*P*H' + R;
%        
%     % global test
%     chi = v' / S * v;
%     T   = size(v,1);
%     thr = chi2inv(0.95,T-4);
%     
%     I1  = [];    
%     if isnan(thr) == 0
%         while chi > thr  % while global test fails
%             %         vn  = sqrt((v./sqrt(diag(S))).^2);   % normalize
%             %         vn  = sqrt(v.^2);
%             vn  = v;
%             ii  = find(v == max(vn));            % local index
%             iii = find(vo == v(ii));             % global index
%             
%             dz(ii,:) = [];
%             R(ii,:)  = [];
%             R(:,ii)  = [];
%             H(ii,:)  = [];
%             
%             % global test
%             v = sqrt(dz.^2);
%             S = H*P*H' + R;
%             
%             chi = v' / S * v;
%             T   = size(v,1);
%             thr = chi2inv(0.95,T-4);
%             
%             
%             
%             if isnan(thr) == 1
%                 break;
%             end
%             
%             I1 = [I1; iii];
%         end
%     end
    
    %% KF method - local testing only
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isempty(dz) == 0
        v = sqrt(dz.^2); vo = v;
        S = H*P*H' + R;
        
        vs = v./diag(S);        
        I1 = find(vs > 1.96); % find index of outliers
        ig = I1;              % global index
        
        % remove outliers 
        v(ig)   = []; 
        R(ig,:) = [];
        R(:,ig) = [];
        H(ig,:) = [];
        
        % additional test
        v_thr = 5;           % threshold for additional test
        mag_v = norm(v);    % magnitude of innovation
                
        while mag_v > v_thr
            try
            il = find(v == max(v)); % local index
            ig = find(vo == v(il)); % global index
            I1 = [I1; ig];
            catch
                keyboard
            end
           
            v(il,:) = [];
            R(il,:)  = [];
            R(:,il)  = [];
            
            % additional test
            v_thr = 5;           % threshold for additional test
            mag_v = norm(v);    % magnitude of innovation
        end
        
        if isempty(I1) == 0
            raim.m2 = 1;
        end
    end
    
    
    %% LS survey method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % using pseudorange only
%     H(~any(H,2),:) = [];  %rows
%     H(:,~any(H,1)) = [];  %columns
%     
%     % LS
%     Vxh = inv(H'/R*H);
%     xh  = (H'/R*H)\(H'/R*dz);    
%     
%     v   = dz - H*xh;
%     Vv  = R - (H*Vxh*H'); 
%     
%     % global test
%     chi = v' / R * v;
%     T   = size(v,1);
%     thr = chi2inv(0.95,T-4);
%                   
%     I1  = [];    
% 
%     raim.m3 = 0;
%     
%     if T > 4
%         while chi > thr  % while global test fails                 
% %             v   = sqrt((v./sqrt(diag(Vv))).^2);   % normalize
%             ii  = find(v == max(v));            % local index
%             
%             dz(ii,:) = [];
%             R(ii,:)  = [];
%             R(:,ii)  = [];
%             H(ii,:)  = [];
%             
%             % LS
%             Vxh = inv(H'/R*H);
%             xh  = (H'/R*H)\(H'/R*dz);
%             
%             v   = dz - H*xh;
%             Vv  = R - (H*Vxh*H');
%             
%             % global test
%             chi = v' / R * v;
%             T   = size(v,1);
%             thr = chi2inv(0.95,T-4);           
%             
%             raim.m3 = 1;           
%           
%             % global index
%             I1 = find(~ismember(dzo, dz));
%             
%             raim.m2 = norm(dz);
%            
%             if T < 5; break; end                     
%         end         
%     end
    

    %% LS survey method
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % stacked GNSS, INS method        
%     dz = [dz; KF.x(1:3)];
%     R  = blkdiag(R,P(1:3,1:3));          
%     
%     H(~any(H,2),:) = [];  %rows
%     H(:,~any(H,1)) = [];  %columns
% 
%     H  = [H;eye(3) zeros(3,1)];
% 
%     % LS
%     xh = (H'/R*H)\(H'/R*dz);    
%     v  = dz - H*xh;
%       
%     % global test
%     chi = v' / R * v;
%     T   = size(v,1);
%     thr = chi2inv(0.95,T-4);
%     
%     % originals
%     Ro = R;
%     vo = v;
%     
%     
%     yo  = sqrt((v./sqrt(diag(R))).^2);    % measurement original
%     yn  = yo;                             % measurement to be omitted
%     I1  = [];
%     
%     raim.m3 = 0;
%     
%     if T > 4
%         while chi > thr  % while global test fails     
%             yn  = sqrt((v./sqrt(diag(R))).^2);    % normalize
%             ii  = find(yn == max(yn));             % local index
%             iii = find(yo == yn(ii));              % global index
%             I1 = [I1, iii];
%            
%             v(ii,:) = [];
%             R(ii,:)  = [];
%             R(:,ii)  = [];
%             
%             T   = size(v,1);
%             chi = v' / R * v;
%             thr = chi2inv(0.95,T-4);
%            
%             if T < 5; break; end
%             raim.m3 = 1;
%         end        
%     end
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    %% LS survey method new
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % stacked GNSS, INS method        
%     dz = [dz; KF.x(1:3)];
%     R  = blkdiag(R,P(1:3,1:3));          
%     
%     H(~any(H,2),:) = [];  %rows
%     H(:,~any(H,1)) = [];  %columns
% 
%     H = H(1:size(H,1),1:3);
%     H  = [H;eye(3)];
% 
%     % LS
%     xh = (H'/R*H)\(H'/R*dz);    
%     v  = dz - H*xh;
%     
%     % global test
%     chi = v' / R * v;
%     T   = size(v,1);
%     thr = chi2inv(0.95,T-3);
%     
%     % originals
%     Ro = R;
%     vo = v;
%     
%     
%     yo  = sqrt((v./sqrt(diag(R))).^2);    % measurement original
%     yn  = yo;                             % measurement to be omitted
%     I1  = [];
%     
%     raim.m3 = 0;
%     
%     if T > 3
%         while chi > thr  % while global test fails     
%             yn  = sqrt((v./sqrt(diag(R))).^2);    % normalize
%             ii  = find(yn == max(yn));             % local index
%             iii = find(yo == yn(ii));              % global index
%             I1 = [I1, iii];
%            
%             v(ii,:) = [];
%             R(ii,:)  = [];
%             R(:,ii)  = [];
%             
%             T   = size(v,1);
%             chi = v' / R * v;
%             thr = chi2inv(0.95,T-3);
%            
%             if T < 4; break; end
%             raim.m3 = 1;
%         end        
%     end
     

    %% Innovation sequence monitoring
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 
    
    
    %% idx 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    raim.m3 = norm(vo); % norm of original innovation
    raim.m4 = mag_v;    % norm of innovation after rejection
    I = sort(I1);
       

end


%%
if isempty(I) == 0
    try
    KF.H(I,:) = [];
    KF.hx(I,:) = [];
    KF.z(I,:) = [];
    KF.dz(I,:) = [];
    KF.R = diag(KF.R);
    KF.R(I,:) = [];
    KF.R = diag(KF.R);
    catch
        keyboard
    end
    GNSS.rem = GNSS.ns - size(I,1);
else
    GNSS.rem = GNSS.ns;
end

if GNSS.rem == 0 || GNSS.out_s == 1;
    GNSS.out_s = 1;
elseif GNSS.rem < 4
    GNSS.out_s = 2;
end

end

