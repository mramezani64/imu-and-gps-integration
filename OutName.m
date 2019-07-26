%% Output name

if Cmode == 0; txt_C = '_woC'; else txt_C = '_wC'; end
if Vmode == 0; txt_S = '_woS'; else txt_S = '_wS'; end
if raim.m == 0; txt_R = '_woR'; else txt_R = '_wR'; end

txt_f = strcat('PVA_',PVA.mode,txt_C,txt_S,txt_R);

% output name
f_out_m = strcat(txt_f,'.mat');
f_out_k = strcat(txt_f,'.kml');