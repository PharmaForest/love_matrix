/*** HELP START ***//*

Macro Name    : %matrix_inverse

Purpose       :
  Compute the inverse of a square numeric matrix stored in a SAS dataset,
  using PROC FCMP and the CALL INV routine. Designed for environments
  without SAS/IML.

Parameters    :
  dataset=         Input dataset containing the numeric matrix to be inverted.
  output_dataset=  Output dataset that will contain the inverse matrix.
                   Default = WORK.OUTPUT_INV

Requirements / Notes:
  - Only numeric variables are considered; character variables are dropped.
  - The input dataset must represent a square matrix (same number of rows and columns).
  - If the matrix is singular or nearly singular, CALL INV will fail or return
    unstable results. No pseudo-inverse is computed in this macro.
  - The output dataset will contain variables named col1, col2, ..., col3.

Example Usage:
  data wk1;
    a=3; b=5; c=0; output;
    a=9; b=1; c=2; output;
    a=8; b=7; c=9; output;
  run;

  %matrix_inverse(dataset=wk1, output_dataset=inv_wk1);

*//*** HELP END ***/

%macro matrix_inverse(dataset=, output_dataset= output_inv );
data temp1;
set &dataset.;
keep _numeric_;
run;

proc sql noprint; 
  select count(*) into:_nobs1 trimmed from temp1;
  select count(*) into:_nvars1 trimmed from dictionary.columns 
  where libname='WORK' and memname="TEMP1"; 
quit;

%if %eval(&_nobs1) ne %eval(&_nvars1) %then %do;
  %put ERROR: Matrix must be square to compute an inverse: rows=&_nobs1, cols=&_nvars1.;
  %return;
%end;

proc fcmp;
   array mat1[&_nobs1.,&_nvars1.] /nosym;
   array col[&_nobs1.,&_nvars1.] /nosym;
   rc = read_array("TEMP1", mat1) ;
   call inv(mat1,col);
   rc = write_array("&output_dataset.", col ) ;
quit;
proc datasets nolist; 
 delete temp1 ; 
quit;
%mend;
