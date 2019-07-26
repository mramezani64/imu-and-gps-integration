function [F0,F1,Fw] = addglo(F,w)

nr = size(F,1);
nc = size(F,2);

F0 = F; F1 = F;

F0(nr+1,nc+1) = 0;
F1(nr+1,nc+1) = 1;
Fw(nr+1,nc+1) = w;

end