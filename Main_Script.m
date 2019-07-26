clear all; close all; clc

F_out = ['PVA_M2_1C.mat','PVA_M2_1C.kml'];

for i = 1:2
    % output name
    f_out   = F_out(i,1);
    f_out_k = F_out(i,2);
    run(Main_INSGNSS);
end