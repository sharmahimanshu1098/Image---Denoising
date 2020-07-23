close all;
clc;clear all;
 
% Enter the total number of images for algorithm...remember name the image
% like IMG0001 in increasing order
 
% Enter the noise here to be added (noise percentage added will be same for
% all)
percentage = str2double(cell2mat(inputdlg('Enter the percent noise: ', 'Noise Density', 1, {'2'}))) / 100;     %percentage of noise to corrupt i/p img
 
 
no = 35; 
 
%for ti = 11 : no
 
    clearvars -except Res no ti percentage
    
    %if (ti < 10)
    %y2 =imread(['D:\EURASIP\Eurasipcode\IMG000',num2str(ti),'.bmp']);
    y2 = imread('lena.jpg');
    %else
    %y2 =imread(['D:\EURASIP\Eurasipcode\lena.jpg']); 
    %y2 =imread(['MATLAB Drive/Published/IMG00',num2str(ti),'.bmp']);
    %end
    
y5=imresize(y2,[256,256]);
y5=y5(:,:,1);
%y5=imcrop(y5,[130 130 50 60]);
img=y5;
 
figure;
subplot(1,3,1);
imshow(y5);
title('Original image');
xlabel('(a)');
[m,n,f]=size(y5);
[rows,cols,f]=size(y5);
a5=y5;
b4=a5;
 
 
%%%%%%%%%%%%%%% ADD RV NOISE %%%%%%%%%%%%%%%%%%%%%%
 
totalPixels = int32(rows * cols);                

numberOfNoisePixels = int32(percentage * double(rows) * double(cols));     %no of pixels to be corrupted
noisyImage = img;
m5 = 4;
pepper = 0;
 
tic;
indloc = zeros(1,numberOfNoisePixels);
 
for n5 = 1:numberOfNoisePixels
    
    if n5==1
        locations = randi(totalPixels) ;    
        indloc(n5) = locations;
    else
        while 1
            locations = randi(totalPixels);
            upix = find(indloc==locations);
            
            if isempty(upix==1)
                indloc(n5) = locations;
                break;
            end
        end
        
    end
    
    if pepper == 0
        noiseValue = randi([0,m5]);                   %corrupt image with pepper noise
      %        noiseValue = 0;                   %corrupt image with pepper noise
        pepper = 1;
    elseif pepper == 1
        noiseValue = randi([255-m5, 255]);        %corrupt image with salt noise
     %   noiseValue = 255;        %corrupt image with salt noise
        pepper = 0;
    end
    noisyImage(locations) = noiseValue;          %salt and pepper noise added in random locations   
end
 
Noise1 = double(img) - double(noisyImage);
 
NoiseCount = 0;
 
for i=1:rows
    for j=1:cols
        if Noise1(i,j)== 0   % same value
            Noise2(i,j) = 1;
            
        else
            Noise2(i,j)  = 0;
            NoiseCount = NoiseCount+1;
        end
        
    end
end
 
NoiseCount;
percentagepixelchanged = (NoiseCount*100)/(rows*cols);
 
figure;
subplot(1,3,2);
imshow(noisyImage);
title('Noisy image');
xlabel('(b)');
 
a5=noisyImage;
a15=noisyImage;
[m,n,f]=size(a5);
 
%****************************** NAFSWM *****************************************
var=percentage;
varience=var*100;
k_it=25;
 
if (varience < 95)
 
    temp=3;
    p=3;
    q=3;
    det_sum=12;
    i_int=2;
    c=zeros(m+2,n+2);
    
for i=1:1:m
    for j=1:1:n
        c(i+1,j+1)=a5(i,j);
    end
end
  
for i=1:1:n
    c(1,i+1) = a5(1,i);
    c(m+2,i+1) = a5(m,i);
end
 
for i=1:1:m+2
    c(i,1)=c(i,2);
    c(i,n+2)=c(i,n+1);
end
 
else
    
    temp=4;
    p=5;
    q=5;
    det_sum=25;
    i_int=3;
c=zeros(m+4,n+4);
 
for i=1:1:m
    for j=1:1:n
        c(i+2,j+2)=a5(i,j);
    end
end
  
for i=1:1:n
    c(2,i+2) = a5(1,i);
    c(1,i+2) = a5(1,i);
    c(m+3,i+2) = a5(m,i);
    c(m+4,i+2) = a5(m,i);
end
 
for i=1:1:m+4
    c(i,1)=c(i,3);
    c(i,2)=c(i,3);
    c(i,n+3)=c(i,n+2);
    c(i,n+4)=c(i,n+2);
end
end
 
%********************************NAFSWM IMPULSE DETECTION**********************************
for u=1:1:f
    for i=i_int:1:m+i_int-1
        for j=i_int:1:n+i_int-1
            b5=zeros(p,q);                      % p = q = 5
            for k=i_int-p:1:p-i_int
                for l=i_int-q:1:q-i_int
                    b5(i_int+k,i_int+l)=c(i+k,j+l,u);   % b5 -> 5x5 sliding window
                end
            end
            
            z=1;
            d=zeros(1,p*q);
            for k=1:1:p
                for l=1:1:q
                    if (b5(k,l) > b5(i_int,i_int))
                        d(1,z)=double((b5(k,l)-b5(i_int,i_int)))/255;       %%%%% normalized difference
                    else
                        d(1,z)=double((b5(i_int,i_int)-b5(k,l)))/255;
                    end
                        
                    z=z+1;
                end
            end
   %%%%%%% convert normalized difference to a non-linear func %%%%%%%%%%%
            g=zeros(1,p*q);
            for z=1:1:p*q                
                we=double(d(1,z));
                g(1,z) = (exp(k_it*we)-1);
            end
            
             
             s=0;
            g=sort(g);
            
            d_sum=ceil((p*q)/2)+1;
             for k=1:d_sum
                 s=s+g(1,k);
             end
             
           
            if ((s > det_sum) || (s == det_sum))        %%%%%%% if pixel under consideration > 25 set noisy         
                 n2(i-1,j-1)=0;             %%%% noisy pixel
                 n1(i-1,j-1)=0;
             %    x=1;
                else
                n2(i-1,j-1)=1;              %%%% noise free
                n1(i-1,j-1)=255;
            %    x=0;
           end
         end
     end
 end
 %imshow(n1);
 
Noise3 = double(n2);
checkNoise = double(n2) - Noise2;
 
CorrectDetection = 0;
MissDetection = 0;
FalseDetection = 0;
 
for i=1:rows
    for j=1:cols
 
        if ((Noise2(i,j)== 1 && Noise3(i,j)== 1) || (Noise2(i,j)== 0 && Noise3(i,j)== 0))  
           CorrectDetection = CorrectDetection + 1;
        end
        
        if (Noise2(i,j)== 0 && Noise3(i,j)== 1)    
           MissDetection = MissDetection + 1;
        end
        
        if (Noise2(i,j)== 1 && Noise3(i,j)== 0)   
           FalseDetection = FalseDetection + 1;
        end
                
    end
end
 
%disp ('CorrectDetection');
%disp (CorrectDetection);
CorrectDetectionPer = CorrectDetection*100/65536;
%disp ('CorrectDetectionPercentage');
%disp (CorrectDetectionPercentage);
 
%disp ('MissDetection');
%disp (MissDetection);
MissDetectionPer = MissDetection*100/65536;
%disp ('MissDetectionPercentage');
%disp (MissDetectionPercentage);
 
%disp ('FalseDetection');
%disp (FalseDetection);
FalseDetectionPer = FalseDetection*100/65536;
%disp ('FalseDetectionPercentage');
%disp (FalseDetectionPercentage);
 
 
ND1 = percentage;
ww2 = 0.5/(1+ND1);
ww1 = 1-ww2;
IncorrectDetectionQuotient = (ww1*MissDetectionPer + ww2*FalseDetectionPer); 
 
r=m;
c1=n;
%%%%%%%%%%% NAFSWM filter %%%%%%%%%%%%%%%%%5
 
for i=1:1:r
    for j=1:1:c1
        
        if(n2(i,j)==0)              %noisy
            
            c = 0;
            s = 1;
            w1 = 0;
            
            while(c==0)
    
                w1 = 0;
                for k=-s:1:s
                    for l=-s:1:s
                        if((i+k)>0 && (i+k)<=r && (j+l)>0 && (j+l)<=c1)
                            w1 = w1 + n2(i + k , j + l);
                            
                        end
                    end
                end
                
                if(w1>0)
                    c = 1;
                else
                    s = s + 1;
                end
                if(s==4)
                    c=1;
                    
                end
            end
 
 %%%%  Include WEIGHT %%%%%%%%%
 
            y = 1;
            yy=zeros(1,1);
            for t1=-s:1:s
                for t2=-s:1:s
                    if((i+t1)>0 && (i+t1)<=r && (j+t2)>0 && (j+t2)<=c1)
                      
                        if(n2(i+t1,j+t2)==1)
                            
                            
                            if( abs(y5(i+t1,j+t2) - y5(i,j))<3)
                                for jkl=1:5
                                    yy(y) = y5(i + t1 , j + t2) ;
                                    y=y+1;
                                end
                            else
                                
                            if( abs(y5(i+t1,j+t2) - y5(i,j))<6 )
                                    for jkl=1:4
                                        yy(y) = y5(i + t1 , j + t2) ;
                                        y=y+1;
                                    end
                                else
                                if( abs(y5(i+t1,j+t2) - y5(i,j))<10 )
                                    for jkl=1:2
                                        yy(y) = y5(i + t1 , j + t2) ;
                                        y=y+1;
                                    end
                                else
                                    yy(y) = y5(i + t1 , j + t2) ;
                                        y=y+1;
                                end
                            
                            end
                            end  
                            
                        end
 
                    end
                end
            end
            
           yy=sort(yy);
           [q4,q3]=size(yy);
           y=floor((q3+1)/2);
           me=(yy(y));
           
           y=1;
           yz=zeros(1,8);
  
%%%%%%%% Fuzzy membership %%%%%%%%%%%%%%
 
            for t1=-s:1:s
                for t2=-s:1:s
                    if((i+t1)>0 && (i+t1)<=r && (j+t2)>0 && (j+t2)<=c1)
%                         if(n2(i+t1,j+t2)==1)
                        
                            if(y5(i + t1 , j + t2) > y5(i,j))
                                yz(y) = y5(i + t1 , j + t2) - y5(i,j);
                                y=y+1;
                            else
                                yz(y) = y5(i,j) - y5(i + t1 , j + t2);
                                y=y+1;
                            end
%                         end
                    end
                end
            end
            yz;
            ma=max(yz);
            
            if(ma<10)
                f=0;
            elseif(10<= ma && ma<30)
                f=(ma-10)/20;
            else
                f=1;
            end
            
            q1=(1-f)*y5(i,j);
            q2=(f*me);
            ppp=q1+q2;
            a15(i,j)=q1+q2;
            
            
        end
    end
end
 
diff=zeros(r,c1);
total=0;
count1=0;
for i=1:1:r
    for j=1:1:c1
        count1=count1+1;
        if (a15(i,j)>y5(i,j))
            diff(i,j) = (a15(i,j) - y5(i,j));
        else
            diff(i,j) = (y5(i,j)-a15(i,j));
        end
    end
end
 %figure;
 %imshow(uint8(diff));
for i=1:1:r
    for j=1:1:c1
        total = total+(diff(i,j)*diff(i,j));
    end
end
toc;
tt=toc;
 
figure;
subplot(132);
imshow(a15);
title('NAFSWM output');
xlabel('(e)');
 
MSE = sum(sum((y5-a15).^2))/(m*n);
disp('MSE - NAFSWM');
disp(MSE);
 
PSNR = 10*log10((255*255)/MSE);
disp('PSNR - NAFSWM');
disp(PSNR);
 
ssimval= ssim(y5, a15);
[ssimval, ssimmap]= ssim(y5, a15);
%fprintf('The SSIM value is %0.4f.\n',ssimval);
figure; 
imshow(ssimmap,[]);
title(sprintf('ssim Index Map - Mean ssim Value is %0.4f',ssimval));
disp('SSIM - NAWFWM');
disp(ssimval);
 
