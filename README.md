# love_matrix
love_matrix: A SAS macro toolkit for basic matrix operations (multiply, inverse, determinant, Cholesky, etc.) — works with PROC FCMP, no SAS/IML required.  
<img width="321" height="384" alt="Image" src="https://github.com/user-attachments/assets/46c031d2-3f48-46b6-b923-30be02bce299" />  

## `%matrix_mult()` macro <a name="matrixmult-macro-5"></a> ######

Macro Name    : %matrix_mult
 
 Purpose       :
   Perform matrix multiplication between two input SAS datasets containing 
   only numeric variables. The macro extracts numeric columns, validates 
   dimensions, and outputs the resulting product matrix as a SAS dataset.

 Parameters    :
 ~~~text
   dataset1=        Input dataset representing the left matrix (observations × variables).
   dataset2=        Input dataset representing the right matrix (observations × variables).
   output_dataset=  Output dataset name where the resulting matrix will be written.
                    Default = WORK.OUTPUT_M
~~~
 Requirements  :
   - Both input datasets must contain only numeric variables or will be 
     reduced to numeric variables internally.
   - The number of numeric columns in dataset1 must equal the number of rows 
     in dataset2 (matrix multiplication rule).
   - Uses PROC FCMP and the CALL MULT routine for matrix multiplication.

 Outputs       :
   - A SAS dataset with dimension (nobs1 × nvars2) containing the 
     matrix product.

 Example Usage :
 ~~~sas
   data wk1;
     a=1; b=2; c=4; output;
     a=5; b=8; c=9; output;
   run;

   data wk2;
     d=3; e=6; output;
     d=2; e=1; output;
     d=0; e=10; output;
   run;

   %matrix_mult(dataset1=wk1, dataset2=wk2, output_dataset=prod_matrix);
~~~

 Notes         :
   - If dimensions do not match, the macro stops with a warning message.
  
---
