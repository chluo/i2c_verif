/* ======================================================================
 *
 * Wishbone Monitor Class (uvm_monitor)
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
 * Description      |  SystemVerilog class for Wishbone monitor. 
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

 class wb_monitor extends uvm_monitor ; 
   // Flags used to enable basic protocol checks and coverage analysis 
   // Enabled by default 
   bit checks_enable  = 1'b1 ; 
   bit coverge_enable = 1'b1 ; 

   // Transaction sent from the collector 
   wb_transaction trxn_collected ; 

   // Export connected to the collector 
   uvm_analysis_imp  #( wb_transaction , wb_monitor ) collector_axport ; 

   // Analysis port for sending transactions out to the top level env 
   uvm_analysis_port #( wb_transaction ) monitor_aport ; 

   // UVM utilities and automation macros 
   `uvm_component_utils ( wb_monitor ) 

   // Coverage groups (empty)
   covergroup wb_monitor_cg ; 
   endgroup : wb_monitor_cg 

   // Constructor 
   function new ( string name = "wb_monitor" , uvm_component parent ) ; 
     super.new ( name , parent ) ; 
     wb_monitor_cg    = new ( ) ;
     collector_axport = new ( "collector_axport" , this ) ; 
     monitor_aport    = new ( "monitor_aport", this ) ; 
   endfunction : new 

   // Help functions 
   // Perform basic bus protocol checks
   virtual function void perform_checks ( ) ; 
     // Forms a data string for the collected transaction 
     string trxn_string ; 
     // Checks whether the direction is either read or write 
     if ( trxn_collected.wb_trxn_dir == WB_READ ) 
       trxn_string = $formatf (
         "Read from %h; Got data %h. Select array: %h" , 
         trxn_collected.wb_trxn_adr , 
         trxn_collected.wb_trxn_dat , 
         trxn_collected.wb_trxn_sel 
       ) ; 
     else if ( trxn_collected.wb_trxn_dir == WB_WRITE ) 
       trxn_string = $formatf (
         "Wrote %h to %h. Select array: %h" , 
         trxn_collected.wb_trxn_dat , 
         trxn_collected.wb_trxn_adr , 
         trxn_collected.wb_trxn_sel 
       ) ; 
     else 
       `uvm_error ( "WB_MONITOR" , "Invalid bus transfer direction" ) 
   endfunction : perform_checks 

   // Perform coverage analysis 
   virtual function void perform_coverage ( ) ; 
     wb_monitor_cg.sample ( ) ; 
   endfunction : perform_coverage 

   // Implement the export retreiving transaction items from the collector 
   virtual function void write ( wb_transaction trxn_received ) ; 
     trxn_collected = trxn_received ; 
     if ( checks_enable  ) perform_checks   ( ) ;
     if ( coverge_enable ) perform_coverage ( ) ; 
   endfunction : write 

 endclass : wb_monitor 

