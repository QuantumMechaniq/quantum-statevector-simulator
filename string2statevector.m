function [p] =string2statevector(s)
%turns a binary string into a statevector
%This uses Qiskit's ordering: |q1,q2,q3,...,qN>,
%as opposed to the standard ordering:|qN,qN-1,...,q3,q2,q1>
ket0 = [1;0];
ket1 = [0;1];
ket = {[ket0],[ket1]};
vec=s-'0';
p=1;
for i = 1:length(vec)
    p=kron(p,ket{1+vec(i)});
end
end