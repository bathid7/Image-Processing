function [] = Tell_Me_The_Time()
% Given analog clock.
Image = imread('clock1.jpg');
%Edge detection using canny operator.
edgedetected = edge(Image(:,:,1), 'canny');
Centre = floor(size(edgedetected)/2);
Radius = Centre(2) - 20;
% Hough transform of the given image
lines = Hough_Transformation(edgedetected);
% Detecting the end points of Hours and Minutes hand
[Hpoint, Mpoint] = Hands_Detection(lines, Centre);
% Detecting the angle made by the hours hand.
HoursAngle = Angle_Detection(Hpoint, Centre, Radius);
Hours = floor(HoursAngle/30);
if(Hours == 0)
    Hours = Hours+12;
end
% Detecting the angle made by the minutes hand.
MinutesAngle = Angle_Detection(Mpoint, Centre, Radius);
Minutes = floor(MinutesAngle/6);
% plotting the result
figure,imshow(Image),hold on
Text = text(Centre(1)+25,Centre(2)+25,horzcat('Time  ',num2str(Hours),':',num2str(Minutes)));
set(Text,'color','Blue','FontWeight','bold','FontSize',12);
end

% Hough_Transformation : This function applies hough transform on the given 
% image and return the hough lines corresponding to the Peaks.
function [lines] = Hough_Transformation(Image)
% Hough transform of the given image.
[Ho,theta,rho] = hough(Image);
% Hough peaks
Peaks = houghpeaks(Ho,5,'threshold',ceil(0.3*max(Ho(:))));
% Hough lines
lines = houghlines(Image,theta,rho,Peaks,'FillGap',2.9);
end

% Hands_Detection : Detect the hands of the image by determining the two
% largest lines from the detected hough lines by
% calculating the euclidean distance between the end points.
function[Hpoint, Mpoint] = Hands_Detection(lines, Centre)
lengths = [];
% The length of the each detected line.
for i = 1:length(lines)
   lengths(end+1) = ceil(norm(lines(i).point1-lines(i).point2));
end
% sorting lines based on their length.
sortlengths = unique(lengths);
% Determining the end points and angle of two largest line segments.
Hpoint = [];Mpoint = [];
% Case 1 : If two hands are not overlapping 
if(length(sortlengths)>1 && sortlengths(end-1) >= sortlengths(end)/2)
    for k= 1:length(lines)
        temp = ceil(norm(lines(k).point1-lines(k).point2));
        if(temp == sortlengths(end))
            Mpoint = EndPoint_Detection(Centre, lines(k).point1, lines(k).point2);              
        end               
        if(temp == sortlengths(end-1))
            Hpoint = EndPoint_Detection(Centre, lines(k).point1, lines(k).point2); 
            break;
        end 
    end
% Case 2 : If two hands are overlapping 
else
  for k= 1:length(lines)
      temp = ceil(norm(lines(k).point1-lines(k).point2));
      if(temp == sortlengths(end))
           Mpoint = EndPoint_Detection(Centre, lines(k).point1, lines(k).point2);
           Hpoint = Mpoint;
      end               
  end
end
end

% EndPoint_Determination : This function detects the end point 
% of the hand by taking the point which is farther from the centre 
function[Point] = EndPoint_Detection(Centre, Point1, Point2)
% Distance of two points from the centre
LengthOfPone =  ceil(norm(Centre-Point1));
LengthOfPtwo =  ceil(norm(Centre-Point2));
% point which is farther from the Centre
if(LengthOfPone > LengthOfPtwo)
    Point = Point1;
else
    Point = Point2;
end
end

% Angle_Detection : Detects the angle made by the point and reference,
% i.e., 12' with respect to Centre.
function[Angle] = Angle_Detection(Point, Centre, Radius)
% Reference point, i.e. 12'O clock
ReferencePoint = [Centre(1),Centre(2)-abs(Radius)];
Point1 = Point - Centre;
Point2 = ReferencePoint - Centre;
% Angle between these three points.
angle = atan2(Point1(1)*Point2(2)-Point2(1)*Point1(2), Point1(1)*Point2(1)+Point1(2)*Point2(2));
Angle = mod(-180/pi * angle, 360);
end