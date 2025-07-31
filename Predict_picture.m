[netFile, netPath] = uigetfile('*.mat', '选择预训练好的网络文件');
if isequal(netFile, 0)
    disp('未选择网络文件。');
    return;
end
loadedNet = load(fullfile(netPath, netFile));
netTransfer = loadedNet.netTransfer; 


[filename, pathname] = uigetfile('*.png', 'Select a PNG image');
if isequal(filename, 0)
    disp('User selected Cancel');
    all_predictions = [];
    num_windows = 0;
    step_size = 0;
    rgb_image = [];
    filename = '';
    return;
else
    image_path = fullfile(pathname, filename);
    
    rgb_image = imread(image_path);
    
    num_samples = size(rgb_image, 1);

    inputSize = netTransfer.Layers(1).InputSize;
    
    if size(rgb_image, 3) == 1
        rgb_image = cat(3, rgb_image, rgb_image, rgb_image); 
    end
end 

window_size = 196; 
step_size = 98; 

num_windows = floor((num_samples - window_size) / step_size) + 1;

all_predictions = cell(num_windows, 1);

for i = 1:num_windows
    window_data = rgb_image((i-1)*step_size + 1:(i-1)*step_size + window_size, :, :);
    
    window_data_resized = imresize(window_data, inputSize(1:2));
    
    predictions = classify(netTransfer, window_data_resized);

    all_predictions{i} = predictions;
end

excel_file = 'predictions.xlsx';
predictions_cell = reshape(all_predictions, num_windows, 1);  
writecell(predictions_cell, excel_file); 

