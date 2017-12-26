
%% K- mean implimenation_vikas_code_1 
% k-means clustering basically is labeling the pixel having k- mean in a
% iterative faishon
function [clustered_img center]=km_kmeans(img) 
threshold = graythresh(img);
gray1=rgb2gray(img);
gray = double(gray1);
array = gray(:);   % Convert image into an array.
i = 0; j=0; % Intialize iteration Counters.
while(1)
    mean_val = mean(array); %  mean of the gray image
    i = i+1;   %Increment Counter for each iteration.
 while(true)
 j = j+1;   % Initialize Counter for each iteration.
 di = (sqrt((array-mean_val).^2));  % Find distance between mean and Gray Value.
dist = (sqrt(sum((array- mean_val).^2)/numel(array))); % Find range for Cluster Center.
%  dist = max(di(:))/5;
 qualified = di<dist;    % Check values are in selected range or not.
 new_mean = mean(array(qualified));   % Update mean.
       
 if isnan(new_mean)    % Check mean is not a NaN value.
%   disp('game over aunty ji')    
     break;
 end
 if mean_val == new_mean || j>10 %Condition for convergence and maximum iteration.
%   disp('game over')
 j=0;
 array(qualified) = [];  % Remove values which have assigned to a cluster.
 center(i) = new_mean;   % Store center of cluster.
 break;
end
 mean_val = new_mean;  % Update mean value.
 end
 if isempty(array) || i>10   % Check maximum number of clusters.
        i = 0;    % Reset Counter.
        break;
 end
 
end

center = sort(center);    % Sort Centers.
newcenter = diff(center);    % Find out Difference between two consecutive Centers. 
intercluster = (max(gray(:)/10));    % Findout Minimum distance between two cluster Centers.
center(newcenter<=intercluster)=[];  % Discard Cluster centers less than distance.

% Now we can make a clustered image using these centers.
vector = repmat(gray(:),[1,numel(center)]); % Replicate vector for parallel operation.
centers = repmat(center,[numel(gray),1]);

distance = ((vector-centers).^2);    % Find distance between center and pixel value.
[~,clustered_img] = min(distance,[],2); % Choose cluster index of minimum distance.
clustered_img = reshape(clustered_img,size(gray)); % Reshape the labelled index vector.
end
% figure()
% subplot(121)
% title('clustered image')
% imshow(clustered_img,[])
% subplot(122)
% title('original image')
% imshow(gray1)