function [ INS, n_rows , Rw , Bs] = INS_Import( f_INS, f_INS_NP )
%INS_IMPORT Import IMU measurements and its noise parameters

%% IMU data
disp('Importing INS data...');

IMU_f = dlmread(f_INS,' ',0,0);

% IMU_f = fopen(f_INS);
% IMU_f = textscan(IMU_f,'%f %f %f %f %f %f %f');

INS = IMU_f;

%Rescale Measurements if needed
% INS(:,3:5) = INS(:,3:5)/9.80665;

%size
n_rows = length(INS);


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

