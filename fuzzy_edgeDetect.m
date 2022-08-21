function [BW]=fuzzy_edgeDetect(img,ground,filterSize)

tic
%% IMAGE ENHANCEMENT
%CITAZ: Grzegorz Mianowski (2022). Lee filter (https://www.mathworks.com/matlabcentral/fileexchange/28046-lee-filter), MATLAB Central File Exchange. Retrieved March 23, 2022. 
%Use of Lee Filter to eliminate speckle from the original image
leeFiltered=lee_filter(img,filterSize);    %Default window size used: 5
%leeFiltered=rgb2gray(leeFiltered);
% figure('WindowState', 'maximized');
% subplot(1,2,1),imshow(img), title('Original image')
% subplot(1,2,2),imshow(leeFiltered), title('Lee-filtered image')

%Contrast enhancement operation:
eqImg=histeq(leeFiltered);

%% This part has been done following the Mathwork helpcenter tutorial: https://it.mathworks.com/help/fuzzy/fuzzy-logic-image-processing.html

%Calculate the image gradient along the x-axis and y-axis, because The fuzzy logic edge-detection algorithm
%relies on the image gradient to locate breaks in uniform regions. 

%To do this, Sobel operator has been used:
Gx = [1 0 -1; 2 0 -2; 1 0 -1];
Gy = Gx';
Ix = conv2(eqImg,Gx,'same'); %convolution of two 2D matrices
Iy = conv2(eqImg,Gy,'same');
% figure,imshow(Ix),colormap('gray'),title('Ix')
% figure,imshow(Iy),colormap('gray'),title('Iy')

%% Definition of a FIS(Fuzzy Inference System) for Edge Detection

edgeFIS = mamfis('Name','edgeDetection');
%Specification of image gradient, Ix and Iy, as the input for edgeFIS:
edgeFIS = addInput(edgeFIS,[-4 4],'Name','Ix');
edgeFIS = addInput(edgeFIS,[-4 4],'Name','Iy');
%Specification of a zero-mean Gaussian membership function for each input
sx = 0.1;  %Value of the std deviation for X
sy = 0.1;  %Value of the std deviation for Y
edgeFIS = addMF(edgeFIS,'Ix','gaussmf',[sx 0],'Name','zero');
edgeFIS = addMF(edgeFIS,'Iy','gaussmf',[sy 0],'Name','zero');

%Specification of the intensity of the edge-detected image as an output of edgeFIS
edgeFIS = addOutput(edgeFIS,[0 1],'Name','Iout');
%Triangular membership function parameters for Iout
wa = 0.4;           %start of the triangle
wb = 1;             %peak of the triangle
wc = 1;             %end of the triangle
ba = 0;
bb = 0;
bc = 0.45;
edgeFIS = addMF(edgeFIS,'Iout','trimf',[wa wb wc],'Name','white');
edgeFIS = addMF(edgeFIS,'Iout','trimf',[ba bb bc],'Name','black');
%% Plotting of the Membership Function for the input and output of edgeFIS
figure
subplot(2,2,1),plotmf(edgeFIS,'input',1),title('Ix')
subplot(2,2,2),plotmf(edgeFIS,'input',2),title('Iy')
subplot(2,2,[3 4]),plotmf(edgeFIS,'output',1),title('Iout')

%% FIS(Fuzzy Inference System) rules definition:
r1 = "If Ix is zero and Iy is zero then Iout is white";
r2 = "If Ix is not zero or Iy is not zero then Iout is black";
edgeFIS = addRule(edgeFIS,[r1 r2]);
edgeFIS.Rules;

%% FIS evaluation phase:
Ieval = zeros(size(eqImg));
for ii = 1:size(eqImg,1)
                  %evalfis function=evaluate a FIS  
    Ieval(ii,:) = evalfis(edgeFIS,[(Ix(ii,:));(Iy(ii,:))]');
end

%% Resulting plot

%figure,imshow(img),colormap('gray'),title('Original Grayscale Image')
figure('WindowState', 'maximized');
subplot(1,4,[1 2]),imshow(Ieval),colormap('gray'),title('Edge Detection Using Fuzzy Logic')
impixelinfo()

%% Binary Mask creation from the resulting edges

T=0.8;
mask=imbinarize(Ieval,T);
subplot(1,4,[3 4]), imshow(mask),title('Initial mask (after edge detection phase)')
%% Opening & Closing morphological operations
se=strel('disk',1);
se2=strel('square',2);

mask=imopen(mask,se);
mask=imclose(mask,se);
mask=imdilate(mask,se2);

%% Mask coloring and overlay on the original image
visualizeImages(img,mask,ground,'FUZZY EDGE DETECT. SEGMENTATION');


%Used for the segmentation_evaluation function:
BW=mask;

toc
end