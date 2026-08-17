package seq_pkg;
  import uvm_pkg::*;
  import uart_pkg::*;
  import ahb_pkg::*;
  import uart_regmodel_pkg::*;

  //TXD
  `include "default_value_chk_sequence.sv"
  `include "read_write_chk_sequence.sv"
  `include "access_reserved_chk_sequence.sv"
  `include "parity_x16_chk_sequence.sv"
  `include "data_frame_x16_chk_sequence.sv"
  `include "stop_bit_x16_chk_sequence.sv"
  `include "baud_rate_x16_chk_sequence.sv"
  `include "random_x16_chk_sequence.sv"
  `include "parity_x13_chk_sequence.sv"
  `include "data_frame_x13_chk_sequence.sv"
  `include "stop_bit_x13_chk_sequence.sv"
  `include "baud_rate_x13_chk_sequence.sv"
  `include "random_x13_chk_sequence.sv"
  //RXD
  `include "ahb_rxd_write_sequence.sv"
  `include "ahb_rxd_read_sequence.sv"
  `include "uart_rxd_write_sequence.sv"
  `include "ahb_rxd_write_parity_status_sequence.sv"
  `include "ahb_rxd_read_parity_status_sequence.sv"
  `include "ahb_rxd_clear_parity_status_sequence.sv"
  `include "ahb_rxd_rx_empty_sequence.sv"
  `include "ahb_rxd_rx_read_empty_sequence.sv"
  `include "ahb_txd_empty_sequence.sv"
  `include "ahb_txd_full_sequence.sv"
  `include "ahb_txd_read_full_sequence.sv"
  `include "ahb_rxd_rx_full_sequence.sv"
  `include "ahb_rxd_rx_read_full_sequence.sv"
  `include "ahb_txd_sequence.sv" 
  `include "ahb_txd_read_empty_sequence.sv"
  `include "ahb_rxd_error_handling.sv"
  `include "ahb_txd_error_handling.sv"
 
endpackage
