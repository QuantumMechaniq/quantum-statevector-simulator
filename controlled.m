function [p] = controlled(gate, control, target, N)
gate = sparse(gate);

P0 = [1,0;0,0];%Projector for |0><0|
P1 = [0,0;0,1];%Projector for |1><1|
kp=@(A,B,C,D) kron(kron(A,B),kron(C,D));
if control == target
    error('Control and target qubit have the same index')
elseif target > control
    p = kron(kron(speye(2^(N - control)), P0), speye(2^(control - 1))) +...
        kron(kron(kron(kron(speye(2^(N - target)), gate), speye(2^(target - 1 - control))), P1), speye(2^(control - 1)));
elseif target < control
    p = kron(kron(speye(2^(N - control)), P0), speye(2^(control - 1))) +...
        kron(kron(kron(kron(speye(2^(N - control)), P1), speye(2^( control - 1 - target))), gate), speye(2^(target - 1)));
end

%Inputs: gate is a 2x2 matrix. control, target, and N are integers.
%controlled.m creates a 2^N x 2^N matrix that represents the evolution of a
%controlled-gate with control qubit number "control" and target qubit
%number "target" 
% for a total number of qubits N.
% Qubit index starts at 1.
%All the "gates" before and after the single qubit gate being applied will 
%be identity matrices
%We will use sparse matrices cause large dimensions blow up