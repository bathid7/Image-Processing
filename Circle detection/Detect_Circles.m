function [] = Detect_Circles()
Image= imread('Your Image');
% Edge detection using Sobel
Image = Edge_Detection(Image);
figure(2),imshow(Image),title('Image after thinning');
circle_detection(Image,1,50,3);
end

function [Image] = Edge_Detection(Image)
Image = im2double(rgb2gray(Image)); %Converting the gray image to double
% Sobel Masks w.r.t X and Y axis
MaskX=[-1,0,1;-2,0,2; -1,0,1]; 
MaskY=[-1,-2,-1;0,0,0; 1,2,1];
% Gradients along X and Y axis by convulting Image with respective masks.
GradientX = conv2(Image, MaskX);
GradientY = conv2(Image, MaskY);
GradientMagnitude = sqrt(GradientX.^2 + GradientY.^2); % Magnitude of the gradient
figure(1),imshow(GradientMagnitude),title('Image after edge detection');
ThresValue = graythresh(GradientMagnitude); % Threshold value of the gray image
Image = im2bw(GradientMagnitude, ThresValue); % Applying threshold to the image.
% Image morphology - image thinning (skeletanization) ifinite times.
Image = bwmorph(Image, 'thin', Inf); 
end

function[Image]= circle_detection(Image, minRadius, maxRadius, numCircles)
[c,r]=size(Image); % Size of the image
% Coordinates of the image where intensity is 1
[Y,X]=find(Image == 1);

% Hough matrix of size of image and maxRadius layers is initialized.
HoughMatrix = zeros(c,r,maxRadius - minRadius + 1);
radiusRange = (minRadius:maxRadius).^2;

% Voting 
for n = 1:length(X)
    for rN = minRadius:maxRadius
        colOp = 1:c;
        Temp = (round(X(n) - sqrt(radiusRange(rN) - (Y(n) - colOp).^2)));
        colOp = colOp(imag(Temp)==0 & Temp>0);
        Temp = Temp(imag(Temp)==0 & Temp>0);
        index = sub2ind([c,r],colOp,Temp);
        HoughMatrix(c*r*(rN-1)+index) = HoughMatrix(c*r*(rN-1)+index) + 1;
    end
end
figure,hold on,title('hough transform')
for i = 1:maxRadius
imagesc(HoughMatrix(:,:,i))
colormap gray
hold on
end
hold off;

% Determining the peaks for each layer.
for n = minRadius:maxRadius
peaks(n) = max(max(HoughMatrix(:,:,n)));
end

sortList= unique(peaks); % Sorting the peaks
maxValues = sortList(end-(numCircles^2):end);
maxValues= maxValues([1, numCircles:end]); % Peaks corresponding to given number of traingles.
[~,indices] = ismember(maxValues,peaks);% Radius of the corresponding circles.
% Determing the coordinates of the center correspoding to these peaks.
xcord=[];ycord=[];index=1;
for n=1:length(maxValues)
   [Y,X] = find(HoughMatrix(:,:,indices(n))== maxValues(n)); 
   xcord(index)=X;ycord(index)=Y;
   index = index+1;
end

% Standardizing radius and center.
index=1;radius=[];
for n=1:length(xcord)
    if n~=length(xcord)&&(abs(xcord(n+1)-xcord(n))<=10 || abs(ycord(n+1)-ycord(n))<= 10)
        xcord(n+1)=floor((xcord(n+1)+xcord(n))/2);
        ycord(n+1)=floor((ycord(n+1)+ycord(n))/2);
        indices(n+1) = ceil(indices(n)+indices(n+1))/2;       
    else
        finalX(index)=xcord(n);
        finalY(index)=ycord(n);
        radius(index)=indices(n);
        index=index+1;
    end
end

% Plotting the centers and radius.
figure(4),imshow(imread('xid-9701611_1.jpg')),title('Detected circles with center and radius'); hold on;
for n = 1:numCircles
plot(finalX(n),finalY(n),'X')
text(finalX(n)+5,finalY(n),num2str(indices(n)),'color','green')
hold on
end
end