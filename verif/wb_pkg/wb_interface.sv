/* ======================================================================
 *
 * Wishbone Bus Interface
 *
 * ======================================================================
 * Basic Information
 * ----------------------------------------------------------------------
 * Author           |  Chunheng Luo
 * ----------------------------------------------------------------------
 * Email Address    |  ChunhengLuo@outlook.com
 * ----------------------------------------------------------------------
 * Date of Creation |  04-04-2017    
 * ----------------------------------------------------------------------
 * Description      |  SystemVerilog interface for Wishbone bus protocol. 
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

 interface wb_interface 
 #( 
   parameter   bw_adr         =   8         , // Address bit width 
   parameter   bw_dat         =   8         , // Data bit width  
   parameter   granularity    =   8           // Data granularity, e.g. 8-bit granularity for a byte-addressable system 
 )( 
   input       logic          wb_clk        , // Bus clock 
   input       logic          wb_rst        , // Synchronous reset, active high 
   input       logic          wb_arst_n       // Asynchronous reset, active low
   /* Note: Asynchronous reset is not included in the original Wishbone
    *       protocol, but is used in many open-source Wishbone-compliant
    *       modules. So added here for convenience. */
 ); 

   //
   // Local parameters
   // 
   localparam bw_sel = bw_dat / granularity ; // Bit width of the wb_sel signal

   //
   // Internal signals
   //
   logic  [ bw_adr - 1 : 0 ]  wb_adr        ; // Address
   logic  [ bw_dat - 1 : 0 ]  wb_dat_w      ; // Data to be written to slaves
   logic  [ bw_dat - 1 : 0 ]  wb_dat_r      ; // Data read from slaves 
   logic  [ bw_sel - 1 : 0 ]  wb_sel        ; // Slave select 
   logic                      wb_we         ; // Write enable, active high 
   logic                      wb_ack        ; // Acknowledge signal given by slaves
   logic                      wb_stb        ; // Strobe signal, indicating a in-progress data transfer 
   logic                      wb_cyc        ; // Cycle signal, indicating a valid bus cycle 
   logic                      wb_tagn_w     ; // User defined from-master-to-slave tag 
   logic                      wb_tagn_r     ; // User defined from-slave-to-master tag

   //
   // Module ports
   //
   // Wishbone master
   modport wb_master (
     input   wb_dat_r , wb_ack , wb_tagn_r , wb_clk , wb_rst , wb_arst_n , 
     output  wb_adr , wb_dat_w , wb_we , wb_sel , wb_stb , wb_cyc , wb_tagn_w 
   ) ; 

   // Wishbone slave
   modport wb_slave (
     input   wb_adr , wb_dat_w , wb_we , wb_sel , wb_stb , wb_cyc , wb_tagn_w , wb_clk , wb_rst , wb_arst_n , 
     output  wb_dat_r , wb_ack , wb_tagn_r 
   ) ; 

   // 
   // Wishbone master transactions
   // TODO: Add support for pipelined bus transfers
   //
   // Bus read
   task wb_rd ( 
     input  logic [ bw_adr - 1 : 0 ] rd_adr , 
     input  logic [ bw_sel - 1 : 0 ] rd_sel , 
     output logic [ bw_dat - 1 : 0 ] rd_dat 
   ) ;
     // Block until the bus is free 
     wait ( !wb_cyc && !wb_stb ) ; 

     @ ( posedge wb_clk ) begin 
       wb_adr <= rd_adr   ; 
       wb_sel <= rd_sel   ; 
       wb_we  <= 1'b0     ; 
       wb_cyc <= 1'b1     ; 
       wb_stb <= 1'b1     ; 
     end 

     // Block until the ack is received
     @ ( posedge wb_ack ) 
       rd_dat <= wb_dat_r ; 
     @ ( posedge wb_clk ) begin 
       wb_cyc <= 1'b0     ; 
       wb_stb <= 1'b0     ;
     end 
   endtask : wb_rd

   // Bus write 
   task wb_wr ( 
     input  logic [ bw_adr - 1 : 0 ] wr_adr     , 
     input  logic [ bw_dat - 1 : 0 ] wr_dat     , 
     input  logic [ bw_sel - 1 : 0 ] wr_sel     , 
     input  logic                    wr_tagn_w    
   ) ;
     // Block until the bus is free 
     wait ( !wb_cyc && !wb_stb ) ; 

     @ ( posedge wb_clk ) begin 
       wb_adr    <= wr_adr    ; 
       wb_dat_w  <= wr_dat    ; 
       wb_sel    <= wr_sel    ; 
       wb_we     <= 1'b1      ; 
       wb_cyc    <= 1'b1      ; 
       wb_stb    <= 1'b1      ;
       wb_tagn_w <= wr_tagn_w ; 
     end 

     // Block until the ack is received
     @ ( posedge wb_ack ) ; 
     @ ( posedge wb_clk ) begin 
       wb_we     <= 1'b0      ; 
       wb_cyc    <= 1'b0      ; 
       wb_stb    <= 1'b0      ;
     end 
   endtask : wb_wr 

 endinterface : wb_interface 
