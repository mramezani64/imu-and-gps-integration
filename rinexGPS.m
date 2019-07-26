function eph = rinexGPS(ephemerisfile)
%RINEXE Reads a RINEX Navigation Message file and
%	    reformats the data into a matrix with 21
%	    rows and a column for each satellite.

% Azmir Hasnur Rabiain 22/02/2012
% rev 10/2014

%Modified, adopted from
%Kai Borre 04-18-96
%Copyright (c) by Kai Borre
%$Revision: 1.1 $  $Date: 2008/06/02  $

% Supports RINEX 2.10, 2.11


% Units are either seconds, meters, or radians
fide = fopen(ephemerisfile);
head_lines = 0;
while 1  % We skip header
    head_lines = head_lines+1;
    line = fgetl(fide);
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
noeph = noeph/8; %Each satellite contains 8 lines of information

%%
frewind(fide); %sets the file position indicator to the beginning of a file
for i = 1:head_lines, line = fgetl(fide); end;

% Set aside memory for the input
svprn	= zeros(1,noeph);
toc     = svprn;
iode    = svprn;
toe     = svprn;
toes    = svprn;
ttr     = svprn;
week	= svprn;
tgd     = svprn;
af2     = svprn;
af1     = svprn;
af0     = svprn;
deltan	= svprn;
M0      = svprn;
ecc     = svprn;
roota	= svprn;
cic     = svprn;
crc     = svprn;
cis     = svprn;
crs     = svprn;
cuc     = svprn;
cus     = svprn;
OMEGA0	= svprn;
omega	= svprn;
i0      = svprn;
Omegadot = svprn;
idot	 = svprn;
svaccur = svprn;
svhealth = svprn;
iodc    = svprn;
codes   = svprn;
tom     = svprn;
L2flag  = svprn;

for i = 1:noeph
    line        = fgetl(fide);	  %1
    svprn(i)    = str2double(line(1:2));
    year        = str2num(line(3:6));
    month       = str2num(line(7:9));
    day         = str2num(line(10:12));
    hour        = str2num(line(13:15));
    minute      = str2num(line(16:18));
    second      = str2num(line(19:22));       
    af0(i)      = str2num(line(23:41));
    af1(i)      = str2num(line(42:60));
    af2(i)      = str2num(line(61:79));
    
    line        = fgetl(fide);	  %2
    iode(i)     = str2num(line(4:22));
    crs(i)      = str2num(line(23:41));
    deltan(i)   = str2num(line(42:60));
    M0(i)       = str2num(line(61:79));
    
    line        = fgetl(fide);	  %3
    cuc(i)      = str2num(line(4:22));
    ecc(i)      = str2num(line(23:41));
    cus(i)      = str2num(line(42:60));
    roota(i)    = str2num(line(61:79));
    
    line        = fgetl(fide);      %4
    toes(i)     = str2num(line(4:22));
    cic(i)      = str2num(line(23:41));
    OMEGA0(i)   = str2num(line(42:60));
    cis(i)      = str2num(line(61:79));
    
    line        = fgetl(fide);	   %5
    i0(i)       = str2num(line(4:22));
    crc(i)      = str2num(line(23:41));
    omega(i)    = str2num(line(42:60));
    Omegadot(i) = str2num(line(61:79));
    
    line        = fgetl(fide);	   %6
    idot(i)     = str2num(line(4:22));
    codes(i)    = str2num(line(23:41));
    week(i)     = str2num(line(42:60));
    L2flag(i)   = str2num(line(61:79));
  
   
    line        = fgetl(fide);	   %7
    svaccur(i)  = str2num(line(4:22));
    svhealth(i) = str2num(line(23:41));
    tgd(i)      = str2num(line(42:60));
    iodc(i)     = str2num(line(61:79));
    
    line        = fgetl(fide);	    %8
    tom(i)      = str2num(line(4:22));
    %   spare = line(23:41); % recent RINEX files have empty spaces
    %   spare = line(42:60);
    %   spare = line(61:79);
    
    %% time
    time        = [year,month,day,hour,minute,second];
    toc(i)      = toes(i) + 604800*week(i);
    
    toe(i)      = adjweek(gpst2time(week(i),toes(i)),toc(i));
    ttr(i)      = adjweek(gpst2time(week(i),tom(i)),toc(i));
    
end
status = fclose(fide);

%  Description of variable eph.
eph = [svprn;   toe;        toes;   toc;    ttr;
    iode;       iodc;       tgd;    af0;    af1;    
    af2;        roota;      ecc;    i0;     OMEGA0; 
    omega;      Omegadot;   M0;     deltan; idot;   
    crc;        crs;        cuc;    cus;    cic;    
    cis;        svhealth;   week];

% eph = [svprn;   toe;        toes;   toc;    ttr;
%     iode;       iodc;       tgd;    af0;    af1;    
%     af2;        roota;      ecc;    i0;     OMEGA0; 
%     omega;      Omegadot;   M0;     deltan; idot;   
%     crc;        crs;        cuc;    cus;    cic;    
%     cis;        svhealth];

%% Check if SV is healthy, else reject!
disp('  ');disp('Analysing Ephemeris data...');
j=1; 
for i = 1:size(eph,2)
    if eph(27,j) ~= 0
        strd = ['Warning - Satellite ', num2str(eph(1,j)), ' not healthy!'];
        disp(strd);
        eph(:,j) = [];
        j=j-1;
    end       
    j = j+1;
end
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');disp('  ');
%%%%%%%%% end rinexe.m %%%%%%%%%