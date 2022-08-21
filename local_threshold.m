function [filledMask]= local_threshold(img,ground,noiseFilter,SharpThresh,GaussianFilter)

tic
%% IMAGE ENHANCEMENT
%adaptive filters to remove speckle
noiseRemoved=wiener2(img,[noiseFilter noiseFilter]);

sharpenedImg=imsharpen(noiseRemoved,'Radius',1.5,'Amount',1.5,'Threshold',SharpThresh);


%% Gaussian Filtering
Iblur=imgaussfilt(sharpenedImg,'FilterSize',GaussianFilter);
% figure
% subplot(4,4,[1,2,5,6]),imshow(img),title('Original Image')
% subplot(4,4,[3,4,7,8]),imshow(noiseRemoved), title('Image with Wiener filter applied')
% subplot(4,4,[9,10,13,14]),imshow(sharpenedImg), title('Sharpened Image')
% subplot(4,4,[11,12,15,16]),imshow(Iblur), title('Gaussian Filter applied')
%figure,imhist(Iblur)

%% LOCAL THRESHOLDING:
% Adaptive image threshold using local first-order statistics(gaussian weighted mean in pixel neighbourood)

tresh=adaptthresh(Iblur,1,'NeighborhoodSize',41,...
    'ForegroundPolarity','bright','Statistic', 'gaussian');
mask=imbinarize(Iblur,tresh);
mask=~mask;


%% Opening & Closing morphological operation to eliminate isolated white dots:
se=strel('disk',2);
mask= imopen(mask,se);
mask= imclose(mask,se);
%figure, imshow(maschera), title('Maschera dopo Opening')

%% "imfill" to eliminate isolated white dots
filledMask = imfill(mask, 'holes');
%figure, imshow(binaryImage), title('Maschera dopo imfill')

%% Mask coloring and overlay on the original image

visualizeImages(img,filledMask,ground,'LOCAL ADAPTIVE THRESHOLD');

toc
end