function [Rw , Bs] = INS_Import_NP(f_INS_NP )
%INS_Import_NP Import IMU Noise parameters

%% IMU noise parameters
fide = fopen(f_INS_NP);
while 1  % We skip header
    line = fgetl(fide);
    answer = findstr(line,'END OF HEADER');
    if ~isempty(answer), break;	end;
end;

Rw = [];
Bs = [];

for i = 1:16
    line = fgetl(fide);
    str = textscan(line,'%s');
    if i > 1 && i < 5
        Rw = [Rw; str2double(str{1,1}{2,1})];
    elseif i > 5 && i < 9
        Rw = [Rw; str2double(str{1,1}{2,1})];
    elseif i > 9 && i < 13
        Bs = [Bs; str2double(str{1,1}{2,1}) str2double(str{1,1}{3,1}) ];
    elseif i > 13 && i < 17
        Bs = [Bs; str2double(str{1,1}{2,1}) str2double(str{1,1}{3,1}) ];
    end
end



end

