/* ======================================================================
 *
 * Wishbone Master Agent Class (wb_master_agent)
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
 * Description      |  SystemVerilog class for Wishbone master agent. 
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

 class wb_master_agent extends uvm_agent ; 
   // Active/passive mode
   // Active by default 
   bit is_active = 1'b1 ; 

   // Child components 
   wb_master_driver    wb_master_driver_i    ; 
   wb_master_sequencer wb_master_sequencer_i ; 
   wb_collector        wb_collector_i        ; 
   wb_monitor          wb_monitor_i          ; 

   // Analysis port for sending the collected transactions out of the agent 
   uvm_analysis_port #( wb_transaction ) agent_aport ; 

   // UVM utilities and automation macros
   `uvm_component_utils_begin ( wb_master_agent ) 
     `uvm_field_int ( is_active , UVM_DEFAULT ) 
   `uvm_component_utils_end 

   // Constructor 
   function new ( string name = "wb_master_agent" , uvm_component parent ) ;
     super.new ( name , parent ) ; 
     agent_aport = new ( "agent_aport" , this ) ;
   endfunction : new 

   // Build phase 
   virtual function void build_phase ( uvm_phase phase ) ; 
     if ( is_active ) begin 
       wb_master_driver_i    = wb_master_driver   ::type_id::create ( "wb_master_driver_i"    , this ) ;
       wb_master_sequencer_i = wb_master_sequencer::type_id::create ( "wb_master_sequencer_i" , this ) ;
     end // if
     wb_collector_i = wb_collector ::type_id::create ( "wb_collector_i" , this ) ;
     wb_monitor_i   = wb_monitor   ::type_id::create ( "wb_monitor_i"   , this ) ;
   endfunction : build_phase

   // Connect phase 
   virtual function void connect_phase ( uvm_phase phase ) ; 
     // Connect driver with sequencer
     if ( is_active ) 
       wb_master_driver_i.seq_item_port.connect ( wb_master_sequencer_i.seq_item_export ) ; 
     // Connect collector with monitor 
     wb_collector_i.collector_aport.connect ( wb_monitor_i.collector_axport ) ; 
     // Connect the monitor's output analysis port to the top-level env 
     wb_monitor_i.monitor_aport.connect ( agent_aport ) ; 
   endfunction : connect_phase

 endclass : wb_master_agent 

