# quantum-statevector-simulator
Quantum statevector simulator, special focus on generalizing controlled unitary gates.
# Theory
## The Kronecker/Tensor Product
The tensor product, also known as the Kronecker product (named after Leopold Kronecker but likely first described by Johann Zehfuss and later attributed to Kronecker), is an important operation in quantum computing. 

If $\vec{A}$ is an $m \times n$ matrix
```math
    \vec{A}=\begin{bmatrix}a_{11} & \cdots & a_{1n}\\
    \vdots&\ddots&\vdots\\
    a_{m1}&\cdots&a_{mn}\end{bmatrix},
```
and $\vec{B}$ is a $p \times q$ matrix
```math
    \vec{B}=\begin{bmatrix}b_{11} & \cdots & b_{1q}\\
    \vdots&\ddots&\vdots\\
    b_{p1}&\cdots&a_{pq}\end{bmatrix},
```
the Kronecker Product of $\vec{A}$ and $\vec{B}$ is
```math
    \vec{A}\otimes\vec{B}=  \begin{bmatrix}a_{11}\vec{B} & \cdots & a_{1n}\vec{B}\\
    \vdots&\ddots&\vdots\\
    a_{m1\vec{B}}&\cdots&a_{mn}\vec{B}\end{bmatrix}.
```

For example,
```math
    Y \otimes X = \begin{bmatrix}0&-i\\i&0\end{bmatrix} \otimes \begin{bmatrix}0&1\\1&0\end{bmatrix} = \begin{bmatrix}0\begin{bmatrix}0&1\\1&0\end{bmatrix}&-i\begin{bmatrix}0&1\\1&0\end{bmatrix}\\i\begin{bmatrix}0&1\\1&0\end{bmatrix}&0\begin{bmatrix}0&1\\1&0\end{bmatrix}\end{bmatrix} 
      =\begin{bmatrix}0&0&0&-i\\
    0&0&-i&0\\
    0&i&0&0\\
    i&0&0&0\end{bmatrix}
```
## Qubits
A qubit $|\psi\rangle$ can be generally expressed as a linear combination of the basis vectors
```math
|0\rangle = \begin{bmatrix}1\\0 \end{bmatrix} , |1\rangle = \begin{bmatrix}0\\1 \end{bmatrix},
```
as
```math
|\psi\rangle = \alpha |0\rangle + \beta |1\rangle = \alpha \begin{bmatrix}1\\0 \end{bmatrix} + \beta \begin{bmatrix}0\\1 \end{bmatrix} = \begin{bmatrix}\alpha\\\beta \end{bmatrix}.
```
Each qubit can be described by a $2\times1$ column vector in complex Hilbert space.
We can describe a system of multiple quantum objects using the tensor product, or Kronecker product.
For example, three qubits in the $|1\rangle$, $|0\rangle$, and $|1\rangle$ states can be written as $|1\rangle \otimes |0\rangle \otimes |1\rangle = |101\rangle$. This composite quantum system can be described by a $8\times1$ column vector in complex Hilbert space.

The column vector that fully describes the system consisting of three qubits $|\psi\rangle$, $|\phi\rangle$, and $|\theta\rangle$ can be constructed by performing Kronecker product $|\psi\rangle \otimes |\phi\rangle \otimes |\theta\rangle$ and has dimensions $8\times1$.

Generally, the column vector that describes an $n$-qubit system will have dimensions $2^n \times 1$.

The column vector that describes the composite system of $n$ qubits $|\phi_1\rangle, |\phi_2\rangle, ... , |\phi_n\rangle$ is the Kronecker product $|\phi_1\rangle \otimes |\phi_2\rangle \otimes \cdots \otimes |\phi_n\rangle$.

## Gates
For quantum systems, timesteps are taken by applying unitary operations to a system. The mathematical representation of a quantum logic gate is a square matrix. A 1-qubit gate is a $2\times2$ square matrix. A $2\times2$ square matrix applied to a $2\times1$ qubit statevector produces a $2\times1$ result qubit statevector. This is one step forward through a quantum circuit.

Mathematically, an $X$-gate applied to a qubit $|\psi\rangle$ is represented by
```math
X|\psi\rangle.
```

If we have the composite system of $|\psi\rangle$ and $|\phi\rangle$, how we can represent applying $X$ to $|\psi\rangle$ and $Y$ to $|\phi\rangle$? There are multiple paths to reach this answer.

We can think of the resulting statevector of the system as the tensor product of the result of $X$ on $|\psi\rangle$ and $Y$ on $|\phi\rangle$:
```math
(X|\psi\rangle) \otimes (Y|\phi\rangle).
```

We can also think of the combined effect of the two gates on the initial composite statevector:

```math
(X \otimes Y) (|\psi\rangle \otimes |\phi\rangle).
```
Because the Kronecker product is associative, these two statements are mathematically equivalent and produce the same resulting statevector:
```math
(X|\psi\rangle) \otimes (Y|\phi\rangle) = (X \otimes Y) (|\psi\rangle \otimes |\phi\rangle).
```

Generally, the unitary matrix $U$ that represents applying $n$ gates $G_1, G_2, ... ,G_n$ to $n$ qubits is

```math
U = G_1 \otimes G_2 \otimes \cdots \otimes G_n.
```
$U$ has dimensions $2^n \times 2^n$.

An "empty" section of wire on a quantum circuit represents doing nothing to that respective qubit. This is represented by applying the identity matrix $I$ which does not change the vector it is being applied to.

Therefore, for a system of $n$ qubits, the unitary that applies only one gate $G$ to the $q^{th}$ qubit 

## General Construction of Controlled Unitary Gates

A controlled-unitary gate will apply some unitary gate $G$ to a target qubit if the control qubit is in the state $|1\rangle$ and will do nothing if the control qubit is in the state $|0\rangle$ (i.e. it applies the identity gate $I$ to the target qubit).






