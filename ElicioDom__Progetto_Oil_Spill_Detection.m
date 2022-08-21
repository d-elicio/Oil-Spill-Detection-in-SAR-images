close all
clear all
clc

%To count the program's execution time: (tic/toc)
tic


choice=99;
fileidx=1;

%Continue running program until user input is "2"
while choice~=2 

%Set the path to load images and labels
extension_img='*.jpg';
extension_labels='*.png';

imagesDir = 'C:\Users\Oil Spill Detection Dataset\train\images';
landImagesDir='C:\Users\Oil Spill Detection Dataset\train\images_with_land';
labelsDir = 'C:\Users\Oil Spill Detection Dataset\train\labels';
landLabelsImagesDir='C:\Users\Oil Spill Detection Dataset\train\labels_with_land';

imagesDircontent=dir(fullfile(imagesDir,extension_img));
landImagesDircontent=dir(fullfile(landImagesDir,extension_img));
labelsDircontent=dir(fullfile(labelsDir,extension_labels));
landLabelsImagesDircontent=dir(fullfile(landLabelsImagesDir,extension_labels));

%Check that the path is correct
assert(numel(imagesDircontent) > 0, 'No file was found');
assert(numel(labelsDircontent) > 0, 'No file was found');
assert(numel(landImagesDircontent) > 0, 'No file was found');
assert(numel(landLabelsImagesDircontent) > 0, 'No file was found');

%preallocation of the structures:
my_img = struct('img', cell(size(imagesDircontent)));  
my_landImg = struct('img', cell(size(landImagesDircontent)));
my_label = struct('img', cell(size(labelsDircontent)));
my_landLabel = struct('img', cell(size(landLabelsImagesDircontent)));


%% Change "fileidx" value to change the image to use
%Put a flag to know if you're going to use ONLY SEA images or LAND & SEA
%images (ONLY SEA--> flag=true(1)) :
fprintf("\n------------------------------------------------------------------------------------------------")
fprintf("\nThere are 2 types of image you can analyze: \n0- LAND + SEA images\n1- ONLY SEA images\n2- EXIT the program\n \n");
choice=input("Make your choice!  ---> ");
if choice==0
    close all,tic
    flag=0;
    fprintf("\nThere are 219 images of this type, please enter a number to analyze the image you want: \n")
    choice2=input("Make your choice!  ---> ");
    
    if choice2<1 || choice2>=220 
        fprintf("\nWRONG NUMBER!\nThere are 219 images of this type, please enter a new number: \n")
        choice2=input("Make your choice!  ---> ");
    else 
        fileidx=choice2;
    end
elseif choice==1
    close all,tic
    flag=1;
    fprintf("\nThere are 783 images of this type, please enter a number to analyze the image you want: \n")
    choice2=input("Make your choice!  ---> ");
    
    if choice2<1 || choice2>=784 
        fprintf("\nWRONG NUMBER!\nThere are 783 images of this type, please enter a new number: \n")
        choice2=input("Make your choice!  ---> ");
    else 
        fileidx=choice2;
    end
elseif choice==2 
    close all
    fprintf("\nThanks for using this segmentation program!\n")
    return
else
    close all
    fprintf("\n------------------------------------------------------------------------------------------------")
    fprintf("\nINPUT ERROR!\nYou can choose only ""0"" ""1""  ""2"" values, please run the program again.\n");
    return
end


%If flag==true you're considering ONLY SEA images, otherwise LAND+SEA images
if flag==true
    %Only sea with oil spills images 
    my_img(fileidx).img=imread(fullfile(imagesDir,imagesDircontent(fileidx).name));
    my_label(fileidx).img=imread(fullfile(labelsDir,labelsDircontent(fileidx).name));
    I=im2double(my_img(fileidx).img);
    label=my_label(fileidx).img;
else
    %Land & oil spills images
    my_LandImg(fileidx).img=imread(fullfile(landImagesDir,landImagesDircontent(fileidx).name));
    my_LandLabel(fileidx).img=imread(fullfile(landLabelsImagesDir,landLabelsImagesDircontent(fileidx).name));
    I=im2double(my_LandImg(fileidx).img);
    label=my_LandLabel(fileidx).img;
end


%Load and show image and label to use
groundTruth1=im2double(label);


%User has chosen land+sea images
if flag==false
    %You have to extract the two labels (cyan and green color (that have 0.7 and 0.35 values of gray intensity)) from the label images in the dataset:
    groundTruth=imbinarize(rgb2gray(groundTruth1),0.7);
    groundTruth2=imbinarize(rgb2gray(groundTruth1),0.35);
    %If you have an image with land, you have to evaluate the complete segmentation (land + oil spill):
    groundTruth=or(groundTruth,groundTruth2);
else
    %Else if user has chosen ONLY SEA images you have to extract only cyan color from the labelled image in the dataset
    groundTruth=imbinarize(rgb2gray(groundTruth1),0.7);
end



figure('WindowState', 'maximized');
subplot(1,4,[1 2]),imshow(I),title('Original Image');
subplot(1,4,[3 4]),imshow(groundTruth1),title('Ground truth');

%RGB to gray conversion
grayImg=rgb2gray(I);

% Gray image histogram:  
%figure,imhist(grayImg),title('Gray Image Histogram')


if choice==1
    
    fprintf("\n\nThere are different segmentation method you can use, please choose a number!\n")
    fprintf("1 - MANUAL THRESHOLDING SEGM.\n")
    fprintf("2 - AUTOMATIC THRESHOLDING SEGM.\n")
    fprintf("3 - LOCAL ADAPTIVE THRESHOLDING SEGM.\n")
    fprintf("4 - SUPERPIXEL + OTSU THRESHOLDING SEGM.\n")
    fprintf("5 - FUZZY LOGIC EDGE DETECTION & SEGM.\n")
    fprintf("6 - K-MEANS CLUSTERING & SEGM.\n")
    
    choice3=input("Make your choice!  ---> ");
    
    
    switch choice3
        case 1         % --------------- MANUAL THRESHOLDING ----------------------- %
            %Default value for thresholds and minimum area of the blobs
            addThreshval=0.06;
            areaToConsider=45;
            medianFilter=3;
            
            [BWmanual,max_value]=manual_thresholding(grayImg,groundTruth1,addThreshval,areaToConsider,medianFilter);
            figure('WindowState', 'maximized');
            segmentation_evaluation(groundTruth,BWmanual);
                        
            %User can manually improve segmentation results by changing some parameters
            fprintf("\nWould you like to improve segmentation results? (Median filter size, Tresh values and blob areas)  [y/n]")
            yesOrNo=input("Press ""y"" or ""n""  --->",'s');
            while strcmpi(yesOrNo,'y')
                close all
                 %User can modify median filter's window size
                fprintf("\nYou can modify the segmentation results by setting a new value for the noise removal filter (median filter)\n If you don't make a choice, default value is 3x3 \n")
                medianFilter=input("-- FILTER VALUE-- \nMake your choice or just press Enter  ---> ");
                if isempty(medianFilter)
                    medianFilter=3;
                else 
                    while medianFilter<3 || medianFilter>243  || rem(medianFilter,2)==0
                        fprintf('The value of the filter should be a number >3 and <243 and it has to be an ODD number. Please insert a valid value\n ')
                        medianFilter=input("-- FILTER VALUE -- \nMake your choice!  ---> ");
                    end
                end
                
                
                %User can modify threshold to recognize oil spill (increase or decrease previous threshold)
                fprintf("\nYou can adjust the segmentation results by increasing or decreasing the thresold value of the mask\n Admitted values are 0<x<1.   If you don't make a choice, DEFAULT VALUE is 0.15\n")
                %Maximum threshold value at the last analysis done:
                fprintf('\n\nMaximum threshold value NOW: %f\n',max_value)
                addThreshval=input("-- THRESHOLD VALUE -- \nMake your choice or just press Enter  ---> ");
                if isempty(addThreshval)
                    addThreshval=0;
                end
                
                %User canmodify the minimum area to recognize an oil spill
                fprintf("\nYou can also adjust the AREA value of the blobs to recognize it as oil spill.    (DEFAULT VALUE: 45px)\n")
                areaToConsider=input("-- AREA VALUE -- \nMake your choice or just press Enter  ---> ");
                if isempty(areaToConsider)
                    areaToConsider=45;
                else 
                    while areaToConsider<=0 || areaToConsider>422500  
                        fprintf('The value of the area should be a number >0 and <422500m^2 (650*650px). Please insert a valid value\n ')
                        areaToConsider=input("-- AREA TO EXPLORE -- \nMake your choice!  ---> ");
                    end
                end
                [BWmanual,max_value]=manual_thresholding(grayImg,groundTruth1,max_value+addThreshval,areaToConsider,medianFilter);
                figure('WindowState', 'maximized');
                segmentation_evaluation(groundTruth,BWmanual);
               
                fprintf("\nWould you like to improve segmentation results? [y/n]")
                yesOrNo=input("Press ""y"" or ""n""  --->",'s');
                
           end
            
           
        case 2     % --------------- AUTOMATIC THRESHOLDING ----------------------- %
            %default value for area of the blobs
            areaToExplore=45;
            medFilter=3;
            
            [automatic_thresh,BWautomatic]=automatic_threshold(grayImg,groundTruth1,areaToExplore,medFilter);
            figure('WindowState', 'maximized');
            segmentation_evaluation(groundTruth,BWautomatic);
            
            %User can manually improve segmentation results by changing some parameters
            fprintf("\nWould you like to improve segmentation results? (Median filter size / Blob area values)  [y/n]")
            yesOrNo=input("Press ""y"" or ""n""  --->",'s');
            while strcmpi(yesOrNo,'y')
                close all
                 %User can modify median filter's window size
                fprintf("\nYou can modify the segmentation results by setting a new value for the noise removal filter (median filter)\n If you don't make a choice, default value is 3x3 \n")
                medFilter=input("-- FILTER VALUE-- \nMake your choice or just press Enter  ---> ");
                if isempty(medFilter)
                    medFilter=3;
                else 
                    while medFilter<3 || medFilter>243  || rem(medFilter,2)==0
                        fprintf('The value of the filter should be a number >3 and <243 and it has to be an ODD number. Please insert a valid value\n ')
                        medFilter=input("-- FILTER VALUE -- \nMake your choice!  ---> ");
                    end
                end
                
                %User can set the minimum area to recognize an oil spill
                fprintf("\nYou can filter the segmentation results by setting the value of the vastness of the area to be considered\n If you don't make a choice, default area is 45px(~450 m^2) around the main oil spill found \n")
                areaToExplore=input("-- AREA TO CONSIDER -- \nMake your choice or just press Enter  ---> ");
                if isempty(areaToExplore)
                    areaToExplore=450;
                else 
                    while areaToExplore<=0 || areaToExplore>422500  
                        fprintf('The value of the area should be a number >0 and <422500m^2 (650*650px). Please insert a valid value\n ')
                        areaToExplore=input("-- AREA TO EXPLORE -- \nMake your choice!  ---> ");
                    end
                end
                     
            [automatic_thresh,BWautomatic]=automatic_threshold(grayImg,groundTruth1,areaToExplore,medFilter);
            figure('WindowState', 'maximized');
            segmentation_evaluation(groundTruth,BWautomatic);
            
            fprintf("\nWould you like to improve segmentation results? [y/n]")
            yesOrNo=input("Press ""y"" or ""n""  --->",'s');
            
            end
            
            
        case 3        % --------------- LOCAL ADAPTIVE THRESHOLDING ----------------------- %
            %defaut filter values
            noiseFilter=5;
            SharpThresh=0.5;
            GaussianFilter=5;
            [BWlocal]=local_threshold(grayImg,groundTruth1,noiseFilter,SharpThresh,GaussianFilter);
            figure('WindowState', 'maximized');
            segmentation_evaluation(groundTruth,BWlocal);
           
            
            %User can manually improve segmentation results by changing some parameters
            fprintf("\nWould you like to improve segmentation results? (Noise filter width)  [y/n]")
            yesOrNo=input("Press ""y"" or ""n""  --->",'s');
            while strcmpi(yesOrNo,'y')
                close all
                %User can modify Wiener filter's window size
                fprintf("\nYou can modify the segmentation results by setting a new value for the noise removal filter (Wiener filter)\n If you don't make a choice, default value is 5x5 \n")
                noiseFilter=input("-- FILTER VALUE-- \nMake your choice or just press Enter  ---> ");
                if isempty(noiseFilter)
                    noiseFilter=5;
                else 
                    while noiseFilter<3 || noiseFilter>243  || rem(noiseFilter,2)==0
                        fprintf('The value of the filter should be a number >3 and <243 and it has to be an ODD number. Please insert a valid value\n ')
                        noiseFilter=input("-- FILTER VALUE -- \nMake your choice!  ---> ");
                    end
                end
                %User can modify threshold of unsharping mask
                fprintf("\nYou can modify the segmentation results by setting a new value for the threshold of UNSHARPING MASK\n If you don't make a choice, DEFAULT VALUE is 0.5. Values can be 0<x<1 \n")
                SharpThresh=input("-- UNSHARPING MASK THRESHOLD -- \nMake your choice or just press Enter  ---> ");
                if isempty(SharpThresh)
                    SharpThresh=0.5;
                else 
                    while SharpThresh<0 || SharpThresh>1
                        fprintf('The value of the threshold should be a number >0 and <1. Please insert a valid value\n ')
                        SharpThresh=input("-- UNSHARPING MASK THRESHOLD -- \nMake your choice!  ---> ");
                    end
                end
                %User can modify Gaussian filter's window size
                fprintf("\nYou can modify the segmentation results by setting a new value for the GAUSSIAN FILTER\n If you don't make a choice, DEFAULT VALUE is 5*5 \n")
                GaussianFilter=input("-- GAUSSIAN FILTER -- \nMake your choice or just press Enter  ---> ");
                if isempty(GaussianFilter)
                    GaussianFilter=5;
                else 
                    while GaussianFilter<3 || GaussianFilter>243 || rem(GaussianFilter,2)==0
                        fprintf('The value of the filter should be a number >3 and <243(MAX value) and it needs to be an ODD number. Please insert a valid value\n ')
                        GaussianFilter=input("-- GAUSSIAN FILTER -- \nMake your choice!  ---> ");
                    end
                end
           
           [BWlocal]=local_threshold(grayImg,groundTruth1,noiseFilter,SharpThresh,GaussianFilter);
           figure('WindowState', 'maximized');
           segmentation_evaluation(groundTruth,BWlocal);
                       
           fprintf("\nWould you like to improve segmentation results? [y/n]")
           yesOrNo=input("Press ""y"" or ""n""  --->",'s');
           
           end
           
           
        case 4        % --------------- SUPERPIXEL APPROACH ----------------------- %
            %Default values of superpixels & minimun distance from principal blob
            spNum=25000;
            minDist=450;
            
            [BWSuperpixel]=superpixel(grayImg,groundTruth1,spNum,minDist);
            figure('WindowState', 'maximized');
            segmentation_evaluation(groundTruth,BWSuperpixel);
            
            %User can manually improve segmentation results by changing some parameters
            fprintf("\nWould you like to improve segmentation results? (Number of superpixels/distance value from main blob)  [y/n]")
            yesOrNo=input("Press ""y"" or ""n""  --->",'s');
            while strcmpi(yesOrNo,'y')
                close all
                %User can modify the number of superpixel to segment the image
                fprintf("\nYou can modify the segmentation results by setting a new value for the number of superpixels or rhe distance value from the principal blob\n If you don't make a choice, default values are [25.000 superpx] & [450px] \n")
                spNum=input("-- SUPERPIXELS NUMBER -- \nMake your choice or just press Enter  ---> ");
                if isempty(spNum)
                    spNum=25000;
                else 
                    while spNum<500 || spNum>812500 
                        fprintf('The number of superpixels should be a number >=500 and <812500 (MAX value). Please insert a valid value\n ')
                        spNum=input("-- SUPERPIXEL NUMBER -- \nMake your choice!  ---> ");
                    end
                end
                %User can change the distance value from the principal blob
                fprintf("\nYou can modify the segmentation results by setting the value of the distance from the main oil spill found  to show other spills\n If you don't make a choice, default values is 450m \n")
                minDist=input("-- DISTANCE VALUE -- \nMake your choice or just press Enter  ---> ");
                if isempty(minDist)
                    minDist=450;
                else 
                    while minDist<=0 ||   minDist>650
                        fprintf('The distance value should be >0 and <650(max value). Please insert a valid value\n ')
                        minDist=input("-- DISTANCE VALUE-- \nMake your choice!  ---> ");
                    end
                end
            
            [BWSuperpixel]=superpixel(grayImg,groundTruth1,spNum,minDist);
            figure('WindowState', 'maximized');
            segmentation_evaluation(groundTruth,BWSuperpixel);
            
            fprintf("\nWould you like to improve segmentation results? [y/n]")
            yesOrNo=input("Press ""y"" or ""n""  --->",'s');
            
            end
            
            
            
        case 5    % --------------- FUZZY LOGIC APPROACH ----------------------- %
            %Default value of Lee filter's window size
            filterSize=5;
            
            [BWfuzzyEdge]=fuzzy_edgeDetect(grayImg,groundTruth1,filterSize);
            figure('WindowState', 'maximized');
            segmentation_evaluation(groundTruth,BWfuzzyEdge);
           
            %User can manually improve segmentation results by changing some parameters
            fprintf("\nWould you like to improve segmentation results? (Lee Filter size)  [y/n]")
            yesOrNo=input("Press ""y"" or ""n""  --->",'s');
            
            while strcmpi(yesOrNo,'y')
                close all
                %User can cheange the Lee Filter's window size 
                fprintf("\nYou can modify the segmentation results by setting a new value for the Lee filter size\n If you don't make a choice, DEFAULT VALUE is 5x5 \n")
                filterSize=input("-- LEE FILTER SIZE -- \nMake your choice or just press Enter  ---> ");
                if isempty(filterSize)
                    filterSize=5;
                else 
                    while filterSize<3 || filterSize>243 || rem(filterSize,2)==0
                        fprintf('The size of the filter should be a number >=3 and <243 (MAX value) and must be adn ODD number. Please insert a valid value\n ')
                        filterSize=input("-- LEE FILTER SIZE -- \nMake your choice!  ---> ");
                    end
                end
                
                [BWfuzzyEdge]=fuzzy_edgeDetect(grayImg,groundTruth1,filterSize);
                figure('WindowState', 'maximized');
                segmentation_evaluation(groundTruth,BWfuzzyEdge);
                                
                fprintf("\nWould you like to improve segmentation results? [y/n]")
                yesOrNo=input("Press ""y"" or ""n""  --->",'s');
                
            end
            
        case 6    % --------------- K-MEANS APPROACH ----------------------- %
            %Default value of number of clusters and no. of blobs to extract
            filterSize=2*ceil(2*0.5)+1.;  % =3      Default MATLAB value. 0.5 is SIGMA =std dev of Gaussian distribution
            numClusters=5;
            numBlobs=1;
            
            [kMeansSegm,BW_kMeans]=kmeansSegment(grayImg,groundTruth1,filterSize,numClusters,numBlobs);
            figure('WindowState', 'maximized');
            segmentation_evaluation(groundTruth,BW_kMeans);
            
            %User can manually improve segmentation results by changing some parameters
            fprintf("\nWould you like to improve segmentation results? (Gaussian filter size / Number of clusters / Number of blobs)  [y/n]")
            yesOrNo=input("Press ""y"" or ""n""  --->",'s');
             while strcmpi(yesOrNo,'y')
                close all
                %User can change the Gaussian filter size
                fprintf("\nYou can choose the Gaussian filter size\n If you don't make a choice, default number is 3\n")
                filterSize=input("-- GAUSSIAN FILTER SIZE -- \nMake your choice or just press Enter  ---> ");
                if isempty(filterSize)
                    filterSize=2*ceil(2*0.5)+1.;
                else 
                    while filterSize<1 || rem(filterSize,2)==0
                        fprintf('The number of clusters should be a value >1 and an ODD number. Please insert a valid value\n ')
                        filterSize=input("-- NUMBER OF CLUSTERS -- \nMake your choice!  ---> ");
                    end
                end
                %User can change the number of clusters
                fprintf("\nYou can choose the number of clusters to divide the image\n If you don't make a choice, default number is 5\n")
                numClusters=input("-- NUMBER OF CLUSTERS -- \nMake your choice or just press Enter  ---> ");
                if isempty(numClusters)
                    numClusters=5;
                else 
                    while numClusters<1
                        fprintf('The number of clusters should be a value >1. Please insert a valid value\n ')
                        numClusters=input("-- NUMBER OF CLUSTERS -- \nMake your choice!  ---> ");
                    end
                end
                %User can change the number of blobs to extract
                fprintf("\nYou can change the number of oil spills to extract. Default number is 1\n")
                numBlobs=input("-- NUMBER OF OIL SPILLS TO EXTRACT -- \nMake your choice or just press Enter  --->  ");
                if isempty(numBlobs)
                    numBlobs=1;
                else
                    while numBlobs<1 || numBlobs>numClusters
                    fprintf('The number of oil spills to extract should be a value >1 and < of the total number of clusters. Please insert a valid value \n')
                    numBlobs=input("-- NUMBER OF OIL SPILLS TO EXTRACT -- \nMake your choice!  ---> \n");
                    end
                end
            
                [kMeansSegm,BW_kMeans]=kmeansSegment(grayImg,groundTruth1,filterSize,numClusters,numBlobs);
                figure('WindowState', 'maximized');
                segmentation_evaluation(groundTruth,BW_kMeans);
                                 
                fprintf("\nWould you like to improve segmentation results? [y/n]")
                yesOrNo=input("Press ""y"" or ""n""  --->",'s');
                
            end
            
            
        otherwise
            fprintf("\nWRONG VALUE!  Please enter another number.")
            choice3=input("\nMake your choice!  ---> ");
    end

        
    
    
% If user chooses images with SEA & LAND:    
elseif choice==0
    fprintf("\n\nThere are different segmentation method you can use, please choose a number!\n")
    fprintf("1 - AUTOMATIC THRESHOLDING SEGM.\n")
    fprintf("2 - K-MEANS CLUSTERING & SEGM.\n")
    
    choice3=input("Make your choice!  ---> ");

    switch choice3
        case 1    % --------------- AUTOMATIC THRESHOLDING ----------------------- %
            %Default values of minimum area to consider for an oil spill and threshold value to recognize land
            areaToExplore=45;
            landThreshold=0.5;
            medFilt=5;
            
            [oilMask,BWland]=land_mask(grayImg,groundTruth1,areaToExplore,landThreshold,medFilt);
            figure('WindowState', 'maximized')
            segmentation_evaluation(groundTruth,BWland);
           
            %User can manually improve segmentation results by changing some parameters
            fprintf("\nWould you like to improve segmentation results? (Blob area values/Land threshold)  [y/n]")
            yesOrNo=input("\nPress ""y"" or ""n""  --->",'s');
            while strcmpi(yesOrNo,'y')
                close all
                 %User can modify median filter's window size
                fprintf("\nYou can modify the segmentation results by setting a new value for the noise removal filter (median filter)\n If you don't make a choice, default value is 5x5 \n")
                medFilt=input("-- FILTER VALUE-- \nMake your choice or just press Enter  ---> ");
                if isempty(medFilt)
                    medFilt=5;
                else 
                    while medFilt<3 || medFilt>243  || rem(medFilt,2)==0
                        fprintf('The value of the filter should be a number >3 and <243 and it has to be an ODD number. Please insert a valid value\n ')
                        medFilt=input("-- FILTER VALUE -- \nMake your choice!  ---> ");
                    end
                end
                %User can change the area of blobs to consider in the segmentation phase
                fprintf("\nYou can filter the segmentation results by setting the value of the vastness of the area to be considered\n If you don't make a choice, default area is 450px(~450 m^2) around the main oil spill found \n")
                areaToExplore=input("-- BLOB AREA VALUE -- \nMake your choice or just press Enter  ---> ");
                if isempty(areaToExplore)
                    areaToExplore=45;
                else 
                    while areaToExplore<=0 || areaToExplore>422500  
                        fprintf('The value of the area should be a number >0 and <422500 m^2 (650*650px). Please insert a valid value\n ')
                        areaToExplore=input("-- AREA TO EXPLORE -- \nMake your choice!  ---> ");
                    end
                end
                %User can change threshold value to recognize land
                fprintf("\nYou can filter the LAND segmentation results by setting the value of the THRESHOLD to identify the land\n If you don't make a choice, DEFAULT VALUE is 0.5 \n")
                landThreshold=input("-- LAND THRESHOLD VALUE -- \nMake your choice or just press Enter  ---> ");
                if isempty(landThreshold)
                    landThreshold=0.5;
                else 
                    while landThreshold<0 || landThreshold>1  
                        fprintf('The value of the threshold should be a number >0 and <1. Please insert a valid value\n ')
                        areaToExplore=input("-- LAND THRESHOLD VALUE -- \nMake your choice!  ---> ");
                    end
                end
            
                [landMask,BWland]=land_mask(grayImg,groundTruth1,areaToExplore,landThreshold,medFilt);
                figure('WindowState', 'maximized')
                segmentation_evaluation(groundTruth,BWland);
                          
                fprintf("\nWould you like to improve segmentation results? (Blob area values)  [y/n]")
                yesOrNo=input("Press ""y"" or ""n""  --->",'s');
                
            end
            
            
            
        
        case 2    % --------------- K-MEANS APPROACH ----------------------- %
            %Default value of number of clusters and no. of blobs to extract
            gaussFilt=3;
            numClusters=5;
            numBlobs=1;
            
            [BW_kMeans]=kmeansSegment_for_land(grayImg,groundTruth1,gaussFilt,numClusters,numBlobs);
            figure('WindowState', 'maximized')
            segmentation_evaluation(groundTruth,BW_kMeans);
            
            %User can manually improve segmentation results by changing some parameters
            fprintf("\nWould you like to improve segmentation results? (Guassian filter size/Number of clusters/Number of blobs to extract)  [y/n]")
            yesOrNo=input("Press ""y"" or ""n""  --->",'s');
            
            while strcmpi(yesOrNo,'y')
                close all
                %User can change the Gaussian filter size
                fprintf("\nYou can choose the Gaussian filter size\n If you don't make a choice, default number is 3\n")
                gaussFilt=input("-- GAUSSIAN FILTER SIZE -- \nMake your choice or just press Enter  ---> ");
                if isempty(gaussFilt)
                    gaussFilt=2*ceil(2*0.5)+1.;  % =3
                else 
                    while gaussFilt<1 || rem(gaussFilt,2)==0
                        fprintf('The number of clusters should be a value >1 and an ODD number. Please insert a valid value\n ')
                        gaussFilt=input("-- NUMBER OF CLUSTERS -- \nMake your choice!  ---> ");
                    end
                end
                %User can change the number of clusters
                fprintf("\nYou can choose the number of clusters to divide the image\n If you don't make a choice, default number is 5\n")
                numClusters=input("-- NUMBER OF CLUSTERS -- \nMake your choice or just press Enter  ---> ");
                if isempty(numClusters)
                    numClusters=5;
                else 
                    while numClusters==0  || numClusters==1
                        fprintf('The number of clusters should be a value >1 and < of the total number of clusters. Please insert a valid value\n ')
                        numClusters=input("-- NUMBER OF CLUSTERS -- \nMake your choice!  ---> ");
                    end
                end
                %User can change number of blobs to extract
                fprintf("\nYou can change the number of oil spills to extract. Default number is 1\n")
                numBlobs=input("-- NUMBER OF OIL SPILLS TO EXTRACT -- \nMake your choice or just press Enter  --->  ");
                if isempty(numBlobs)
                    numBlobs=1;
                else
                    while numBlobs<1 || numBlobs>numClusters
                    fprintf('The number of oil spills to extract should be a value >1. Please insert a valid value \n')
                    numBlobs=input("-- NUMBER OF OIL SPILLS TO EXTRACT -- \nMake your choice!  ---> \n");
                    end
                end
                
                [BW_kMeans]=kmeansSegment_for_land(grayImg,groundTruth1,gaussFilt,numClusters,numBlobs);
                figure('WindowState', 'maximized')
                segmentation_evaluation(groundTruth,BW_kMeans);
                            
                fprintf("\nWould you like to improve segmentation results? (Blob area values)  [y/n]")
                yesOrNo=input("Press ""y"" or ""n""  --->",'s');
            end
            
        otherwise
            fprintf("\nWRONG VALUE!  Please enter another number.")
            choice3=input("\nMake your choice!  ---> ");
    end

end







%%                      -----------  Code finished  -----------

toc
end

