function t = str2time(time)
%STR2TIME 

if time(1) < 100; 
    if time(1) < 80
        time(1) = time(1) + 2000;
    else
        time(1) = time(1) + 1900;
    end
end

t = epoch2time(time);

end

