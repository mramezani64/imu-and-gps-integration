function [ i_1, i_2 ] = InitTime( D1, D2, i_1, i_2, D1_TI , D2_TI, time)
%Initialize time

D1_t = D1(i_1,D1_TI);
D2_t = D2(i_2,D2_TI);

if isempty(time) ~= 1
    Stime = time(1);
        
    while D1_t < Stime
        i_1     = i_1 + 1;
        D1_t    = D1(i_1,D1_TI);
    end
    while D2_t < Stime
        i_2     = i_2 + 1;        
        D2_t    = D2(i_2,D2_TI);
    end
%     fprintf('Time is now aligned: Data 1 - %.2f Data 2 - %.2f \n\n', D1_t, D2_t);
else
    if D1_t > D2_t
        fprintf('Initial time matching: Data 2 starts before Data 1 \n')
        while D1_t > D2_t
            i_2     = i_2 + 1;
            D2_t    = D2(i_2,D2_TI);
        end
    else
        fprintf('Initial time matching: Data 1 starts before Data 2 \n')
        while D2_t > D1_t
            i_1     = i_1 + 1;            
            D1_t    = D1(i_1,D1_TI);
        end
    end
    
    fprintf('Time is now aligned: Data 1 - %.2f Data 2 - %.2f \n\n', D1_t, D2_t);
end

end

