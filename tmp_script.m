%% temporary script
nii = load_untouch_nii('data_neg/d01/S0293/dti.bedpostX/xfms/coef_diff2standard.nii.gz');
img = nii.img;
img_size = size(img);
u = squeeze(img(:,:,round(img_size(3)/2),1));
v = squeeze(img(:,:,round(img_size(3)/2),2));

u = u(1:img_size(1)/20:end, 1:img_size(2)/20:end);
v = v(1:img_size(1)/20:end, 1:img_size(2)/20:end);
x = 1:length(u);
y = 1:length(v);
[x,y] = meshgrid(x,y);
quiver(x,y,u,v);
axis([1,length(x)+1,1,length(y)+1]);
