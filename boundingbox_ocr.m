inp = imread('callender.jpg');
inp2 = imread('calender2.png');
inp_bw = rgb2gray(inp2);
h = fspecial('laplacian');
a = imfilter(inp_bw,h');
b = imbinarize(a);
[~, threshold] = edge(inp_bw, 'sobel');
BWs = edge(inp_bw,'sobel', threshold*0.6);
imshow(BWs)
BW = edge(BWs,'sobel');
imshow(BW)
[H,T,R] = hough(BW);
imshow(H,[],'XData',T,'YData',R,...
            'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;

P  = houghpeaks(H,100,'threshold',ceil(0.00002*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));
y = y(x==-90|x==0);
x = x(x==-90|x==0);
plot(x,y,'s','color','white');
lines = houghlines(BW,T,R,P,'FillGap',1,'MinLength',2);
figure, imshow(inp2), hold on
max_len = 0;
points = [];
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   points(k,:) = [lines(k).point1,lines(k).point2];
end
%

x1 = points(:,1);
x2 = points(:,3);
y1 = points(:,2);
y2 = points(:,4);
pts = [x1,y1;x2,y2];
[a,b] = hist(pts(:,1),unique(pts(:,1)));
X_cor = b(a>10);
[a,b] = hist(pts(:,2),unique(pts(:,2)));
Y_cor = b(a>15);

for i = 1:length(X_cor)-1
    if(X_cor(i+1)-X_cor(i)<10)
%         X_cor(i) = (X_cor(i) + X_cor(i+1))/2;
        X_cor(i+1) = X_cor(i);
    end
end

for i = 1:length(Y_cor)-1
    if(Y_cor(i+1)-Y_cor(i)<20)
%         X_cor(i) = (X_cor(i) + X_cor(i+1))/2;
        Y_cor(i+1) = Y_cor(i);
    end
    
end
Y_cor(i+1) = Y_cor(i); 

corners_x =[];
corners_y = [];

for i=1: size(inp_bw,1)
    for j=1:size(inp_bw,2)
        if(~isempty(X_cor(X_cor==j))&& ~isempty(Y_cor(Y_cor==i)) )
            plot(j,i,'x','LineWidth',2,'Color','red');
            corners_x = [corners_x,j];
            corners_y = [corners_y,i];
            
        end

    end
end

corners_x = unique(corners_x);
corners_y = unique(corners_y);
t=1;
for i=1:length(corners_x)-1
   for j=1:length(corners_y)-1
        boxes(t,1) = corners_x(i);
        boxes(t,2) = corners_x(i+1);
        boxes(t,3) = corners_y(j)+2;
        boxes(t,4) = corners_y(j+1)+2;
        t= t+1;
    end
end


struct = {};
for j = 1:length(boxes)
    
    img = inp2(boxes(j,3):boxes(j,4),boxes(j,1):boxes(j,2));
    % Make the image a bit bigger to help OCR
    img = imresize(img, 3);

    % binarize image
    lvl = graythresh(img);
    BWOrig = im2bw(img, lvl);
  
    % First remove the circuit using connected component analysis.
    BWComplement = ~BWOrig;
    CC = bwconncomp(BWComplement);
    numPixels = cellfun(@numel, CC.PixelIdxList);
    [biggest,idx] = max(numPixels);
    BWComplement(CC.PixelIdxList{idx}) = 0;
 
    % Next, because the text does not have a layout typical to a document, you
    % need to provide ROIs around the text for OCR. Use regionprops for this.
    BW = imdilate(BWComplement, strel('disk',3)); % grow the text a bit to get a bigger ROI around them.
    CC = bwconncomp(BW);
    % Use regionprops to get the bounding boxes around the text
    s = regionprops(CC,'BoundingBox');
    roi = vertcat(s(:).BoundingBox);
    % Apply OCR
    % Thin the letters a bit, to help OCR deal with the blocky letters
    BW1 = imerode(BWComplement, strel('square',1));
    box = [boxes(j,1),boxes(j,2),boxes(j,3),boxes(j,4)];
%     t = ocr(inp2(boxes(j,3):boxes(j,4),boxes(j,1):boxes(j,2)));

    x = ocr(BW1,'TextLayout','Block');
    
    struct(j).word = x.Words;
    struct(j).colour = inp2(boxes(j,3) + 3,boxes(j,1) +3 ,:);
    struct(j).bound = box;
    
end


img = inp2(Y_cor(end):size(inp2,1),X_cor(1):size(inp2,2));
img = imresize(img, 3);
lvl = graythresh(img);
BWOrig = im2bw(img, lvl);
BWComplement = ~BWOrig;
CC = bwconncomp(BWComplement);
numPixels = cellfun(@numel, CC.PixelIdxList);
[biggest,idx] = max(numPixels);
BWComplement(CC.PixelIdxList{idx}) = 0;
BW1 = imerode(BWComplement, strel('square',1));
x = ocr(BW1,'TextLayout','Block');


