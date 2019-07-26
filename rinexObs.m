function [Obs_types, ant_delta, Obs_data, Obs_data_R, n_rows] = rinexObs(file, Obs_type)
%RINEXOBS Reads and saves all of the observations.
%       First analyse the header for antenna delta and types of observation
%       Structure as follows:[Date,time,time(SOW),nSV,sat_n, obs_n] The
%       observation is dependent on user specification
%       gps and glonass(if available) are stored in different files
%       obs_data - gps, obs_data_r - glonass

%       I/O - Uses a combination of both fixed length width and strings

% Original code from kai borre. The following code has been heavily
% modified by Azmir Hasnur(1/3/2012)

% Rev 05/08/2013
%   Checks for empty data
%   Correct for how many satellites are available

% Edited by Milad Ramezani(2/07/2015)
% Be noted that this function can just read C/A code psuedorange carried on
% L1. For reading other obs, code should be manipulated 

% Supports RINEX 2.10, 2.11


%%
% keyboard
fid = fopen(file,'rt');
Obs_types   = [];
Obs_data    = [];
Obs_data_R  = [];
ant_delta   = [];

disp('Analysing Observation data...');
% keyboard
while 1
    % Header
    line = fgetl(fid);
    answer = strfind(line,'END OF HEADER');
    if  ~isempty(answer), break; end;
    if (line == -1), eof = 1; break; end;
    
    tof = strfind(line,'TIME OF FIRST OBS');
    if ~isempty(tof)
        str = textscan(line,'%s');
        Time_of_first_obs = [str2double(str{1,1}(5)) str2double(str{1,1}(6))];
    end
    tof = strfind(line,'TIME OF LAST OBS');
    if ~isempty(tof)
        str = textscan(line,'%s');
        Time_of_last_obs = [str2double(str{1,1}(5)) str2double(str{1,1}(6))];
    end
    
    answer = strfind(line,'ANTENNA: DELTA H/E/N');
    if ~isempty(answer)
        str = textscan(line,'%s');
        ant_delta = [str2double(str{1,1}(1)) str2double(str{1,1}(2))  str2double(str{1,1}(3))];
    end
    
    answer = strfind(line,'# / TYPES OF OBSERV');
    if ~isempty(answer)
        NObs    = textscan(line,'%s');
%         keyboard
        NoObs   = str2double(NObs{1,1}(1));
%         NObs{1,1}(2)r
        for i = 1:NoObs
%             NObs{1,1}{i+1}
%              tf=strfind(NObs{1,1}(i+1),'#')
%              if isempty(cell2mat(tf))
            Obs_types = strcat(Obs_types,NObs{1,1}{i+1});
%              else
%              Obs_types = strcat(Obs_types,'C5L5')
%              break;
%             end;
        end;
    end;
end;

%Mark Obs type
s = strfind(Obs_types, Obs_type);
Obs_type_n = (s+1)/2;

%%%%%%%%% end anheader.m %%%%%%%%%

%% Start Saving data in Obs_Data
% keyboard
nData_GPS = 0;
nData_Glo = 0;
progress = waitbar(0,'Please wait...');
while ~feof(fid)
    
    try
        line = fgets(fid);
        
        %New comment introduced
        answer  = strfind(line,'COMMENT');
        if ~isempty(answer)
            continue
        end
        
        %Types/arrangement of observations changed
        answer1 = strfind(line,'# / TYPES OF OBSERV');
        if ~isempty(answer1)
            NObs    = textscan(line,'%s');
            NoObs   = str2double(NObs{1,1}(1));
            Obs_types   = [];
            for i = 1:NoObs
                Obs_types = strcat(Obs_types,NObs{1,1}{i+1});
            end;
            %Mark Obs type
            s = strfind(Obs_types, Obs_type);
            Obs_type_n = (s+1)/2;
            continue
        end;
        
        str = textscan(line,'%s');
        
        %Check if length is shorter than 8 (at least 7 fields)
        if length(str{1,1}) < 8
            continue
        end
        
        str = sscanf(line,'%c');
        if strcmp(str(29),'0') == 1 %flag if this observation is any good
            year    = str2double(str(2:3));
            month   = str2double(str(5:6));
            day     = str2double(str(8:9));
            hour    = str2double(str(11:12));
            minute  = str2double(str(14:15));
            second  = str2double(str(17:26));
            
            time        = [year+2000,month,day,hour+minute/60+second/3600];
            jd          = julday(year+2000,month,day,hour+minute/60+second/3600);
            [week, sow] = jul2GPSt(jd);
            datetime = [year month day hour minute second sow+week*604800];
            
            
            %% Identify Satellites (SV)
            nstr    = size(str,2);
            if nstr < 68 %Satellite PRN on lines should fill up to 68 col
                SV      = sscanf(str(31:nstr),'%c');
            else
                SV      = sscanf(str(31:68),'%c');
            end
            nSat    = str2double(SV(1:2));
            SV      = sscanf(SV,'%s');
            
            %check if there are more than 12 sats, continuation
            if nSat > 12
                nl      = floor(nSat/12);
                ml      = mod(nSat,12);
                if ml == 0
                    nl = nl - 1;
                end
                for il = 1:nl
                    line    = fgets(fid);
                    str     = sscanf(line,'%c');
                    nstr    = size(str,2);
                    SVt     = sscanf(str(31:nstr),'%s');
                    SV = strcat(SV,SVt);
                end
                
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% detect GPS/GLONASS
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            nGPS = 0; nGlo = 0;
            %         if isempty(strfind(SV,'G')) == 0
            nData_GPS   = nData_GPS+1;
            nGPS        = length(find(SV=='G'));
            SV_GPS      = nGPS;
            
            % Save time
            Obs_data(nData_GPS,1:7) = datetime;
            %         end
            
            %         if isempty(strfind(SV,'R')) == 0
            nData_Glo   = nData_Glo + 1;
            nGlo        = length(find(SV=='R'));
            SV_Glo      = nGlo;
            
            % Save time
            Obs_data_R(nData_Glo,1:7) = datetime;
            %         end
            
            
            %save SV
            tmp_str1 = sscanf(SV,'%f%*c',[1,inf]);
            for i = 1:nSat
                if i <= nGPS
                    SV_GPS(i+1) = tmp_str1(i+1);
                elseif i > nGPS
                    SV_Glo(i+1-nGPS) = tmp_str1(i+1);
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   keyboard          
            %% Save Pseudoranges
            Pseudo_GPS  = zeros(1,nGPS);
            Pseudo_Glo  = zeros(1,nGlo);
            uGPS        = 1;
            uGLO        = 1;
%             Meas        = cell(1,10);
%             Meas        = cell(1,NoObs);
            
            xGPS        = []; xGLO = []; % index for missing data
            
            % Rearrange data
            for i = 1:nSat
                str     = sscanf(fgets(fid),'%c');
                
                if NoObs > 5; wL = 5; else wL = NoObs;  end
                
                %check if line width is as expected
                if size(str,2) < wL*16
                    str = strcat(str, 'E');
                    tmp = [blanks(81-size(str,2)) 'E'];
                    str = strcat(str, tmp);
                    str = strrep(str, 'E', '');
                end
                
                % Rearrange data
                for j = 1:wL
                    k       = 16*(j-1)+1;
                    if isspace(str(k+8))==0
                            Meas{j} = str(k:k+15); %Including LLI
                            else
                             Meas{j}='0';
                    end       
                end
                
                % When there are more than 5 types of measurements
                if NoObs > 5
                    nNoObs  = floor(NoObs/5); % check if more than 10 meas
                    for iObsl = 1:nNoObs
                        str   = sscanf(fgets(fid),'%c');
                        %check if line width is as expected
                        if size(str,2) < (NoObs-5*iObsl)*16
                            str = strcat(str, 'E');
                            tmp = [blanks(81-size(str,2)) 'E'];
                            str = strcat(str, tmp);
                            str = strrep(str, 'E', '');
                        end
                        
%                         for j = 1:NoObs-(5*iObsl)
                if nNoObs == 1; wL1 = NoObs-5; else wL1 = 5;  end
                   if iObsl ==1
                          for j = 1:wL1
                            k           = 16*(j-1)+1;
                            if isspace(str(k+8))==0
                            Meas{j+5}   = str(k:k+15); %Including LLI
                            else
                                Meas{j+5}='0';
                            end
                          end
                   end
                   if iObsl ==2
                       for j = 1:NoObs-(5*iObsl)
                            k           = 16*(j-1)+1;
                            if isspace(str(k+8))==0
                            Meas{j+10}   = str(k:k+15); %Including LLI
                            else
                                Meas{j+10}='0';
                            end
                          end
                   end
                   
                    end
                end
                
                
                % Save user specified data (C1, L1...)
                if i <= nGPS && nGPS ~= 0 % GPS
                    Pseudo_GPS(uGPS) = str2double(Meas{Obs_type_n}(1:14));
                    % check for missing data
                    if isnan(Pseudo_GPS(uGPS)) == 1 || Pseudo_GPS(uGPS) == 0
                        fprintf('Warning - Incomplete GPS observation. Date - %02.0f %02.f %02.f  Time - %02.0f %02.f %02.2f \n', datetime(1),datetime(2),datetime(3), datetime(4),datetime(5),datetime(6))
                        xGPS = [xGPS uGPS];
                    end
                    uGPS = uGPS + 1;
                end
                
                if i > nGPS && nGlo ~= 0 %GLONASS
                    Pseudo_Glo(uGLO) = str2double(Meas{Obs_type_n}(1:14));
                    % check for missing data
                    if isnan(Pseudo_Glo(uGLO)) == 1 || Pseudo_Glo(uGLO) == 0
                        fprintf('Warning - Incomplete GLONASS observation. Date - %02.0f %02.f %02.f  Time - %02.0f %02.f %02.2f \n', datetime(1),datetime(2),datetime(3), datetime(4),datetime(5),datetime(6))
                        xGLO = [xGLO uGLO];
                    end
                    uGLO = uGLO + 1;
                end
            end
            
            % remove missing data
            if isempty(xGPS) == 0
                SV_GPS(1) = SV_GPS(1) - length(xGPS); % n sats
                SV_GPS(xGPS+1)      = [];
                Pseudo_GPS(xGPS)    = [];
            end
            
            
            
            % remove missing data
            if isempty(xGLO) == 0
                SV_Glo(1) = SV_Glo(1) - length(xGLO); % n sats
                SV_Glo(xGLO+1)      = [];
                Pseudo_Glo(xGLO)    = [];
            end
            
            %Save appropriate SV and Pseudoranges
            if nGPS ~= 0
                temp = [SV_GPS Pseudo_GPS];
                Obs_data(nData_GPS,8:7+length(temp)) = temp;
            else
                Obs_data(nData_GPS,8) = 0;
            end
            
            if nGlo ~= 0
                temp = [SV_Glo Pseudo_Glo];
                Obs_data_R(nData_Glo,8:7+length(temp)) = temp;
            else
                Obs_data_R(nData_Glo,8) = 0;
            end
            
        else %skip this observation
            strd = ['Warning - Observations are faulty: time  ', num2str(time)];
            disp(strd);
            if NoObs>5
                j=2;
            end
            for k = 1:nSat*j
                fgets(fid);
            end
        end
    catch
        fprintf('Unspecified error in Observation file \n')
        fprintf('Observation. Date - %02.0f %02.f %02.f  Time - %02.0f %02.f %02.2f \n', datetime(1),datetime(2),datetime(3), datetime(4),datetime(5),datetime(6))
%         keyboard
    end
    
    Total_time= (Time_of_last_obs(1)*60+Time_of_last_obs(2)) -...
                (Time_of_first_obs(1)*60+Time_of_first_obs(2));
    Current_time= (datetime(5)*60+datetime(6)) -...
                  (Time_of_first_obs(1)*60+Time_of_first_obs(2));
    
    waitbar(Current_time / Total_time)
    
end
close(progress)
n_rows = length(Obs_data);

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');disp('  ');