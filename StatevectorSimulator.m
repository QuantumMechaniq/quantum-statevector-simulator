%% Qubit Statevector Simulator

clear all %clear all variables

psi0 = sparse(1,1,1,1,2^16)';
%psi0 is the starting state |000...0>,
% which is the column vector [1,0,0,0,...,0] with 16 elements

%gates
H=sqrt(1/2)*[1,1;1,-1];
X=[0,1;1,0];
T=[1,0;0,exp(i*pi/4)];
Tdg = [1,0;0,exp(-i*pi/4)];

%% read in qasm data from .txt file

filenames = ["con1_216","mini_alu_305","sym6_316","miller_11",...
    "one-two-three-v3_101","hwb5_53","cm152a_212","squar5_261","rd84_142",...
    "f2_232","alu-bdd_288","decod24-v2_43","cnt3-5_179","wim_266"];

%solutions for the respective qasm files

qasmsolutions = ["1001011100000000","0000000110000000","0000000000001000",...
    "0000000000000000","1100000000000000","0000000000000000","0111000000000000",...
    "0000000011011000","0000000000000000","0000011000000000","0000001000000000",...
    "0001000000000000","0000000000000000","1101111111100000"];

%preallocate some arrays
times = zeros(1,length(filenames));
Ns = zeros(1,length(filenames));
circuitDepths = zeros(1,length(filenames));
numCNOTs = zeros(1,length(filenames));
nonzeroelements = zeros(1,length(filenames));
depth = 0;

for k = 1:length(filenames)

    % Import data from text file
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
    tbl = readtable(strcat("C:\Users\Jacob\Desktop\cs238qasm\",filenames(k),".txt"), opts);
    % Convert to output type
    qreg = tbl.qubits(1);
    creg = tbl.qubits(2);
    gates = tbl.gates(3:end);
    qubits = tbl.qubits(3:end)+1; %+1 for matlab indexing: qubit 0 is now qubit 1
    controls = tbl.controls(3:end)+1; %+1 for matlab indexing: qubit 0 is now qubit 1
    % Clear temporary variables
    clear opts tbl
    

    %% Executing all of the gates
    % We don't want to have to do all of the qubits until the end if we can
    % avoid it, so we will calculate only with the max qubit index involved
    % and then extend to N = 16 qubits
    
    depth = length(gates);
    N = 0;%N keeps track of the number of total qubits involved at any point
    %N = max(max(qubits),max(controls)); %N is the largest qubit index referenced in qubits or controls
    U = 1;%Dummy starter U for the total product of the circuit
    qubit = 0;%Starting qubit index at 0
    CNOTcount = 0;
    tic %begin timer
    
    for index = 1:depth
    
        qubit = max(controls(index),qubits(index));
        %expand U to the dim of the largest qubit index involved so far
        if N < qubit
            N = qubit;
            U = extend(U,N);
        end
    
        %Read the qasm gate text and apply the appropriate gate
        G = gates(index);
        if G == "cx"
            U = controlled(X,qubits(index),controls(index),N) * U;
            CNOTcount = CNOTcount + 1;
        elseif G == "x"
            U = gate(X,qubits(index),N) * U;
        elseif G == "t"
            U = gate(T,qubits(index),N) * U;
        elseif G == "tdg"
            U = gate(Tdg, qubits(index),N) * U;
        elseif G == "h"
            U = gate(H, qubits(index),N) * U;
        else
            error('gate does not match')
        end
    
    end
    
    Uunextended = U;
    
    %If N is less than 16 qubits, we extend the unitary to be appropriate for
    %16 qubits
    if N < qreg
        U = extend(U,qreg);
    end
    
    
    %psi0 is the starting state |000...0>,
    % which is the column vector [1,0,0,0,...,0] with 16 elements
    result = U*psi0;

    elapsedTime = toc; %end timer

    %Check to see if the imaginary and the real parts of the simulator
    %solution are within machine precision of the qasm solution
    a=string2statevector(char(qasmsolutions(k)));
    solnmatch = 0;
    if (sum(abs(imag(a-result)) > eps) == 0) && (sum(real(a-result) > eps) == 0)
        sprintf(['The simulator matches the solution within machine ' ...
            'precision for circuit '] + filenames(k) + '.qasm.','Interpreter','none')
        solnmatch = 1
    end
    
    figure
    spy(Uunextended)
    hold on
    set(gca,'FontName','cmr12')
    title('Sparsity of Unitary Matrix for Circuit ' + filenames(k) + '.qasm','Interpreter','none','FontName', 'Highway Gothic')
    plot(0,0,'k')%Makes an invisible dot in the corner so we can title the plots
    xlabel(sprintf('Qubits before Expanding: %d', log2(length(Uunextended))))
    
    
    times(k) = elapsedTime;
    Ns(k) = N;
    circuitDepths(k) = depth;
    numCNOTs(k) = CNOTcount;
    nonzeroelements(k)=nnz(Uunextended);
end

%%
figure('units','normalized','outerposition',[0 0 1 1])
[Nsort,isrt] = sort(Ns);
timesort = times(isrt);
sgtitle('Execution Time vs. Number of Qubits in Circuit')
subplot(1,3,1)
plot(Nsort,timesort,'*-')
title('Linear')
ylabel('Execution Time [s]')
xlabel('Number of Qubits')
subplot(1,3,2)
semilogy(Nsort,timesort,'*-')
title('Semilog')
ylabel('Execution Time [s]')
xlabel('Number of Qubits')
subplot(1,3,3)
loglog(Nsort,timesort,'*-')
title('Log-log')
ylabel('Execution Time [s]')
xlabel('Number of Qubits')

figure('units','normalized','outerposition',[0 0 1 1])
[depthsort,isrt] = sort(circuitDepths);
timesort = times(isrt);
sgtitle('Execution Time vs. Circuit Depth')
subplot(1,3,1)
plot(depthsort,timesort,'*-')
title('Linear')
ylabel('Execution Time [s]')
xlabel('Number of Gates')
subplot(1,3,2)
semilogy(depthsort,timesort,'*-')
title('Semilog')
ylabel('Execution Time [s]')
xlabel('Number of Gates')
subplot(1,3,3)
loglog(depthsort,timesort,'*-')
title('Log-log')
ylabel('Execution Time [s]')
xlabel('Number of Gates')

figure('units','normalized','outerposition',[0 0 1 1])
volumes = circuitDepths.*Ns;
[volsort,isrt] = sort(volumes);
timesort = times(isrt);
sgtitle('Execution Time vs. Circuit Volume')
subplot(1,3,1)
plot(volsort,timesort,'*-')
title('Linear')
ylabel('Execution Time [s]')
xlabel('Num Gates x Num Qubits')
subplot(1,3,2)
semilogy(volsort,timesort,'*-')
title('Semilog')
ylabel('Execution Time [s]')
xlabel('Num Gates x Num Qubits')
subplot(1,3,3)
loglog(volsort,timesort,'*-')
title('Log-log')
ylabel('Execution Time [s]')
xlabel('Num Gates x Num Qubits')


figure('units','normalized','outerposition',[0 0 1 1])
[cnotsort,isrt] = sort(numCNOTs);
timesort = times(isrt);
sgtitle('Execution Time vs. Number of CNOTs in Circuit')
subplot(1,3,1)
plot(cnotsort,timesort,'*-')
title('Linear')
ylabel('Execution Time [s]')
xlabel('Number of CNOTs')
subplot(1,3,2)
semilogy(cnotsort,timesort,'*-')
title('Semilog')
ylabel('Execution Time [s]')
xlabel('Number of CNOTs')
subplot(1,3,3)
loglog(cnotsort,timesort,'*-')
title('Log-log')
ylabel('Execution Time [s]')
xlabel('Number of CNOTs')

figure('units','normalized','outerposition',[0 0 1 1])
[nnzsort,isrt] = sort(nonzeroelements);
timesort = times(isrt);
sgtitle('Execution Time vs. Sparsity of Resulting Unitary (Before Extension)')
subplot(1,3,1)
plot(nnzsort,timesort,'*-')
title('Linear')
ylabel('Execution Time [s]')
xlabel('Number of Nonzero Elements')
subplot(1,3,2)
semilogy(nnzsort,timesort,'*-')
title('Semilog')
ylabel('Execution Time [s]')
xlabel('Number of Nonzero Elements')
subplot(1,3,3)
loglog(nnzsort,timesort,'*-')
title('Log-log')
ylabel('Execution Time [s]')
xlabel('Number of Nonzero Elements')