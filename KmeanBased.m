%%%%%%%%%%%%%%%%%%%%%%%  K-mean based background subtraction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
clear all;
video=VideoReader('video.mp4');% read the video
nrow=video.Height;
ncolumn=video.Width;
Bkg=zeros(nrow,ncolumn,3);
nframe=video.numberofFrames;% no. of frames in the video
framerate=video.framerate;%no. of frames in a sec
for n=1:20;
    img=read(video,n);
    img=double(img);
   Bkg=imadd(Bkg,img);
end
Background=Bkg/20;
Background=uint8(Background);
Bkg_gray=rgb2gray(Background);
CC_new=[];
CC_ne=[];

CC_old1=[];   %  centroid
CC_old2=[];   %   centroid
cc=[];

%%
m1=21;
CurrentFrame1=read(video,m1);

%%
%%%%%%%%%%%%%%%%% MEAN CLUSTERING of above background %%%%%%%%%%%%%%%%%%%%
Background = imadjust(Background, stretchlim(Background), [0 1]);
[kmean_Background,center_background] = km_kmeans(Background);

CurrentFrame1 = imadjust(CurrentFrame1, stretchlim(CurrentFrame1), [0 1]);
[kmean_CurrentFrame1,center_CurrentFrame] = km_kmeans(CurrentFrame1);

%%%%%%%%%%%%%%%%% forgroung extraction %%%%%%%%%%%%%%%%%
Forgnd1=imsubtract(kmean_Background,kmean_CurrentFrame1);  % forgroung 


%%%%%%%%%%%%%%%%%%% main loop %%%%%%%%%%%%%%%%%%%%%%%%%
for m=21:1000
    m
    CC_old2=[];
CurrentFrame2=read(video,m+1);
CurrentFrame2 = imadjust(CurrentFrame2, stretchlim(CurrentFrame2), [0 1]);
[kmean_CurrentFrame2,center_CurrentFrame] = km_kmeans(CurrentFrame2);

Forgnd2=imsubtract(kmean_Background,kmean_CurrentFrame2);

  figure(1);
  pause(0.1)
 subplot(121),
imshow(Forgnd2)
 subplot(122),imshow(CurrentFrame2)
% subplot(223),imshow(Forgnd_new_new2)
% prop2=regionprops(Forgnd_label2,'Area','BoundingBox','Centroid'); 
% figure(4)
% imshow(Forgnd_new_new2)
% imshow(CurrentFrame2)
% hold on
% for n1=1:noc2
% CC2=prop2(n1).Centroid;
% CC_old2=[CC2 CC_old2];
% s=length(CC_old2);
% end
% dis=[];
% dist_n=[];

%%%%%%%%%%%%%% Trajectory based occlusion handling %%%%%%%%%%%
% for p=1:l/2  % privious centroid   
%     for q=1:noc2  % current frame
%         dist=sqrt(((CC_old2((2*q)-1))-CC_old1((2*p)-1))^2 +(CC_old2((2*q))-CC_old1(2*p))^2);
% %         pause(2)
%         dist_n(q)=sqrt(((CC_old2((2*q)-1))-CC_old1((2*p)-1))^2 +(CC_old2((2*q))-CC_old1(2*p))^2);
%         A2=prop2(q).Area;
%  if dist<=18
%     plot(CC_old2(2*q-1),CC_old2(2*q),'*g')
%     BB2=[((CC_old2(2*q-1))-15) ((CC_old2(2*q))-30) 30 60]; 
%    %c1=CC_old2(2*q-1);
%    %c2=CC_old2(2*q);
%    %c=[c1 c2]
%    CC_new=[ CC_new CC_old2(2*q-1) CC_old2(2*q)];
%    CC_ne=union(CC_ne,CC_new,'stable');
%    CC_ne=CC_ne';
% %    BB2=prop2(q).BoundingBox   
%    rectangle('Position',BB2,'EdgeColor','g','LineWidth',2)
% % pause(2)
%    % hold on    
% end
   
% dist_min(p)=min(dist_n);


end


