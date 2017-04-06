/* ======================================================================
 *
 * Wishbone Collector Class (uvm_component)
 *
 * ======================================================================
 * Basic Information
 * ----------------------------------------------------------------------
 * Author           |  Chunheng Luo
 * ----------------------------------------------------------------------
 * Email Address    |  ChunhengLuo@outlook.com
 * ----------------------------------------------------------------------
 * Date of Creation |  04-06-2017    
 * ----------------------------------------------------------------------
 * Description      |  SystemVerilog class for Wishbone collector. 
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

 class wb_collector extends uvm_component ; 
   // Virtual Wishbone bus interface 
   // To be assigned in the verification environment 
   virtual interface wb_interface wb_interface_i ; 

   // Analysis port for sending transactions to the monitor 
   // To be connected in the Wishbone master agent 
   uvm_analysis_port #( wb_transaction ) collector_aport ; 

   // UVM utilities and automation macros
   `uvm_component_utils ( wb_collector ) 

   // Constructor 
   function new ( string name = "wb_collector" , uvm_component parent ) ; 
     super.new ( name , parent ) ; 
     // Creat the analysis port 
     // Note: TLM ports are UVM components 
     collector_aport = new ( "collector_aport" , this ) ; 
   endfunction : new 

   // Run phase 
   virtual task run_phase ( uvm_phase phase ) ; 
     // Collected Wishbone transaction object 
     wb_transaction trxn_collected = new ( "trxn_collected" ) ; 
     // Repeatedly collect transaction information from the interface 
     forever begin : trxn_collection 
       // Wait for the master raise the strobe and cycle signals 
       wait ( wb_interface_i.wb_stb && wb_interface_i.wb_cyc ) ; 
       // Raise the objection here, making sure the collection is finished
       // once it is started
       phase.raise_objection ( this ) ; 
       // Sample the transaction information at the next clock event 
       @ ( posedge wb_interface_i.wb_clk ) begin 
         // Sample the address and the sel signal
         trxn_collected.wb_trxn_adr = wb_interface_i.wb_adr ; 
         trxn_collected.wb_trxn_sel = wb_interface_i.wb_sel ; 
         // If it is a write transaction, sample the data now 
         if ( wb_interface_i.wb_we ) begin 
           trxn_collected.wb_trxn_dir = WB_WRITE ; 
           trxn_collected.wb_trxn_dat = wb_interface_i.wb_dat_w ; 
           // Wait until the ack signal is received; (TODO) May block forever if the
           // slave never responses
           wait ( wb_interface_i.wb_ack ) ; 
         end // if
         // If it is a read transaction, wait for the ack signal and sample
         // the data
         else begin // ! wb_interface_i.wb_we 
           trxn_collected.wb_trxn_dir = WB_READ ; 
           wait ( wb_interface_i.wb_ack ) ; 
           @ ( posedge wb_interface_i.wb_clk ) 
             trxn_collected.wb_trxn_dat = wb_interface_i.wb_dat_r ; 
         end // else 
       end // @
       // Send the collected transaction to the monitor thru the analysis port 
       collector_aport.write ( trxn_collected ) ; 
       // Drop objection
       phase.drop_objection ( this ) ; 
     end : trxn_collection // forever
   endtask : run_phase 
 endclass : wb_collector 
