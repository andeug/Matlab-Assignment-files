%Suppose you have an image of a cluttered scene, clutteredDesk.jpg, and you want to detect a particular
%object of which you have a separate image, stapleRemover.jpg. You can start by reading the reference
%image containing the object of interest into MATLAB®.
catImage = imread('cats.jpg');
figure;
imshow(catImage);
title('Image of a Cat');
%Next, you can read the target image containing a cluttered scene.
sceneImage = imread('cats-and-dogs-03.jpg');
figure;
imshow(sceneImage);
title('Image of a cat and a dog ');
%You can detect feature points in both images.
catPoints = detectSURFFeatures(rgb2gray(catImage));
scenePoints = detectSURFFeatures(rgb2gray(sceneImage));
%Then, you can visualize the strongest feature points found in the reference image.
figure;
imshow(catImage);
title('100 Strongest Feature Points from Box Image');
hold on;
plot(selectStrongest(catPoints, 100));
%For comparison, visualizing the strongest feature points found in the target image.
figure;
imshow(sceneImage);
title('300 Strongest Feature Points from Scene Image');
hold on;
plot(selectStrongest(scenePoints, 300));

%extracting feature descriptors at the interest points in both images.
[catFeatures, catPoints] = extractFeatures(rgb2gray(catImage), catPoints);
[sceneFeatures, scenePoints] = extractFeatures(rgb2gray(sceneImage), scenePoints);

%matching the features using their descriptors.
catPairs = matchFeatures(catFeatures, sceneFeatures);

%Displaying putatively matched features.
matchedCatPoints = catPoints(catPairs(:, 1), :);
matchedScenePoints = scenePoints(catPairs(:, 2), :);
figure;
showMatchedFeatures(catImage, sceneImage, matchedCatPoints, ...
matchedScenePoints, 'montage');
title('Putatively Matched Points (Including Outliers)');
%The estimateGeometricTransform function calculates the transformation relating the matched points,
%while eliminating outliers. This transformation allows you to localize the object in the scene.
%[tform, inlierBoxPoints, inlierScenePoints] = ...
%estimateGeometricTransform(matchedBoxPoints, matchedScenePoints,...
%'affine');

[tform, inlierBoxPoints, inlierScenePoints, status] = estimateGeometricTransform(matchedCatPoints, matchedScenePoints, ...
     'projective');
%displaying the matching point pairs with the outliers removed.
figure;
showMatchedFeatures(catImage, sceneImage, inlierBoxPoints, ...
inlierScenePoints, 'montage');

title('Matched Points (Inliers Only)');
%getting the bounding polygon of the reference image.
catPolygon = [1, 1;... % top-left
size(catImage, 2), 1;... % top-right
size(catImage, 2), size(catImage, 1);... % bottom-right
1, size(catImage, 1);... % bottom-left
1, 1]; % top-left again to close the polygon
%To indicate the location of the object in the scene,  transform the polygon into the coordinate
%system of the target image.
newCatPolygon = transformPointsForward(tform, catPolygon);
%displaying the detected object.
figure;
imshow(sceneImage);
hold on;
line(newCatPolygon(:, 1), newCatPolygon(:, 2), 'Color', 'y');
title('Detected Cat');

%detecting a dog using same procedure as for cat

dogImage = imread('dog.jpg');
figure;
imshow(dogImage);
title('Image of a Dog');
dogPoints = detectSURFFeatures(rgb2gray(dogImage));
figure;
imshow(dogImage);
hold on;
plot(selectStrongest(dogPoints, 100));
title('100 Strongest Feature Points from Dog Image');
[dogFeatures, dogPoints] = extractFeatures(rgb2gray(dogImage), ...
dogPoints);
dogPairs = matchFeatures(dogFeatures, sceneFeatures, ...
'MaxRatio', 0.9);
matchedDogPoints = dogPoints(dogPairs(:, 1), :);
matchedScenePoints = scenePoints(dogPairs(:, 2), :);
figure;
showMatchedFeatures(dogImage, sceneImage, matchedDogPoints, ...
matchedScenePoints, 'montage');
title('Putatively Matched Points (Including Outliers)');
[tform, inlierDogPoints, inlierScenePoints] = ...
estimateGeometricTransform(matchedDogPoints, ...
matchedScenePoints, 'affine');
figure;
showMatchedFeatures(dogImage, sceneImage, inlierDogPoints, ...
inlierScenePoints, 'montage');
title('Matched Points (Inliers Only)');
dogPolygon = [1, 1;... % top-left
size(dogImage, 2), 1;... % top-right
size(dogImage, 2), size(dogImage, 1);... % bottom-right
1, size(dogImage, 1);... % bottom-left
1,1]; % top-left again to close the polygon
newPolygon = transformPointsForward(tform, dogPolygon);
figure;
imshow(sceneImage);
hold on;
line(newCatPolygon(:, 1), newCatPolygon(:, 2), 'Color', 'y');
line(newElephantPolygon(:, 1), newElephantPolygon(:, 2), 'Color', 'g');
title('Detected Dog and Cat');