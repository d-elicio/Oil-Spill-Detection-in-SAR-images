function [BW2]= superpixel(img,ground,spNumber, minDist)

tic
%Superpixel image creation and show: 25.000 superpixel are created:
%Default number of Superpixel created is spNumber=25000;
[L,NumLabels]=superpixels(img,spNumber);
figure('WindowState', 'maximized');
%To view and draw superpixels on original image
BW = boundarymask(L);
subplot(1,4,[1 2]),imshow(imoverlay(img,BW,'red')),title('Original image scomposed in superpixels')


outputImage = zeros(size(img),'like',img);
idx = label2idx(L);

%The mean intensity value is computed for each superpixel(to apply Otsu method)
for labelVal = 1:NumLabels
    Idx = idx{labelVal};
    outputImage(Idx) = mean(img(Idx));
end    
subplot(1,4,[3 4]),imshow(outputImage,'InitialMagnification',100),title('Computation of mean intensity value for each superpixel')


%Otsu thresholding applied:
level=graythresh(outputImage);
if level>0.5
    level=level-0.25;
else 
    level=level-0.15;
end

%Image mask creation using the computed Otsu threshold: 
binary=imbinarize(outputImage,level);
binary=~binary;
%figure,imshow(binary,[]),title('Initial binary mask after applying Otsu thresholding')


%% DARK SPOT FEATURE EXTRACTION
%DISTANCE COMPUTATION FROM THE CENTRAL OIL SPILL

%Get centroids of all regions:
props = regionprops(binary, 'all');


% 2 'Area' values are computed:
%    - maxArea corresponding to the principal oil spill
%    - meanArea as minimum threshold to consider other spills in the image
allAreas=[props.Area];
%Sort resulting blobs by area and choose only 3 blobs with maximum area
sortedAreas=sort(allAreas);
maxAreaBlob=max(sortedAreas);
if size(sortedAreas,2)>=3
    low=sortedAreas(size(sortedAreas,2)-2);
    binary=bwareafilt(binary,[low maxAreaBlob]);
else
    low=0;
    binary=bwareafilt(binary,[low maxAreaBlob]);
end
%figure, imshow(binary),title('Only blobs with a certain area')

%Now you have to find the Centroid of the spill with the maxArea:
blobIndex=find(allAreas==maxAreaBlob);
blobIndexCentroid=props(blobIndex).Centroid;

%Centroid computation for all the remaining blobs  
measurements = regionprops(binary, 'Centroid');
allCentroids=[measurements.Centroid];
centroidX=allCentroids(1:2:end)';
centroidY=allCentroids(2:2:end)';
centr=[centroidX centroidY];

%Compute distances between the principal oil spill and all other blobs
%Only spills with a distance <450px (~450mt) from the principal spill are shown
distanceMatrix = pdist2(blobIndexCentroid,centr);
%Default value of minDist=450;
binary=bwlabel(binary);
ind=find(distanceMatrix<=minDist);

BW2=ismember(binary,ind);

%% Mask coloring and overlay on the original image
visualizeImages(img,BW2,ground,'SUPERPIXEL SEGMENTATION');

toc
end
