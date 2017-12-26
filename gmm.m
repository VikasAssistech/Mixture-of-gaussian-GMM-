%%%%%%%%%%%%%%%%%%%%%%%%% Assignment-0 : GMM %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% frame read and variable
video=VideoReader('video.mp4');
nframe=video.CurrentTime;
frame=readFrame(video); % read 1st frame as background frame
frame=frame(260:320,120:420,:); % downsize to quarter
frame_bw = rgb2gray(frame); % convert background to greyscale
frame_size = size(frame); 
width = frame_size(2);
height = frame_size(1);
foreground = zeros(height, width);  % foregtound image
background = zeros(height,width);       % Background

%% Mixture of Gaussian variables 
K = 3; % number of gaussian 
M = 3; % number of components in background 
D = 2.5; %+ve deviation threshold
alpha = 0.01; % learning rate 
thresh = 0.35; % foreground threshold 
sd_init = 6; % initial standard deviation var = 30 in paper

weight = zeros(height,width,K); % initialize weights
mean = zeros(height,width,K); % pixel means
sd = zeros(height,width,K); % pixel standard deviations
Pixel_diff = zeros(height,width,K); % difference of each pixel from mean // Mahalanobi s distance
p = alpha/(1/K); % initial p variable used to update mean and sd
order = zeros(1,K); % order the gaussian by (weight/sd)


% --------------------- initialize Component means and weights -----------

pixel_depth = 8; % 8-bit resolution
pixel_range = 255; % pixel range 
mean(:,:,:) = pixel_range.*rand([height,width,K]); % means random choosen initialy 
weight(:,:,:) = 1/K; % weights uniformly distributed
sd(:,:,:) = sd_init; % initialize sd to sd_init

pframe=100;  % lets test for initial 10 frame
tic
for n = 1:pframe
CurrenrFr=readFrame(video);
CurrenrFr=CurrenrFr(260:320,120:420,:); % downsize to quarter
% CurrenrFr = imresize(CurrenrFr, 0.25); % downsize to quarter to run faster
CurrenrFr_bw = rgb2gray(CurrenrFr);  % convert CurrenrFrame to grayscale

% difference of mean from current frame /  Mahalanobi's distance calculation 
for m=1:K
Pixel_diff(:,:,m) = abs(double(CurrenrFr_bw) - double(mean(:,:,m)));
end

% update gaussian components for each pixel
for i=1:height
for j=1:width  
match = 0;
for k=1:K 

 %  E-M   
if (abs(Pixel_diff(i,j,k)) <= D*sd(i,j,k))     % Expectation stage: if( Mahalanobi s distance <=  D*sd )
% Current pixel is match with one of the K Gaussian and classify pixel as background
match = 1;  
%update parameters weights, mean, sd, & p for matching distribution
weight(i,j,k) = (1-alpha)*weight(i,j,k) + alpha;                % w(i,t+1) = (1-alpha)*w(i,t)+alpha
p = alpha/weight(i,j,k);                                        % p=alpha/w(i,t+1)
mean(i,j,k) = (1-p)*mean(i,j,k) + p*double(CurrenrFr_bw(i,j));  % mean(i,t+1)=(1-p)*mean(i,t)+p*X(t+1)
sd(i,j,k) = sqrt((1-p)*(sd(i,j,k)^2) + p*((double(CurrenrFr_bw(i,j)) - mean(i,j,k)))^2);

else     % Maximization
% current pixel value Xt doesn't match with any of the K Gaussian hence  its a foreground pixel
% slighly decreases the weight but mean and sd would be same in case of unmatched
weight(i,j,k) = (1-alpha)*weight(i,j,k); 
end
end

% normalized the weight
weight(i,j,:) = weight(i,j,:)./sum(weight(i,j,:));

% updated the background model
background(i,j)=0;
for k=1:K
background(i,j) = background(i,j)+ mean(i,j,k)*weight(i,j,k);
end

% if no components match, re initialized mean and sd
if (match == 0)
[min_w, min_w_index] = min(weight(i,j,:)); 
mean(i,j,min_w_index) = double(CurrenrFr_bw(i,j));
sd(i,j,min_w_index) = sd_init;
end

order = weight(i,j,:)./sd(i,j,:); % calculate gaussian component order
order_ind = [1:1:K];


%% calculate foreground
match = 0;
k=1;
foreground(i,j) = 0;
while ((match == 0)&&(k<=M))

if (weight(i,j,order_ind(k)) >= thresh)
if (abs(Pixel_diff(i,j,order_ind(k))) <= D*sd(i,j,order_ind(k)))
% background pixel
foreground(i,j) = 0;
match = 1;
else
% foreground pixel   
foreground(i,j) = CurrenrFr_bw(i,j); 
end
end
k = k+1;
end
end
end
figure(1)
imshow(foreground) 
figure(2)
imshow(CurrenrFr)
end
toc