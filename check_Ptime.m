function [ flg ] = check_Ptime( INS, Ptime )
%CHECK_PTIME

flg = 0;

if isempty(Ptime) == 0 % check processing time
    if Ptime(2) ~= 0
        if INS.INS(INS.i+1,1) > Ptime(2); flg = 1; end
    end
end



end

