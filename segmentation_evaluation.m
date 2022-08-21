function segmentation_evaluation(groundTruth,segmentationMask)

tic

%% 1st metric: JACCARD SIMILARITY
similarityJaccard = jaccard(groundTruth,segmentationMask);
subplot(4,4,[1,2,5,6])
imshowpair(groundTruth,segmentationMask)
title(['Jaccard Index = ' num2str(similarityJaccard)])

%% 2nd metric: DICE SIMILARITY
similarityDice = dice(groundTruth,segmentationMask);
subplot(4,4,[3,4,7,8])
imshowpair(groundTruth,segmentationMask)
title(['Dice Index = ' num2str(similarityDice)])

%% 3rd metric: BF SCORE
similarityBFScore = bfscore(groundTruth,segmentationMask);
subplot(4,4,[10,11,14,15])
imshowpair(groundTruth,segmentationMask)
title(['BF Score = ' num2str(similarityBFScore)])

toc
end