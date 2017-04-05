/* ======================================================================
 *
 * Wishbone Master Sequencer Class (uvm_sequencer)
 *
 * ======================================================================
 * Basic Information
 * ----------------------------------------------------------------------
 * Author           |  Chunheng Luo
 * ----------------------------------------------------------------------
 * Email Address    |  ChunhengLuo@outlook.com
 * ----------------------------------------------------------------------
 * Date of Creation |  04-05-2017    
 * ----------------------------------------------------------------------
 * Description      |  SystemVerilog class for Wishbone master sequencer. 
 *                  |  Designed for functional verification of Wishbone-
 *                  |  compliant modules. 
 * ======================================================================
 * Revision History
 * ----------------------------------------------------------------------
 * Date of Revision |  Revision Description 
 * ----------------------------------------------------------------------
 *                  |
 * ----------------------------------------------------------------------
 *                  |
 * =================================================================== */

 class wb_master_sequencer extends uvm_sequencer #( wb_transaction , wb_transaction ) ; 
   // UVM automation macro for sequencers 
   `uvm_sequencer_utils ( wb_master_sequencer ) 

   // Constructor 
   function new ( string name = "wb_master_sequencer" , uvm_component parent ) ; 
     super.new ( name , parent ) ; 
     `uvm_update_sequence_lib_and_item ( wb_transaction )  
   endfunction : new 
 endclass : wb_master_sequencer 
