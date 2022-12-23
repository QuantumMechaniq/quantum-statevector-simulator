syms a b c d e f g h
ket0 = [1;0];
ket1 = [0;1];
ket = {[ket0],[ket1];}

P0 = ket0 * conj(ket0');
P1 = ket1 * conj(ket1');
X = [0,1;1,0];
I=eye(2);

state = @(a,b,c) kron(kron(ket{1+a},ket{1+b}) ,ket{1+c})
state(0,0,0)
state(1,0,1)

H=[1,1;1,-1];
X=[0,1;1,0];
T=[1,0;0,exp(i*pi/4)];
Tdg = [1,0;0,exp(-i*pi/4)];

%% Routine for 1 qubit gate to arbitrary qubit with dim N predetermined
% N=9
% numq = 3; %number qubit the gate is acting on
% p = eye(2); %starting the product p
% gate=X
% tic
% for i = 1:N
%     if i == numq
% 
%         if i == 1
%             p = gate
%         else
%             p = kron(p,gate)
%         end
% 
%     else
% 
%         if i == 1
%             p = eye(2)
%         else
%             p = kron(p,eye(2))
%         end
% 
%     end
% 
% end
% toc
%% Maybe a different method for 1 qubit gates

N=9
numq = 3; %number qubit the gate is acting on
p = speye(2); %starting the product p
gate=sparse(H)
tic
for i = 1:N
    if i == numq

        if i == 1
            p = gate
        else
            p = kron(p,gate)
        end

    else

        if i == 1
            p = speye(2)
        else
            p = kron(p,speye(2))
        end

    end

end
toc

%% 1 qubit gate but instead of successive tensor products you just do one big eye(n) before the gate and one after

N=9
numq = 9; %number qubit the gate is acting on
gate=sparse(X)
tic

if numq == 1
    p=kron(gate,speye(2^(N-1)))
elseif numq == N
    p = kron(speye(2^(N-1)),gate)
else
    p = kron(kron(speye(2^(numq-1)),gate),speye(2^(N-(numq))))
end

toc

%% arbitrary controlled gate
N = 3
control = 3;%index of control qubit
target = 1;%index of target qubit
gate = X
P00 = kron(P0,P0); P11 = kron(P1,P1);
CNOT21 = kron(P0,speye(2)) + kron(P1,X)
CNOT12 = kron(speye(2),P0) + kron(X,P1)
CNOT31 = kron(kron(P0,eye(2)),eye(2)) + kron(kron(P1,eye(2)),X)
CNOT13 = kron(kron(eye(2),eye(2)),P0) + kron(kron(X, eye(2)), P1)

if control == target
    error('Control and target qubit have the same index')
elseif control < target
    p = kron(kron(speye(2^(control - 1)), P0), speye(2^(N - control))) +...
        kron(kron(kron(kron(speye(2^(control - 1)), P1), speye(2^(target - 1 - control))), gate), speye(2^(N - target)))
elseif control > target
    p = kron(kron(speye(2^(control - 1)), P0), speye(2^(N - control))) +...
        kron(kron(kron(kron(speye(2^(target - 1)), gate), speye(2^(control - 1 - target))), P1), speye(2^(N - control)))
end

%% Make CNOTS for control and target 1 thru 17
CNOTS={}

for control = 1:17
    for target = 1:17
        if target ~= control
          CNOTS{target,control} = controlled(X,control,target,17);
        end
    end
end


%% read in qasm data from .txt file
% Import data from text file
% Script for importing data from the following text file:
%
%    filename: C:\Users\Jacob\Downloads\rd84_142.txt
%
% Auto-generated by MATLAB on 27-Nov-2022 22:58:40

% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 3);

% Specify range and delimiter
opts.DataLines = [3, Inf];
opts.Delimiter = [" ", ","];

% Specify column names and types
opts.VariableNames = ["gates", "qubits", "controls"];
opts.VariableTypes = ["string", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";

% Specify variable properties
opts = setvaropts(opts, "gates", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "gates", "EmptyFieldRule", "auto");
opts = setvaropts(opts, ["qubits", "controls"], "TrimNonNumeric", true);
opts = setvaropts(opts, ["qubits", "controls"], "ThousandsSeparator", ",");

% Import the data
tbl = readtable("C:\Users\Jacob\Downloads\rd84_142.txt", opts);

% Convert to output type
qreg = tbl.qubits(1) + 1;
creg = tbl.qubits(2) + 1;
gates = tbl.gates(3:end);
qubits = tbl.qubits(3:end)+1; %+1 for matlab indexing: qubit 0 is now qubit 1
controls = tbl.controls(3:end)+1; %+1 for matlab indexing: qubit 0 is now qubit 1

% Clear temporary variables
clear opts tbl

% Executing all of the gates
%We don't want to have to do all of the qubits until the end if we can
%avoid it

depth = length(gates);
N = 0;%N keeps track of the number of total qubits involved at any point
U = 1;%Dummy starter U for the total product of the circuit
qubit = 0;%Starting qubit at 0

tic
for i = 1:depth

    qubit = qubits(i);

    if N < qubit
        N = qubit;
        U = extend(U,N);
    end

    %Read the qasm gate and apply the appropriate gate
    G = gates(i);
    if G == "cx"
        U = controlled(X,controls(i),qubits(i),N) * U;
    elseif G == "x"
        U = gate(X,qubits(i),N) * U;
    elseif G == "t"
        U = gate(T,qubits(i),N) * U;
    elseif G == "tdg"
        U = gate(Tdg, qubits(i),N) * U;
    elseif G == "h"
        U = gate(H, qubits(i),N) * U;
    end
end

if N < qreg
    U = extend(U,qreg);
end

psi0 = sparse(1,1,1,1,length(U))';
%This makes the starting state |000...0>,
% which is the column vector [1,0,0,0,...,0]
result = U*psi0;
elapsedTime = toc;