/*** HELP START ***//*

Macro Name    : %matrix_determinant

 Purpose       :
   Compute the determinant of a square numeric matrix stored in a SAS dataset,
   using PROC FCMP and the CALL DET routine. Designed for environments
   without SAS/IML.

 Parameters    :
   dataset=         Input dataset representing the numeric matrix.
   output_dataset=  Output dataset to store the determinant as a 1×1 matrix.
                    Default = WORK.OUTPUT_DET


 Requirements / Notes:
   - Only numeric variables are considered; character variables are ignored.
   - The input dataset must represent a square matrix. Otherwise, the macro stops with an error.
   - If the matrix is singular or nearly singular, the determinant may be 0 or numerically unstable.
   - The output dataset will contain a single cell (col1) with the determinant value.

 Example Usage:
   data wk1;
     a=2; b=1; output;
     a=3; b=4; output;
   run;

   %matrix_determinant(dataset=wk1, output_dataset=work.det_wk1);

   proc print data=work.det_wk1;
   run;

*//*** HELP END ***/

%macro matrix_determinant(dataset=, output_dataset= output_det);
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
  %put ERROR: Matrix must be square to compute the determinant: rows=&_nobs1, cols=&_nvars1.;
  %return;
%end;

proc fcmp;
   array mat1[&_nobs1. , &_nvars1.] /nosym;
   array col[1 ,1] /nosym;
   rc = read_array("TEMP1", mat1) ;
   call det(mat1, result);
   put result=;
   col[1 ,1] =result;
   rc = write_array("&output_dataset.", col ) ;
quit;

proc datasets nolist; 
 delete temp1 ; 
quit;
%mend;
