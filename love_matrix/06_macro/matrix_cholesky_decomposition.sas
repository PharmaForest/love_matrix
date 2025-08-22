/*** HELP START ***//*

Macro Name    : %matrix_cholesky_decomposition

 Purpose       :
   Perform a Cholesky decomposition of a square numeric matrix stored in a SAS dataset.
   The macro computes the lower-triangular matrix L such that A = L*L',
   and also outputs its transpose (L').

 Parameters    :
   dataset=       Input dataset containing the numeric square matrix.
   output_L=      Output dataset for the lower-triangular matrix L.
                  Default = WORK.OUTPUT_L
   output_TL=     Output dataset for the transpose of L (L').
                  Default = WORK.OUTPUT_TL
 Requirements / Notes:
   - Only numeric variables are considered; character variables are ignored.
   - The input matrix must be symmetric and positive definite.
   - If the matrix is not positive definite, CALL CHOL will fail even with validation.
   - The output datasets will contain variables col1, col2, ..., coln.

Example Usage:
  data wk1;
    a=2; b=2; c=3; output;
    a=2; b=4; c=2; output;
    a=3; b=2; c=6; output;
  run;

  %matrix_cholesky_decomposition(dataset=wk1,
                                 output_L=work.Lmat,
                                 output_TL=work.LTmat);

*//*** HELP END ***/

%macro matrix_cholesky_decomposition(dataset=, output_L= output_L, output_TL= output_TL );
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
  %put ERROR: Matrix must be square for cholesky decomposition: rows=&_nobs1, cols=&_nvars1.;
  %return;
%end;

proc fcmp;
   array mat1[&_nobs1. , &_nvars1.] /nosym;
   array L[&_nobs1. , &_nvars1.] /nosym;
   rc = read_array("TEMP1", mat1) ;
   call chol(mat1, L, 1);
   array TL[&_nobs1. , &_nvars1.] / nosym;
    call transpose(L, TL);
   rc = write_array("&output_L", L ) ;
   rc = write_array("&output_TL", TL ) ;
quit;
proc datasets nolist; 
 delete temp1 ; 
quit;
%mend;
