# ALU 
## A Paramterized Design on Arithmetic and Logical Unit

## INTRODUCTION

Arithmetic and logical units are an integral part of any SOC that performs Arithmetic and 
logical operations. The ALU designed in this project supports variety of functions including 
arithmetic operations such as addition, subtraction, increment, decrement, and multiplication,
as well as logical operations such as AND, OR, XOR, NOT, NAND, NOR, and XNOR. In addition, 
it supports shift and rotate operations. The design also has comparator functions and error 
checking for invalid command conditions. 

## OBJECTIVE

The objective of the project is to:   
 -> Design a synthesizable ALU using Verilog.   
 -> Support parameterized command, input and output widths as required.   
 -> Perform both signed and unsigned addition and subtraction, with appropriate generation of carry-out and overflow flags.   
 -> Execute the specified command for the given inputs with a one-cycle delay, except for the multiplication operation, which produces the result at third clock cycle.    
 -> Ensure the error flag is raised under defined invalid conditions.  
