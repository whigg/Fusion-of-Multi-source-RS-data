% Computes the gradient backprojection for the super-resolution
% minimization function. This function implements the gradient of the
% level one norm between the projection of the estimated HR image and each
% of the LR images.
%
% Inputs:
% Xn - The current estimate of the HR image
% LR - A sequence of low resolution images
% Fmot - The tranlational motion for each LR frame
% Hpsf - The PSF function (common to all frames and space invariant)
% Dres - The resolution increment factor
%
% Outpus:
% The backprojection of the sign of the residual error
function G=GradientBackProject(Xn, LR, T) 

% Note that shift and blur are comutative, so to improve runtime, we first
% filter the HR image
%k=1;
HRsd = zeros(size(LR));

for k=1:size(LR,3)
    H(:,:,k)=double(abs(LR(:,:,k)-Xn)<T*GetSlope(LR(:,:,k)));
    H1(:,:,k)=ones(size(Xn))-H(:,:,k);
    HRsd(:,:,k)=H(:,:,k).*Xn+H1(:,:,k).*LR(:,:,k);
    Gsign(:,:,k) = sign(HRsd(:,:,k)-LR(:,:,k));
	HRsd(:,:,k)=H(:,:,k).*Gsign(:,:,k);
end
G=sum(HRsd,3);

end