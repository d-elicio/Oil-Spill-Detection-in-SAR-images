function [maschera,BW]=kmeansSegment(img,ground,filter,numClusters,numBlobs)

tic
%% IMAGE ENHANCEMENT
grayImg=imgaussfilt(img,'FilterSize',filter);

%% K-MEANS CLUSTERING
[rows, columns] = size(grayImg);

%experimentally has been seen that the best results can be obtained with 5 clusters
numberOfClusters = numClusters;

% Convert to column vector
grayLevels = double(grayImg(:)); 

%kmeans function is used
[clusterIndexes, clusterCenters] = kmeans(grayLevels, numberOfClusters,'Replicates', 5,...
    'MaxIter',350);
labeledImage = reshape(clusterIndexes, rows, columns);

caption = sprintf('k-means with %d clusters', numberOfClusters);
figure('WindowState', 'maximized');
imshow(label2rgb (labeledImage, 'hsv', 'k', 'shuffle'),[]),title(caption);

% Every blob has a different color to visually show distinct blobs
%coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); 
%figure,imshow(coloredLabels),title('Colored labels');

%% OIL SPILL DETECTION PHASE:
% We will assume the oil spill is the darkest class (between the clusters)
% The cluster center will be the mean gray level of the class.. so we now try to find the darkest class  
[minValue, indexOfMaxValue] = min(clusterCenters);

% Get pixels that are labeled as the oil spill
oilSpill = labeledImage == indexOfMaxValue;

% Extract the largest blobs;
blobsToExtract=numBlobs;
oilSpill=bwareafilt(oilSpill, blobsToExtract);

% Fill holes.
oilSpill=imfill(oilSpill, 'holes');

%figure,imshow(oilSpill, []),title('K-MEANS SEGMENTATION: MASK');


%% Mask coloring and overlay on the original image

visualizeImages(img,oilSpill,ground,'K-MEANS CLUSTERING SEGMENTATION');

background=zeros(size(img),'double');
maschera=imoverlay(background,oilSpill,'cyan');

%Used for the segmentation_evaluation function:
BW=oilSpill;



toc
end
