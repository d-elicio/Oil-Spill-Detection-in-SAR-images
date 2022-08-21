function [BW,max_value] = manual_thresholding(img,ground,addValue,maxArea,medianFilter)
tic

%% Image Smoothing operation with median filter:
grayImg=medfilt2(img,[medianFilter medianFilter]);
%figure, 
%subplot(1,4,[1 2]), imshow(img), title('Original Image')
%subplot(1,4,[3 4]),imshow(grayImg), title('Median filter smoothed image')

%% Contrast enhancement (Histogram equalization):
eqImg=histeq(grayImg,50);

%% Gray and equalized image histograms comparison:
%figure
%subplot(1,2,1), imhist(grayImg),title('Original Gray Image Histogram ')
%subplot(1,2,2), imhist(eqImg), title('Equalized Image Histogram')


%% MANUAL THRESHOLDING:
%Manually choose pixels to use for thresholding:
figure('WindowState', 'maximized') 
pixel_values=impixel(eqImg);

%Computation of min and max values for the chosen pixels
min_value=min(pixel_values(:,1,1));
max_value=max(pixel_values(:,1,1));

if (min_value==0 && max_value==0) || (min_value==max_value)
    max_value=min_value+addValue;
elseif max_value~=0
    max_value=max_value+addValue;
end

%Binary mask creation:
% mask=imbinarize(eqImg,[min_value:max_value]);
%mask= ~mask;
mask=eqImg>=min_value & eqImg<=max_value;
%figure, imshow(mask),title('Maschera dopo manual thresholding')

%% Opening & Closing morphological operations to eliminate isolated white dots:
se=strel('disk',1);
mask= imopen(mask,se);
%mask=imclose(mask,se);
%figure, imshow(mask), title('Maschera dopo Opening & Closing')

%% "imfill" to fill blank areas
filledMask = imfill(mask, 'holes');
%figure, imshow(binaryImage), title('Maschera dopo imfill')





%% SPOT FEATURES EXTRACTIONS:
%Label connected components in 2-D binary image (useful to use regionprops later) 
[labeledImage, ~] = bwlabel(filledMask, 4);

% figure
% imshow(labeledImage, []);  % Show the gray scale image.
% title('Labeled Image, from bwlabel()');

% Let's assign each blob a different color to visually show the distinct blobs
%coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); % pseudo random color labels
%figure,imshow(coloredLabels);

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

% statsStd = [stats.StandardDeviation];
% lowStd = find(statsStd >11 && statsStd<42.91);
% for k = 1:length(lowStd)
%     rectangle('Position',s(lowStd(k)).BoundingBox,'EdgeColor','y');
% end

% idx=find( statsStd >11 & statsStd<42.91); 
% norm=normalize(vertcat(stats.StandardDeviation),'range')*100;
% figure
% bar(1:numberOfBlobs,norm)
% xlabel('Region Label Number')
% ylabel('Standard Deviation')

%Find blobs with an area >45pixels^2 ~450m^2 in real world
idx=find([stats.Area]>maxArea);
BW=ismember(labelmatrix(cc),idx);

%figure, imshow(BW), title('maschera finale tenendo conto delle AREE')

%% Mask coloring and overlay on the original image

visualizeImages(img,BW,ground,'MANUAL THRESHOLDING');



toc
end