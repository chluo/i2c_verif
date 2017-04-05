/* ======================================================================
 * 
 * Wishbone Transcation Class (uvm_sequence_item)  
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
 * Description      |  SystemVerilog class for Wishbone bus transactions, 
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

 typedef enum bit { WB_READ , WB_WRITE } wb_direction_enum ; 

 // TODO: Add support for pipelined bus transfers
 class wb_transaction
 #( 
   // Class parameters 
   parameter    BW_ADR        =   8                  , // Address bit width  
   parameter    BW_DAT        =   8                  , // Data bit width 
   parameter    GRANULARITY   =   8                    // Data granularity 
 ) extends uvm_sequence_item ; 

   // Local parameters 
   localparam   BW_SEL        = BW_DAT / GRANULARITY ;  // Bit width of wb_trxn_sel

   // Data members 
   rand bit [ BW_ADR - 1 : 0 ] wb_trxn_adr ;  // Address
   rand bit [ BW_DAT - 1 : 0 ] wb_trxn_dat ;  // Data (for either direction) 
   rand bit [ BW_SEL - 1 : 0 ] wb_trxn_sel ;  // Which slot the data is placed in
   rand wb_direction_enum      wb_trxn_dir ;  // Bus transaction direction 

   // Constraints 
   // wb_trxn_sel has to be one-hot
   constraint sel_valid_cstr { is_one_hot ( wb_trxn_sel ) == 1'b1 ; } 

   // Help functions
   // Check if wb_trxn_sel is one-hot
   function bit is_one_hot ( bit [ BW_SEL - 1 : 0 ] num ) ; 
     int num_of_ones = 0; 
     repeat ( BW_SEL ) begin 
       num_of_ones = num_of_ones + ( num & 1'b1 ) ; 
       num = num >> 1 ; 
     end // repeat
     return ( num_of_ones == 1 ) ; 
   endfunction : is_one_hot

   // UVM utilities and automation macros 
   `uvm_object_utils_begin ( wb_transaction ) 
     `uvm_field_int  ( wb_trxn_adr , UVM_DEFAULT ) 
     `uvm_field_int  ( wb_trxn_dat , UVM_DEFAULT )
     `uvm_field_int  ( wb_trxn_sel , UVM_DEFAULT )
     `uvm_field_enum ( wb_direction_enum , wb_trxn_dir , UVM_DEFAULT ) 
   `uvm_object_utils_end 

   // Constructor 
   function new ( string name = "wb_transaction" ) ; 
     super.new ( name ) ; 
   endfunction : new 
 endclass : wb_transaction
