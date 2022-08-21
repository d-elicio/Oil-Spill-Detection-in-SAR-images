function [maschera,BW] = automatic_threshold(img,ground,maxArea,medFilter)

tic

%% Image Smoothing operation with median filter:
grayImg=medfilt2(img,[medFilter medFilter]);
%figure, imshow(grayImg), title('Original image')

%% Contrast enhancement (Histogram equalization):
eqImg=histeq(grayImg,50);

%% Gray and equalized image histograms comparison:
% subplot(1,2,1), imhist(grayImg)
% title('Istogramma Gray Image')
% subplot(1,2,2), imhist(eqImg);
% title('Istogramma immagine Equalizzata')

%% AUTOMATIC THRESHOLDING:
[counts,binLocations]=imhist(eqImg);
A=[counts,binLocations];

%% Finding two threshold values: 
valueMax= max(max([counts,binLocations]));
valueMin= min(min([counts,binLocations]));
[row column]= find(A==valueMax,1,'first');
%Maximum threshold value:
Tmax=A(row,2);
[r c]= find(A==valueMin,1,'first');
%Minimum threshold value:
Tmin=A(r,2);

%If Tmin=0 means that there are no pixel with that value, so you have to use only Tmax
if Tmin==0
    mask=imbinarize(eqImg,Tmax);
else
    mask=imbinarize(eqImg,Tmin:Tmax);
end

mask=~mask;


%% Opening & Closing morphological operations to eliminate isolated white dots:
se=strel('disk',2);
openedImg= imopen(mask,se);
closedImg= imclose(openedImg,se);
%figure, imshow(mask), title('Maschera dopo Opening')

%% "imfill" to fill blank areas
filledMask = imfill(closedImg, 'holes');


%% SPOT FEATURES EXTRACTIONS:
[labeledImage, ~] = bwlabel(filledMask, 8);

% figure
% imshow(labeledImage, []);  % Show the gray scale image.
% title('Labeled Image, from bwlabel()');

% Let's assign each blob a different color to visually show the user the distinct blobs.
%coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); % pseudo random color labels
%figure, imshow(coloredLabels);

% Get all the blob properties.
cc=bwconncomp(filledMask);
stats = regionprops(labeledImage, img, 'all');


%Computation of std deviation:
% for k = 1:numberOfBlobs
%     stats(k).StandardDeviation = std(double(stats(k).PixelValues));
%     text(stats(k).Centroid(1),stats(k).Centroid(2), ...
%         sprintf('%2.1f', stats(k).StandardDeviation), ...
%         'EdgeColor','b','Color','r');
% end

%statsStd = [stats.StandardDeviation];
% lowStd = find(statsStd >11 && statsStd<42.91);
% for k = 1:length(lowStd)
%     rectangle('Position',s(lowStd(k)).BoundingBox,'EdgeColor','y');
% end

%idx=find( statsStd >11 & statsStd<42.91); 
% norm=rescale(vertcat(stats.StandardDeviation),0,100);
% figure
% bar(1:numberOfBlobs,norm)
% xlabel('Region Label Number')
% ylabel('Standard Deviation')

%GRAFICO AREA
% figure
% bar(1:numberOfBlobs,[stats.Area])
% xlabel('Region Label Number')
% ylabel('Area')

%Find blobs with an area >45pixels^2 ~450m^2 in real world
%Default value of maxArea=45;
idx=find([stats.Area]>maxArea); %| norm >=10 & norm<32.91);
BW=ismember(labelmatrix(cc),idx);
%figure, imshow(BW), title('maschera finale tenendo conto delle AREE')

%% Mask coloring and overlay on the original image
visualizeImages(img,BW,ground,'AUTOMATIC THRESHOLDING');


%This is useful to reuse this function when it is called from the land_mask function: 
background=zeros(size(img),'double');
maschera=imoverlay(background,BW,'cyan');


toc
end