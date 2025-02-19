function [r_norm,x_ls,r] = get_spot_residual_background(o,A,b)

% Orthogonal Matching Pursuit (OMP)
% https://github.com/seunghwanyoo/omp
% Input for data of dimension n:
%   A: dictionary (matrix) [n x nAtoms]
%   b: signals [n x nData]
% Output:
%   r_norm: norm of residual after removing codes specified by
%   code_indices.
%   x_ls(:,i): coef vector for code A(:,code_indices(i)) [nData x nAtoms]
% Background vectors are just strip in each colour channel so only use one
% color channel in each round to find WeightFactor, not all 7. 
% Also, they are orthogonal hence can find x_ls independently for each
% background vector. 
nCodes = length(o.CharCodes);
code_indices = nCodes+1:nCodes+o.nBackground;
nSpots = size(b,2);
nSelectAtoms = length(code_indices);
x_ls = zeros(nSelectAtoms,nSpots);
SignalReshape = reshape(b,[o.nBP,o.nRounds,nSpots]);
%Background vectors orthogonal so can treat independently
i=1;
for g=code_indices
    WeightFactor = zeros(o.nRounds,nSpots);
    for r=1:o.nRounds
        WeightFactor(r,:) = squeeze(abs(SignalReshape(i,r,:)));
    end
    WeightFactor = 1./(WeightFactor+o.ompWeightShift).^o.ompWeightPower;
    WeightFactor = repelem(WeightFactor,o.nBP,1);
    A_g = repmat(A(:,g),[1,nSpots]);
    A_g = A_g.*WeightFactor;
    b_Weight = b.*WeightFactor;
    %Multiply by o.nBP because background vectors zero in all but one
    %channel.
    %x_ls(i,:) = diag(A_g'*b_Weight./sum(A_g.^2,1));
    x_ls(i,:) = sum((A_g.*b_Weight))./sum(A_g.^2,1);
    i=i+1;
end
A_omega = A(:,code_indices);
%x_ls = A_omega \ b;  % Aomega * x_ls = b
r = b - A_omega * x_ls; % get residual
r_norm = vecnorm(r,2,1)';
x_ls = x_ls';

end

