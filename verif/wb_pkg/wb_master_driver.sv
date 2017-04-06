/* ======================================================================
 *
 * Wishbone Master Driver Class (wb_master_driver)
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
 * Description      |  SystemVerilog class for Wishbone master driver. 
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

 class wb_master_driver extends uvm_driver #( wb_transaction , wb_transaction ) ;  
   // Virtual Wishbone bus interface 
   // To be assigned in the verification environment 
   virtual interface wb_interface wb_interface_i ; 

   // UVM utilities and automation macros
   `uvm_component_utils ( wb_master_driver ) 

   // Help functions and tasks
   virtual protected task drive_transaction ( wb_transaction trxn ) ; 
     // Initiate a read transaction 
     if ( trxn.wb_trxn_dir == WB_READ ) 
       wb_interface_i.wb_rd ( trxn.wb_trxn_adr , trxn.wb_trxn_sel , trxn.wb_trxn_dat ) ;
     // Initiate a write transaction 
     else if ( trxn.wb_trxn_dir == WB_WRITE ) 
       wb_interface_i.wb_wr ( trxn.wb_trxn_adr , trxn.wb_trxn_sel , trxn.wb_trxn_dat ) ;
   endtask : drive_transaction 

   // Constructor 
   function new ( string name = "wb_master_dirver" , uvm_component parent ) ; 
     super.new ( name , parent ) ; 
   endfunction : new 
   
   // Run phase 
   // TODO: Add support for reset handling 
   virtual task run_phase ( uvm_phase phase ) ; 
     forever begin 
       // Raise objection 
       phase.raise_objection ( this ) ;
       // Get the next sequence item from the sequencer 
       seq_item_port.get_next_item ( req ) ; 
       // Clone the request to response
       $cast ( rsp , req.clone ( ) ) ; 
       // Correspond the response to the request 
       rsp.set_id_info ( req ) ; 
       // The response is driven on to the bus and is modified according to
       // the slave's response  
       drive_transaction ( rsp ) ; 
       // Sequence item finished; send the response back to the sequencer
       seq_item_port.item_done ( rsp ) ;
       // Drop objection 
       phase.drop_objection ( this ) ;
     end // forever
   endtask : run_phase 

 endclass : wb_master_driver
