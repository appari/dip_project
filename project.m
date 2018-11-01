%% Scan The Input image
inp = imread('callender.jpg');
inp2 = imread('calender2.png');
inp_bw = rgb2gray(inp);

%% Trying Different filters on the image.

% Laplacian

h = fspecial('laplacian');
filteredout = imfilter(rgb2gray(imread('callender.jpg')),h);
imshow(filteredout);

% Sobel
[~, threshold] = edge(inp_bw, 'sobel');
BWs = edge(inp_bw,'sobel', threshold*0.5);
imshow(BWs);

% Canny edge 
filteredout = rgb2gray(imread('callender.jpg'));
canny = edge(filteredout,'canny');
imshow(canny)

% Canny + Laplacian
a = imfilter(rgb2gray(imread('callender.jpg')),h);
b = imbinarize(a);
c = edge(b);
imshow(c)


% Hough transform
a = imfilter(rgb2gray(imread('callender.jpg')),h);
b = imbinarize(a);
BW = edge(b,'canny');
[H,T,R] = hough(BW);
imshow(H,[],'XData',T,'YData',R,...
            'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;

P  = houghpeaks(H,44,'threshold',ceil(0.0000001*max(H(:))));
x = T(P(:,2)); y = R(P(:,1));
plot(x,y,'s','color','white');
lines = houghlines(BW,T,R,P,'FillGap',1,'MinLength',1);
figure, imshow(b), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
%
binarizedout = imbinarize(filteredout);
labels = bwlabel(binarizedout);
% labels = bwlabel(imfilter(rgb2gray(imread('callender.jpg')),h));

[r,c] = size(labels);
out = zeros(r,c);
for i=1:r
    for j=1:c
        if(labels(i,j)==0)
            out(i,j) = 1;
        else
            out(i,j) =0;
        end
    end
end
ocr_out = ocr(inp);


