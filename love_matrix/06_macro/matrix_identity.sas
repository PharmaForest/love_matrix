/*** HELP START ***//*

Macro Name    : %matrix_identity

 Purpose       :
   Generate an identity matrix of a specified size using PROC FCMP.
   The macro creates an array, calls the IDENTITY routine, and writes
   the resulting matrix into a SAS dataset.

 Parameters    :
   size=            Dimension of the identity matrix (default = 5).
                    Must be a positive integer. The result will be size × size.
   output_dataset=  Output dataset name to store the identity matrix.
                    Default = WORK.OUTPUT_IDENTITY.

 Processing Flow:
   1. Define a square array of dimension size × size.
   2. Use CALL IDENTITY to populate the array with an identity matrix
      (1's on the diagonal, 0's elsewhere).
   3. Write the array into the specified output dataset.

 Requirements / Notes:
   - Requires PROC FCMP (no SAS/IML dependency).
   - The output dataset will contain variables col1, col2, ..., coln.
   - Very large values of SIZE may exceed available memory.

 Example Usage:
   %matrix_identity(size=3, output_dataset=work.id3);

   proc print data=work.id3;
   run;


*//*** HELP END ***/

%macro matrix_identity(size=5, output_dataset= output_identity );
proc fcmp;
  array col[&size,&size] /nosym;
   call identity(col);
   rc = write_array("&output_dataset", col ) ;
quit;
%mend;
