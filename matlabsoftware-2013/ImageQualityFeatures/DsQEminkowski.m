%Calculates the error summation in the form  of the Minkowski metric
% this is the norm of the disimilarity between two images. For b=2 one obtains the root of the MSE,
% for b=1 one obtain the absolute difference and for b=apiro the maximum difference measure between 
% the two image max(abs(a-b))
% The function output is the Minkowski metric in the 3rd and the fourth power

function [M3, M4] = DsQEminkowski(P,Q);
len=(size(P,1));
wid=(size(P,2));
P=double(P);
Q=double(Q);
M3=0; M4=0;
for i = 1:len
    for j=1:wid
        
% For a 2-D Image       
        Pr=P(i,j);
        Qr=Q(i,j);
        
      
% For a 3-D Image
%         Pr=P(i,j,1);
%         Pg=P(i,j,2);
%         Pb=P(i,j,3);
%         
%         Qr=Q(i,j,1);
%         Qg=Q(i,j,2);
%         Qb=Q(i,j,3);
        
       % mag =((Pr-Qr)^2) + ((Pg-Qg)^2) + ((Pb-Qb)^2);
       mag3=(abs(Pr-Qr)^3);
       mag4=(abs(Pr-Qr)^4);
        M3=M3+mag3;
        M4=M4+mag4;
        
    end
end

M3=(M3/(len*wid))^(1/3);
M4=(M4/(len*wid))^(1/4);



