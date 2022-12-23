function [p] = gate(gate, qubit, N)
gate = sparse(gate);

if qubit == N
    p=kron(gate,speye(2^(N-1)));
elseif qubit == 1
    p = kron(speye(2^(N-1)),gate);
else
    %p = kron(kron(speye(2^(qubit-1)),gate),speye(2^(N-(qubit))));
    p = kron(kron(speye(2^(N-(qubit))),gate),speye(2^(qubit-1)));
end

%Inputs: gate is a 2x2 matrix. qubit and N are integers.
%gate.m creates a 2^N x 2^N matrix that represents the evolution of the input
%gate being applied to qubit number qubit (starting from 1) for a total
%number of qubits N.
%All the "gates" before and after the single qubit gate being applied will 
%be identity matrices
%We will use sparse matrices cause large dimensions blow up