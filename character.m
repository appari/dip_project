function out = character(img)
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
% Set text layout to 'Word' because the layout is nothing like a document.
% Set character set to be A to Z, to limit mistakes.
results = ocr(BW1, roi, 'TextLayout', 'Word','CharacterSet','A':'Z');
% remove whitespace in the results
c = cell(1,numel(results));
for i = 1:numel(results)
    c{i} = deblank(results(i).Text);
end
% insert recognized text into image
final = insertObjectAnnotation(im2uint8(BWOrig), 'Rectangle', roi, c);

out = final;

end