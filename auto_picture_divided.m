
[filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files (*.jpg, *.png, *.bmp, *.tif)'}, 'Select an Image');
if isequal(filename, 0)
    disp('User canceled the operation');
    return;
end
inputImage = imread(fullfile(pathname, filename));

[height, width, ~] = size(inputImage);


sliceHeight = 196;  
numSlices = floor(height / sliceHeight); 


if numSlices == 0
    disp('Image height is less than 196 pixels. No slices will be generated.');
    return;
end

outputFolder = uigetdir('', 'Select the Folder to Save Slices');
if isequal(outputFolder, 0)
    disp('User canceled the operation');
    return;
end


for i = 1:numSlices

    startRow = (i-1)*sliceHeight + 1;
    endRow = i*sliceHeight;
    
    slice = inputImage(startRow:endRow, :, :);
    
    outputFilename = fullfile(outputFolder, sprintf('%d.png', i));
    
    imwrite(slice, outputFilename, 'png');
    fprintf('Saved: %s\n', outputFilename);
end

disp('Image slicing completed! Files named as 1.png, 2.png, ...');