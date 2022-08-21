function visualizeImages(img,mask,ground,stringMethod)

%Visualization GROUND TRUTH & FINAL MASK
background=zeros(size(img),'double');
maschera=imoverlay(background,mask,'cyan');
figure('WindowState', 'maximized');
subplot(1,4,[1 2]),imshow(ground),title('Ground Truth');
subplot(1,4,[3 4]),imshow(maschera),title(sprintf('%s : MASK',stringMethod));

%Visualization ORIGINAL IMAGE with overlapped the FINAL MASK
figure('WindowState', 'maximized');
imshow(img), title(sprintf('%s: Original image with overlapped mask',stringMethod))
hold on;
overlappedImg=imshow(maschera);
overlappedImg.AlphaData=0.35;


end