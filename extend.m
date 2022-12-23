function [p] = extend(U, N)
dim = log2(length(U));
if diff(size(U)) ~= 0
    error('The input matrix is not square.')
elseif sqrt(dim) >= N
    error('The input matrix has dimensions equal to or greater than the Hilbert space you are requesting it be extended into.')
else
p = kron(speye(2^(N - dim)),U);
end