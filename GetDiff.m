function regularization = GetDiff(X,P) 
% 函数功能 正则化迭代式中的正则项，∫||x||dxdy
% 正则化方法：BTV
% im: 输入初始图像


lambda = ComputeA(X);
%% 计算对其求解的?
regularization = zeros(size(X));


% Create an inflated version of Xn so shifting operation is simpler
Xpad = padarray(X, [P P], 'symmetric');

% ComPute a grid of l=-P:P and m=0:P such that l+m>=0
for l=-P:P
  for m=-P:P%这里-P应该改为0

    % Shift HR by l and m
    Xshift = Xpad(1+P-l:end-P-l, 1+P-m:end-P-m);

    % Subtract from HR image and compute sign
    Xsign = sign(X-Xshift);
    
    % Shift Xsign back by -l and -m
    Xsignpad = padarray(Xsign, [P P], 0);

    Xshift = Xsignpad(1+P+l:end-P+l,1+P+m:end-P+m);

    regularization = regularization + lambda.^(abs(l)+abs(m)).*(Xsign-Xshift);

  end
end

