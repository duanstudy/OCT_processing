%Calculates the Geometric Average Error (GAE)
%GAE is the measure which tells if transformed image is very bad. 
%GAE will only be positive in case when every pixel value is different 
%in original and transformed image. Therefore GAE is zero for haniaglass256-a 
%because we got a very good transformation of the original. 
%But since the transform for the haniaglass256-b was extremely bad 
%therefore GAE for that transform was 0.9887. 
%C.P.Loizou 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T = DsQEGAE(P,Q);
len=(size(P,1));
wid=(size(P,2));
P=double(P)/255;
Q=double(Q)/255;
M=ones(len);
T=1;


for i = 1:len
    for j=1:wid
        
         % For a 2-D image
        Pr=P(i,j);
        Qr=Q(i,j);
        
%         Pr=P(i,j,1);
%         Pg=P(i,j,2);
%         Pb=P(i,j,3);
%         
%         Qr=Q(i,j,1);
%         Qg=Q(i,j,2);
%         Qb=Q(i,j,3);
%         
%         mag =(((Pr-Qr)^2) + ((Pg-Qg)^2) + ((Pb-Qb)^2))^0.5;
      
        mag=((Pr-Qr)^2)^0.5;
        T=T*mag;
        
    end
end
T=T^(1/(len*wid));

