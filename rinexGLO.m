function eph = rinexGLO(ephemerisfile)
%RINEXE Reads a RINEX Navigation Message file and
%	    reformats the data into a matrix 
%Azmir Hasnur Rabiain 22/09/2014
%Edited by Milad Ramezani 29/06/2015

% Supports RINEX 2.10, 2.11

if exist(ephemerisfile, 'file') == 0
    fprintf('Missing GLONASS file')
    eph = [];
    return
end
% keyboard
% Units are either seconds, meters, or radians
fide = fopen(ephemerisfile);
head_lines = 0;
while 1  % We skip header
    head_lines = head_lines+1;
    line = fgetl(fide);
    answer = findstr(line,'CORR TO SYSTEM TIME');
    if ~isempty(answer), Tau_c = str2double(line(23:41));	end;
    answer = findstr(line,'END OF HEADER');
    if ~isempty(answer), break;	end;
end;
%head_lines;
noeph = -1;
while 1
    noeph = noeph+1;
    line = fgetl(fide);
    if line == -1, break;  end
end;
noeph = noeph/4; %Each GlONASS satellite contains 4 lines of information

%%
frewind(fide); %sets the file position indicator to the beginning of a file
for i = 1:head_lines, line = fgetl(fide); end;

% Set aside memory for the input
svprn	 = zeros(1,noeph);
year     = zeros(1,noeph);
month    = zeros(1,noeph);
day      = zeros(1,noeph);
hour     = zeros(1,noeph);
minute   = zeros(1,noeph);
second   = zeros(1,noeph);
toe      = zeros(1,noeph);
toeU     = zeros(1,noeph);
iode     = zeros(1,noeph);
cdT      = zeros(1,noeph);
Relfbias = zeros(1,noeph);
frametime= zeros(1,noeph);

posx     = zeros(1,noeph);
velx     = zeros(1,noeph);
accx     = zeros(1,noeph);
health   = zeros(1,noeph);
posy     = zeros(1,noeph);
vely     = zeros(1,noeph);
accy     = zeros(1,noeph);
f_num    = zeros(1,noeph);
posz     = zeros(1,noeph);
velz     = zeros(1,noeph);
accz     = zeros(1,noeph);
age      = zeros(1,noeph);
Tau_C    = zeros(1,noeph);

for i = 1:noeph
    line = fgetl(fide);	  %1
    
    svprn(i)    = str2num(line(1:2));
    year(i)     = str2num(line(3:6));
    month(i)    = str2num(line(7:9));
    day(i)      = str2num(line(10:12));
    hour(i)     = str2num(line(13:15));
    minute(i)   = str2num(line(16:18));    
    second(i)   = str2num(line(19:22));
    cdT(i)      = str2num(line(23:41));
    Relfbias(i) = str2num(line(42:60));
    frametime(i)= str2num(line(61:79));
    
    DT          = [year(i)+2000,month(i),day(i),hour(i),minute(i),second(i)];    
    [~,ls]      = utc2gps(DT);
   
    time        = [year(i)+2000,month(i),day(i),hour(i),minute(i),second(i)];
    jd          = julday(year(i)+2000,month(i),day(i),hour(i)+minute(i)/60+second(i)/3600);
    [week, sow] = jul2GPSt(jd);
    toeU(i)     = sow + 604800*week;

    % toc rounded by 15 min in utc 
    toc         = 86400*7*week + floor((sow+450.0)/900.0)*900; %round 15 mins
    dow         = floor(sow/86400.0);
         
    % time of frame in utc
    tod         = frametime(i);
    tof         = 86400*7*week + tod + dow*86400;     
    tt          = tof-toc;
    if tt<-43200; tof = tof + 86400;
    elseif tt>43200; tof = tof - 86400; end
        
%             keyboard

    toeU(i)     = toeU(i) + ls;
    toe(i)      = toc + ls; % toe in GPSt
    tof(i)      = tof + ls; % tof in GPSt
    iode(i)     = mod(sow+10800,86400.0)/900.0+0.5; %issue of data, eph

    line        = fgetl(fide);	  %2
    posx(i)     = str2num(line(4:22))*1E3; 
    velx(i)     = str2num(line(23:41))*1E3;
    accx(i)     = str2num(line(42:60))*1E3;
    health(i)   = str2num(line(61:79));
  
    line        = fgetl(fide);	  %3
    posy(i)     = str2num(line(4:22))*1E3; 
    vely(i)     = str2num(line(23:41))*1E3;
    accy(i)     = str2num(line(42:60))*1E3;
    f_num(i)    = str2num(line(61:79));

    line        = fgetl(fide);	  %4
    posz(i)     = str2num(line(4:22))*1E3; 
    velz(i)     = str2num(line(23:41))*1E3;
    accz(i)     = str2num(line(42:60))*1E3;
    age(i)      = str2num(line(61:79)); 
    
end
fclose(fide);

% Eph
eph  = [svprn;  toe;        toeU;       cdT;    tof;    
    iode;       Relfbias;   frametime;  posx;   velx;   
    accx;       health;     posy;       vely;   accy;   
    f_num;      posz;       velz;       accz;   age;    
    year;month;day;hour;minute;second];


%% Check if SV is healthy, else reject!
disp('  ');disp('Analysing Ephemeris data...');
j=1; 
for i = 1:size(eph,2)
    if eph(12,j) ~= 0
        strd = ['Warning - GLONASS Satellite ', num2str(eph(1,j)), ' not healthy!'];
        disp(strd);
        eph(:,j) = [];
        j=j-1;
    end       
    j = j+1;
end
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');disp('  ');

%% Sort according to svn

eph = sortrows(eph',1)';

%%%%%%%%% end rinexe.m %%%%%%%%%