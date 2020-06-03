
clc
clear all
close all

load 'E:\MATLAB_R2016a_Installation\MATLAB\GAN\AutoEnc9VDSR.mat'

net = AutoEnc9VDSR;

dc = dir('*.tiff');

path='E:\MATLAB_R2016a_Installation\MATLAB\GAN\ON';

for i = 1:size(dc)
    
  varName = dc(i).name;  % output string
  [~, baseFileName, ~] = fileparts(varName);
  K = imread(varName);
  try
      numParts = ceil(size(K,2)/120)+1;
  catch
      numParts = ceil(size(K,2)/120);
  end
  

   
  J = imresize(K,[120,120*numParts],'bicubic');
  
  Reconst_Image=[];
  
  for j = 1 : numParts
      
      LR = J(:,(120*(j-1)+1):120*j);
%   imwrite( LR , [baseFileName,'_P',num2str(j),'.jpg']);
%   LR = imbinarize(LR);
      HR = predict(net, im2single(LR));
      
%       Reconst_Image = [Reconst_Image HR(3:120-3,:)];
Reconst_Image = [Reconst_Image HR];
%       imwrite( Reconst_Image , ['HR_',baseFileName,'.jpg']);
      
  end
   Reconst_Image = imbinarize(Reconst_Image);
%   Reconst_Image=imresize(Reconst_Image,[67,632],'bicubic');
      imwrite( Reconst_Image , ['HR_',baseFileName,'.jpg']);
end

 