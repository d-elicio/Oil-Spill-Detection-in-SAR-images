function [oilThresh,BWautomatic] = land_mask(img,ground,areaToExplore,landThreshold,medFilt)

tic
%% IMAGE ENHANCEMENT
%Adaptive filters to remove speckle
noiseRemoved=wiener2(img,[medFilt medFilt]);
%figure, imshow(noiseRemoved), title('Rumore eliminato')

%Unsharping mask
sharpenedImg=imsharpen(noiseRemoved,'Radius',1.5,'Amount',1.5,'Threshold',0.5);
%figure, imshow(sharpenedImg), title('Sharpened Image')

% Gaussian Filtering to reduce gaussian noise
Iblur=imgaussfilt(sharpenedImg,'FilterSize',5);
% figure,imshow(Iblur)
% figure,imhist(Iblur)


%% LAND MASK:
%Fixed threshold (0.5) to recognize land, user can modify it
mask=Iblur>landThreshold;

%% Closing & Opening morphological operations
mask=imclose(mask,[0 1 0;1 1 1;0 1 0]);           %    |0 1 0|
mask=imopen(mask,[0 1 0;1 1 1;0 1 0]);            %  S=|1 1 1|
                                                  %    |0 1 0|

%% Call to oil spill segmentation function to show oil & land segmentation together:
[oilThresh,BWautomatic]=automatic_threshold_for_land(img,ground,areaToExplore,medFilt);

%% Call to function that shows mask and images
visualizeImages_for_land(img,mask,ground,oilThresh,'AUTOMATIC THRESH. OIL + LAND SEGMENTATION');


%Used for the segmentation_evaluation function:
BWautomatic=or(mask,BWautomatic);


toc
end