function writetxt(FName, Project, Data, UERE, Mode)
%WRITETXT Summary of this function goes here
%   Detailed explanation goes here

h_program   = 'Program:         Matlab GPS-SPP';
h_project   = 'Project:         ';
h_process   = 'ProcessInfo:     ';
h_source    = 'Source:          ';
h_datum     = 'Datum:           WGS 84';
h_UERE      = 'Set UERE:        ';
h_DataL     = 'Data Length:     '; 

h_field     = 'GPSTime      Latitude       Longitude      H-Ell     SDNorth  SDEast   SDHeight   X-ECEF         Y-ECEF          Z-ECEF         SDX-ECEF  SDY-ECEF SDZ-ECEF';
h_funit     = '(sec)        (Deg)          (Deg)          (m)       (m)      (m)      (m)        (m)            (m)             (m)            (m)       (m)      (m)';


n = length(Data);

c = clock;
fid = fopen(FName, 'wt');
fprintf(fid, '%s   \n', h_program);
fprintf(fid, '%s%s \n', h_project, Project);
fprintf(fid, '%s%02.0f.%02.0f.%02.0f %02.0f:%02.0f:%02.0f \n', h_process,c(3),c(2),c(1),c(4),c(5),c(6));
fprintf(fid, '%s%s   \n',h_source,Mode);
fprintf(fid, '%s   \n',h_datum);
fprintf(fid, '%s%i%s \n',h_UERE, UERE,'m');

DL = Data(n,1)-Data(1,1);
fprintf(fid, '%s%.3f%s \n\n\n',h_DataL, DL,' seconds');

fprintf(fid, '%s   \n',h_field);
fprintf(fid, '%s   \n',h_funit);


for i = 1:n
    fprintf(fid, '%f %.10f %.10f %f %f %f %f %f %f %f %f %f %f  \n',Data(i,:));
end


end

