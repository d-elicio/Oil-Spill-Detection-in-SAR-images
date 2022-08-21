function [BW]=kmeansSegment_for_land(img,ground,gaussFilt,numClusters,numBlobs)

tic

%% IMAGE ENHANCEMENT
grayImg=imgaussfilt(img,'FilterSize',gaussFilt);

%% K-MEANS CLUSTERING
[rows, columns] = size(grayImg);

%experimentally has been seen that the best results can be obtained with 5 clusters
numberOfClusters = numClusters;

% Convert to column vector
grayLevels = double(grayImg(:)); 

%kmeans MATLAB function is used
[clusterIndexes, clusterCenters] = kmeans(grayLevels, numberOfClusters,'Replicates', 5,...
    'MaxIter',350);
labeledImage = reshape(clusterIndexes, rows, columns);

%Every blob has a different color to visually show distinct blobs
caption = sprintf('k-means with %d clusters', numberOfClusters);
figure('WindowState', 'maximized');
imshow(label2rgb (labeledImage, 'hsv', 'k', 'shuffle'),[]),title(caption);



%% OIL SPILL DETECTION PHASE:
% We will assume the oil spill is the darkest class (between the clusters)
% The cluster center will be the mean gray level of the class.. so we now try to find the darkest class  
[minValue, indexOfMinValue] = min(clusterCenters);

%We also assume that the land is the brightest class
[maxValue,indexOfMaxValue] = max(clusterCenters);

% Get pixels that are labeled as the oil spill and as the land
oilSpill = labeledImage == indexOfMinValue;
land = labeledImage == indexOfMaxValue;

% Extract the largest blobs;
blobsToExtract=numBlobs;
oilSpill=bwareafilt(oilSpill, blobsToExtract);
land=bwareafilt(land, blobsToExtract);

% Fill holes.
oilSpill=imfill(oilSpill, 'holes');
land=imfill(land, 'holes');


%% Mask coloring and overlay on the original image
background=zeros(size(img),'double');
mascheraSpill=imoverlay(background,oilSpill,'cyan');

%Call to function that shows mask and images
visualizeImages_for_land(img,land,ground,mascheraSpill,'K-MEANS CLUSTERING OIL + LAND SEGMENTATION');


%Used for the segmentation_evaluation function
BW=or(oilSpill,land);



toc
end
