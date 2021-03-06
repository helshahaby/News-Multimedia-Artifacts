
%% AE Feature Extraction

clc
clear all
close all

% reset(gpuDevice(1))

HRpath = 'E:\MATLAB_R2016a_Installation\MATLAB\GAN_Dataset_120_1740\HighResolution';

imds = imageDatastore(HRpath,...
'IncludeSubfolders',true,'LabelSource','foldernames');

imds.ReadSize = 500;

rng(0)

imds = shuffle(imds);

[imdsTrain,imdsVal,imdsTest] = splitEachLabel(imds,0.95,0.025,'randomize');

dsTrainNoisy = transform(imdsTrain,@addNoise);
dsValNoisy = transform(imdsVal,@addNoise);
dsTestNoisy = transform(imdsTest,@addNoise);

dsTrain = combine(dsTrainNoisy,imdsTrain);
dsVal = combine(dsValNoisy,imdsVal);
dsTest = combine(dsTestNoisy,imdsTest);

dsTrain = transform(dsTrain,@commonPreprocessing);
dsVal = transform(dsVal,@commonPreprocessing);
dsTest = transform(dsTest,@commonPreprocessing);

exampleData = preview(dsTrain);
inputs = exampleData(:,1);
responses = exampleData(:,2);
minibatch = cat(2,inputs,responses);
montage(minibatch','Size',[8 2])
title('Inputs (Left) and Responses (Right)')


imageLayer = imageInputLayer([120,120,1] ,'Name','InputLayer','Normalization','none' );

encodingLayers = [ ...
    convolution2dLayer(1 , 64 , 'Stride',1 ,'Name','Conv1'), ...
    reluLayer('Name','RL_1'), ...
    maxPooling2dLayer(1,'Stride',1, 'Name','maxPool_1'), ...
    convolution2dLayer(1 , 32 , 'Stride',1 ,'Name','Conv2'), ...
    reluLayer('Name','RL_2'), ...
    maxPooling2dLayer(1,'Stride',1, 'Name','maxPool_2'), ...
    convolution2dLayer(1 , 16 , 'Stride',1 ,'Name','Conv3' ), ...
    reluLayer('Name','RL_2a'), ...
    convolution2dLayer(1 , 8 , 'Stride',1,'Name','Conv4' ), ...
    reluLayer('Name','RL_2b'), ...
    convolution2dLayer(1 , 4 , 'Stride',1,'Name','Conv5' ), ...
    reluLayer('Name','RL_2c'), ...
    maxPooling2dLayer(2,'Stride',2, 'Name','maxPool_3')];


decodingLayers = [ ...
    transposedConv2dLayer(4,4 , 'Stride',2,'Cropping',1, 'Name','TransConv1'), ...
    reluLayer( 'Name','RL3'), ...
    transposedConv2dLayer(1,8 , 'Stride',1,'Name','TransConv2'), ...
    reluLayer( 'Name','RL4'), ...
    transposedConv2dLayer(1,16 , 'Stride',1,'Name','TransConv3'), ...
    reluLayer( 'Name','RL5'), ...
    transposedConv2dLayer(1,32 , 'Stride',1,'Name','TransConv4'), ...
    reluLayer( 'Name','RL6'), ...
    transposedConv2dLayer(1,64 , 'Stride',1,'Name','TransConv5'), ...
    reluLayer( 'Name','RL7'), ...
    convolution2dLayer(1,64 , 'Stride',1,'Name','Conv6','WeightsInitializer','he','BiasInitializer','zeros'), ...
    reluLayer( 'Name','RL8'), ...
    convolution2dLayer(1,64 , 'Stride',1,'Name','Conv7','WeightsInitializer','he','BiasInitializer','zeros'), ...
    reluLayer( 'Name','RL9'), ...
    convolution2dLayer(1,64 , 'Stride',1,'Name','Conv8','WeightsInitializer','he','BiasInitializer','zeros'), ...
    reluLayer( 'Name','RL10'), ...
    convolution2dLayer(1,64 , 'Stride',1,'Name','Conv9','WeightsInitializer','he','BiasInitializer','zeros'), ...
    reluLayer( 'Name','RL11'), ...
    convolution2dLayer(1,64 , 'Stride',1,'Name','Conv10','WeightsInitializer','he','BiasInitializer','zeros'), ...
    reluLayer( 'Name','RL12'), ...
    convolution2dLayer(1,64 , 'Stride',1,'Name','Conv11','WeightsInitializer','he','BiasInitializer','zeros'), ...
    reluLayer( 'Name','RL13'), ...
    convolution2dLayer(1,64 , 'Stride',1,'Name','Conv12','WeightsInitializer','he','BiasInitializer','zeros'), ...
    reluLayer( 'Name','RL14'), ...
    convolution2dLayer(1,64 , 'Stride',1,'Name','Conv13','WeightsInitializer','he','BiasInitializer','zeros'), ...
    reluLayer( 'Name','RL15'), ...
    convolution2dLayer(1,64 , 'Stride',1,'Name','Conv14','WeightsInitializer','he','BiasInitializer','zeros'), ...
    reluLayer( 'Name','RL16'), ...
    convolution2dLayer(1,64 , 'Stride',1,'Name','Conv15','WeightsInitializer','he','BiasInitializer','zeros'), ...
    reluLayer( 'Name','RL17'), ...
    convolution2dLayer(1, 1 , 'Stride',1,'Name','Conv16','WeightsInitializer','he','BiasInitializer','zeros','NumChannels',64), ...  
    regressionLayer( 'Name','routput')];

layers = [imageLayer,encodingLayers,decodingLayers];


% options = trainingOptions('adam', ...
%     'MaxEpochs',20, ...
%     'MiniBatchSize',imds.ReadSize, ...
%     'ValidationData',dsVal, ...
%     'Shuffle','never', ...
%     'Plots','training-progress', ...
%     'Verbose',false);

maxEpochs = 100;
epochIntervals = 1;
initLearningRate = 0.1;
learningRateFactor = 0.1;
l2reg = 0.0001;
miniBatchSize = 64;
options = trainingOptions('sgdm', ...
    'Momentum',0.9, ...
    'InitialLearnRate',initLearningRate, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',10, ...
    'LearnRateDropFactor',learningRateFactor, ...
    'L2Regularization',l2reg, ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'GradientThresholdMethod','l2norm', ...
    'GradientThreshold',0.01, ...
    'Plots','training-progress', ...
    'Verbose',false);

net = trainNetwork(dsTrain,layers,options);

AutoEnc9VDSR  = net;

save AutoEnc9VDSR 

ypred = predict(net,dsTest);

inputImageExamples = preview(dsTest);

montage({inputImageExamples{1},ypred(:,:,:,1)});
ref = inputImageExamples{1,2};
originalNoisyImage = inputImageExamples{1,1};
psnrNoisy = psnr(originalNoisyImage,ref)
psnrDenoised = psnr(ypred(:,:,:,1),ref)


montage({inputImageExamples{2},ypred(:,:,:,2)});
ref = inputImageExamples{2,2};
originalNoisyImage = inputImageExamples{2,1};
psnrNoisy = psnr(originalNoisyImage,ref)
psnrDenoised = psnr(ypred(:,:,:,2),ref)



% psnrNoisy =
% 
%   single
% 
%    21.3383
% 
% 
% psnrDenoised =
% 
%   single
% 
%    26.1668



