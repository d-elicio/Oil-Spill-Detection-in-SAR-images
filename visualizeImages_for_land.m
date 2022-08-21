function visualizeImages_for_land(img,mask,ground,oilThresh,stringMethod)

background=zeros(size(img),'double');
maschera=imoverlay(background,mask,'green');


%Visualization of GROUND TRUTH and our SEGMENTATION FINAL MASK:
figure('WindowState', 'maximized');
subplot(1,4,[1 2]), imshow(ground),title('Ground Truth');
subplot(1,4,[3 4]), imshow(imfuse(maschera,oilThresh,'ColorChannels',[0 1 2])) 
title(sprintf('%s : MASK',stringMethod));


%Visualization ORIGINAL IMAGE with the FINAL MASK overlapped
 figure('WindowState', 'maximized');
 imshow(img), title(sprintf('%s: Original image with overlapped mask',stringMethod))
 hold on;
 overlappedMasks=imshow(oilThresh);
 overlappedMasks2=imshow(maschera);
 overlappedMasks.AlphaData=0.35;
 overlappedMasks2.AlphaData=0.35;

end