clear

folder_path = uigetdir('', '选择文件夹');
if folder_path == 0
    disp('未选择文件夹。');
    return;
end

imds = imageDatastore(folder_path, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');


labels = unique(imds.Labels);  
trainFiles = {};  
valFiles = {};   

for i = 1:numel(labels)
    labelIdx = find(imds.Labels == labels(i)); 
    numImages = numel(labelIdx); 

    valIdx = labelIdx(1:5:numImages); 
    trainIdx = setdiff(labelIdx, valIdx); 

    trainFiles = [trainFiles; imds.Files(trainIdx)];
    valFiles = [valFiles; imds.Files(valIdx)];
end

imdsTrain = imageDatastore(trainFiles, 'LabelSource', 'none');
trainLabels = {};
for i = 1:numel(trainFiles)
    [~, folder_name, ~] = fileparts(fileparts(trainFiles{i}));
    trainLabels = [trainLabels; folder_name];
end
imdsTrain.Labels = categorical(trainLabels);
imdsValidation = imageDatastore(valFiles, 'LabelSource', 'none');

valLabels = {};
for i = 1:numel(valFiles)
    [~, folder_name, ~] = fileparts(fileparts(valFiles{i}));
    valLabels = [valLabels; folder_name];
end
imdsValidation.Labels = categorical(valLabels);


numTrainFiles = numel(imdsTrain.Files); 
numValFiles = numel(imdsValidation.Files); 
   

net = alexnet;

layersTransfer = net.Layers(1:end-3);

numClasses = numel(categories(imdsTrain.Labels));

layers = [
    layersTransfer  
    fullyConnectedLayer(numClasses)  
    softmaxLayer                 
    classificationLayer  
    ];

inputSize = net.Layers(1).InputSize;

augimdsTrain = augmentedImageDatastore(inputSize(1:2), imdsTrain);
augimdsValidation = augmentedImageDatastore(inputSize(1:2), imdsValidation);

analyzeNetwork(layers);

options = trainingOptions('sgdm', ...
    'MiniBatchSize', 15, ...
    'MaxEpochs', 25, ...
    'InitialLearnRate', 0.001, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', augimdsValidation, ...
    'ValidationFrequency', 3, ...
    'Verbose', true, ...
    'Plots', 'training-progress');

[netTransfer,info] = trainNetwork(augimdsTrain, layers, options);

[YPred, ~] = classify(netTransfer, augimdsValidation);

idx = randperm(numel(imdsValidation.Files), 9);
figure
for i = 1:9
    subplot(3, 3, i)
    I = readimage(imdsValidation, idx(i));
    imshow(I)

    image_folder = fileparts(imdsValidation.Files{idx(i)});
    [~, folder_name, ~] = fileparts(image_folder);

    label = YPred(idx(i));
    title(sprintf('%s - 原始类别：%s', string(label), folder_name));
end

YValidation = imdsValidation.Labels;
accuracy = mean(YPred == YValidation);

figure
confusionchart(YValidation, YPred);

figure
subplot(2,2,1)
plot(info.TrainingLoss, 'LineWidth', 2); 
title('a：Training Loss');
xlabel('Iteration');
ylabel('Loss');
grid on;

subplot(2,2,2)
plot(info.TrainingAccuracy, 'LineWidth', 2); 
title('b：Training Accuracy');
xlabel('Iteration');
ylabel('Accuracy');
grid on;

subplot(2,2,3)
A=info.ValidationLoss;

B=A(~isnan(A));

plot(B, 'LineWidth', 2);
title('c：Validation Loss');
xlabel('Iteration');
ylabel('Loss');
grid on;

subplot(2,2,4)
C=info.ValidationAccuracy;
D=C(~isnan(C));
plot(D, 'LineWidth', 2); 
title('d：Validation Accuracy');
xlabel('Iteration');
ylabel('Accuracy');
grid on;

categories = unique(YValidation);
numCategories = numel(categories);
categoryAccuracy = zeros(numCategories, 1);

for i = 1:numCategories
    category = categories(i);
    idx = YValidation == category;
    categoryAccuracy(i) = mean(YPred(idx) == category);
end

disp('每个分类类别的准确率：');
for i = 1:numCategories
    fprintf('类别 %s 的准确率: %.2f%%\n', string(categories(i)), categoryAccuracy(i) * 100);
end

