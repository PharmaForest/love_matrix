/*** HELP START ***//*

Macro Name    : %matrix_mult
 
 Purpose       :
   Perform matrix multiplication between two input SAS datasets containing 
   only numeric variables. The macro extracts numeric columns, validates 
   dimensions, and outputs the resulting product matrix as a SAS dataset.

 Parameters    :
   dataset1=        Input dataset representing the left matrix (observations × variables).
   dataset2=        Input dataset representing the right matrix (observations × variables).
   output_dataset=  Output dataset name where the resulting matrix will be written.
                    Default = WORK.OUTPUT_M

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

 Notes         :
   - If dimensions do not match, the macro stops with a warning message.

*//*** HELP END ***/

%macro matrix_mult(dataset1=,dataset2=, output_dataset= output_m );
data temp1;
set &dataset1.;
keep _numeric_;
run;

data temp2;
set &dataset2.;
keep _numeric_;
run;

proc sql noprint; 
  select count(*) into:_nobs1 trimmed from temp1;
  select count(*) into:_nvars1 trimmed from dictionary.columns 
  where libname='WORK' and memname="TEMP1"; 
  select count(*) into:_nobs2 trimmed from temp2;
  select count(*) into:_nvars2 trimmed from dictionary.columns 
  where libname='WORK' and memname="TEMP2"; 
quit;
 %if %eval(&_nvars1) ne %eval(&_nobs2) %then %do;
    %put WARNING: The dimensions of the matrix product do not match. The number of numerical columns in &dataset1 (&_nvars1) ^= the number of rows in &dataset2 (&_nobs2)..;
    %return;
  %end;
proc fcmp;
   array mat1[&_nobs1.,&_nvars1.] /nosym;
   array mat2[&_nobs2.,&_nvars2.] /nosym;
   array outm[&_nobs1.,&_nvars2.];
   rc = read_array("TEMP1", mat1) ;
   rc = read_array("TEMP2", mat2) ;
   call mult(mat1, mat2, outm);
   rc = write_array( "&output_dataset.",outm) ;
quit;
proc datasets nolist; 
 delete temp1 temp2; 
quit;
%mend;


