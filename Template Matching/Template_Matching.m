function [] = Template_Matching()
Template=imread('template image'); 
Object=imread('object image');
[Rt,Ct] = size(Template);
% padding the Object such that the center of the template can be placed on 
% on each pixel of the Object.
TempObj = padarray(Object, [floor((Rt)/2) floor(Ct/2)],0,'post'); 
TempObj = padarray(TempObj, [ceil(Rt/2) ceil(Ct/2)],0,'pre');
[Rto,Cto]=size(TempObj);
corr=0.4;
% Center of the template is slided through each pixel of the object and the
% coorelation is computed.
 for i = 1: Rto-Rt
  for j = 1: Cto-Ct
   Correlation(i,j) = corr2(Template, TempObj(i:i+Rt-1,j:j+Ct-1));
  end
 end
figure(4),imshow(Correlation),title('Correlation of two images');
[ycord,xcord] = ind2sub(size(Correlation),find(Correlation >= max(Correlation(:))*corr));
index=1;
for n=1:length(xcord)-1
    if((xcord(n+1)-xcord(n)<=2)&(ycord(n+1)-ycord(n)<=2))
        xcord(n+1)=floor((xcord(n+1)+xcord(n))/2);
        ycord(n+1)=floor((ycord(n+1)+ycord(n))/2);
    else
        finalX(index)=xcord(n);
        finalY(index)=ycord(n);
        index=index+1;
    end
end
finalX(index)=xcord(length(xcord));
finalY(index)=ycord(length(xcord));
sprintf('Points in Correlation image :')
for z=1:length(finalX)
    sprintf('Instance %d is (%g,%g)',z,finalX(z),finalY(z))
end
sprintf('Points in the Object :')
for z=1:length(finalX)
    sprintf('Instance %d is (%g,%g)',z,(finalX(z)-floor(Rt/2)),finalY(z)-floor(Ct/2))
end

end