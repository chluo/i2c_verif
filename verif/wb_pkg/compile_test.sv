/* ======================================================================
 *
 * This module is used to check if there are any compile errors in 
 * the Wishbone bus protocol package, i.e. wb_pkg. Under the directory 
 * ../sim, use the following commands to run the compile check. 
 * You need to use one of the ECE 64-bit machines and use Cadence 2015. 
 *
 * module load cadence 
 * irun +compile -incdir ../wb_pkg -incdir $UVM_HOME/uvm_lib/uvm_sv/uvm_src
 *      -uvm ../wb_pkg/compile_test.sv 
 *
 * ======================================================================
 * Author   Chunheng Luo
 * =================================================================== */

 // Include any modules or interfaces in wb_pkg here
 `include "wb_interface.sv"
 
 module compile_test ; 
   // Import the UVM package
   import uvm_pkg::* ; 

   // Include the UVM macros
   `include "uvm_macros.svh"

   // Include any classes in wb_pkg here
   `include "wb_transaction.sv"
   `include "wb_master_driver.sv"
   `include "wb_master_sequencer.sv"
   `include "wb_collector.sv"
   `include "wb_monitor.sv"

 endmodule : compile_test
