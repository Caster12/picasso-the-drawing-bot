% -------------------------------------------------------------------------
% | Pic/Plot images to Coordinates Points                                 |
% | Amir Hossein Ashtari                                                  |
% | National University of Malaysia, Center for Artificial Intelligence   |
% | Technology (CAIT), Faculty Of Information Science and Technology      |
% | (c) 2015                                                              |
% -------------------------------------------------------------------------

clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 5;


%%


Im = imread('C:\Users\HP\Desktop\pic2points\Images\s2.jpg');
T = graythresh(Im);
ImPlot = 'true';
maxNum = 150;
M = pic2point(Im,T,ImPlot,maxNum);
M = sortrows(M,'descend');
[M] = scale(M);
M = nearestSort(M);
x = M(:,1);
y = M(:,2);
plot(x,y)

%% Nearest
function [Mnew] = nearestSort(M)

x = M(:,1);
y = M(:,2);
numPoints = size(M,1);

newx = [];
newy =[];

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.08, 1, 0.92]);

% Make a list of which points have been visited
beenVisited = false(1, numPoints);
% Make an array to store the order in which we visit the points.
visitationOrder = ones(1, numPoints);
% Define a filasafe
maxIterations = numPoints + 1;
iterationCount = 1;
% Visit each point, finding which unvisited point is closest.
% Define a current index.  currentIndex will be 1 to start and then will vary.
currentIndex = 1;
while sum(beenVisited) < numPoints && iterationCount < maxIterations
  % Indicate current point has been visited.
  visitationOrder(iterationCount) = currentIndex; 
  beenVisited(currentIndex) = true; 
  % Get the x and y of the current point.
  thisX = x(currentIndex);
  newx = [newx thisX];
  
  thisY = y(currentIndex);
  newy = [newy thisY];
  
  % Compute distances to all other points
  distances = sqrt((thisX - x) .^ 2 + (thisY - y) .^ 2);
  % Don't consider visited points by setting their distance to infinity.
  distances(beenVisited) = inf;
  % Also don't want to consider the distance of a point to itself, which is 0 and would alsoways be the minimum distances of course.
  distances(currentIndex) = inf;
  % Find the closest point.  this will be our next point.
  [minDistance, indexOfClosest] = min(distances);
  % Save this index
  iterationCount = iterationCount + 1;
  % Set the current index equal to the index of the closest point.
  currentIndex = indexOfClosest;
end
Mnew(:,1) = newx;
Mnew(:,2) = newy;
end
%%

function [M] = scale(M)
x = M(:,1);
y = M(:,2);
x = x./(max(x)*4);
y = y./(max(y)*4);
M = [x y];
end

function [MResult] = pic2point(Im,TshV,ImPlot,maxNum)

% -------------------------------------------------------------------------
% |                        How to use the code                            |
% -------------------------------------------------------------------------
% The provided source code gets an input image (black object pixels on 
% white background, e.g. an scanned plot with black ink on a white paper)
% The output is coordinates of all points/pixles in the image, therefore 
% the image is converted to coordinates of points and it is possible for 
% re-plotting the scanned image. In other words, the provided function is  
% an OCR for scanned plot to extract the image points coordinates. 
%
% ----------------------------------Inputs---------------------------------
%
%  (1)Im        - Input image, it can be gray, color or binary 
%                 image. The image can be Double = [0,1] or 
%                 Unsign integer = [0,255]. The image foreground must
%			      be black on white background.
%                    
%  (2)TshV      - Denotes the threshold value for image binarization.
%				  It is between 0~1 and by default is calculated by
%				  graythresh(Im).
%
%  (3)ImPlot    - If the image is a plot, ImPlot must be �1� or �true�. 
%                 The image is thinned to 1 pixel width line when ImPlot is 
% 	              true therefore finding the coordinate of drawn line in 
%	              plot would be possible.
%
%  (4)maxNum    - Denotes maximum number of points that should be	
%				  extracted from the image. If all points in the image
%				  are requested, leave the maxNum empty; otherwise enter 
%				  the arbitrary number to select randomly from all points.
%				  Actually it is a random resampling from all point for 
%                 output.
%    
% ----------------------------------Output---------------------------------
%
%  (1) MResult  - Matrix of pixels/points coordinates in the image. MResult
%				  has two columns, first column denotes x-coordinates
%				  and second column is for y-coordinates. 
%				  Number of rows equals to number of points in the image.
%   
% --------------------------------Examples---------------------------------
%
% example 1:
%
% Im = imread('./Images/Plot.png');
% CoordinateMatrix = pic2points(Im);
% scatter(CoordinateMatrix (:,1), CoordinateMatrix (:,2),'.'); 
%                                                          %Plot the points
%
% ----------------------------------
% example 2:
%
% Im = imread('./Images/Plot.png');
% CoordinateMatrix = pic2points(Im,0.547); % With defined threshold for 
%							               % binarization.
% scatter(CoordinateMatrix (:,1), CoordinateMatrix (:,2),'.'); 
%                                                          %Plot the points
% ----------------------------------
% example 3:
%
% Im = imread('./Images/Plot.png');
% CoordinateMatrix = pic2points(Im,0.547,1); % With defined threshold for 
%							                 % binarization and it is plot
%							                 % so line must be thin to 1 
%							                 % pixel.
% scatter(CoordinateMatrix (:,1), CoordinateMatrix (:,2),'.'); 
%                                                          %Plot the points
%
% ----------------------------------
% example 4:
%
% Im = imread('./Images/Plot2.png');
% CoordinateMatrix = pic2points(Im,0.547,1,1000); % With defined threshold 
%							               % binarization and it is plot 
%							               % so line must be thin to 1
%							               % pixel. 1000 is the number of
%							               % points that return by function
% scatter(CoordinateMatrix (:,1), CoordinateMatrix (:,2),'.'); 
%                                                          %Plot the points
%
% -------------------------------------------------------------------------

switch nargin
    case 1
        Pmode = false; % Not a plot
        randomPick = false;
        TshV = graythresh(Im);
    case 2
        Pmode = false; % Not a plot
        randomPick = false;
    case 3
        if strcmpi(ImPlot,'plot')
            Pmode = true; % It is a plot
        else
            Pmode = false; % It is an image
        end
        randomPick = false;
    case 4
        if strcmpi(ImPlot,'plot')
            Pmode = true; % It is a plot
        else
            Pmode = false; % It is an image
        end
        randomPick = true;
end
ImBW=im2bw(Im,TshV);
ImBW=1-ImBW; % When the plot drew by black ink on the white background
if Pmode
    ImBW = bwmorph(ImBW,'thin',Inf);
end
figure(); imshow(ImBW);
[r,c,v] = find(ImBW==1);
r = size(ImBW,1) - r; % Correct the coordinates from the image
TMresult = [c r];
if randomPick
    Sran = linspace(1,sum(v),maxNum)
    Sran = uint32(Sran);
%     Sran = randperm(sum(v),maxNum);
    
    MResult = TMresult(Sran',:);
else
    MResult = TMresult;
end 
end