/*** HELP START ***//*

Macro Name    : %matrix_transpose

 Purpose       :
   Transpose a numeric matrix stored in a SAS dataset using PROC FCMP.
   The macro reads numeric variables into an array, transposes the matrix,
   and writes the result to an output dataset.

 Parameters    :
   dataset=         Input dataset containing numeric variables to be transposed.
   output_dataset=  Output dataset name to store the transposed matrix.
                    Default = WORK.OUTPUT_TRAN

 Requirements / Notes:
   - Only numeric variables are considered; character variables are ignored.
   - The output dataset will contain variables named col1, col2, ..., coln.

 Example Usage:
   data wk1;
     a=3; b=5; output;
     a=0; b=9; output;
     a=1; b=2; output;
   run;

   %matrix_transpose(dataset=wk1, output_dataset=tran_wk1);

*//*** HELP END ***/

%macro matrix_transpose(dataset=, output_dataset= output_tran );
data temp1;
set &dataset.;
keep _numeric_;
run;

proc sql noprint; 
  select count(*) into:_nobs1 trimmed from temp1;
  select count(*) into:_nvars1 trimmed from dictionary.columns 
  where libname='WORK' and memname="TEMP1"; 
quit;

proc fcmp;
   array mat1[&_nobs1.,&_nvars1.] /nosym;
   array col[&_nvars1.,&_nobs1.] /nosym;
   rc = read_array("TEMP1", mat1) ;
   call transpose(mat1,col);
   rc = write_array("&output_dataset.", col ) ;
quit;
proc datasets nolist; 
 delete temp1 ; 
quit;
%mend;

