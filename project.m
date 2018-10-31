inp = imread('callender.jpg');
inp2 = imread('calender2.png');

h = fspecial('laplacian');
filteredout = imfilter(rgb2gray(imread('callender.jpg')),h);
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
ocr_out = ocr(inp)
