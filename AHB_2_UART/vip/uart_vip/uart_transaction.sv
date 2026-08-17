class uart_transaction extends uvm_sequence_item;

  //`uvm_object_utils(uart_transaction)

  typedef enum {
    TX,
    RX
  } direction_e;

  rand  bit   [8:0]     data;
        bit             parity;
        bit   [1:0]     stop_bit;
        int   unsigned  baud_rate;
  direction_e  direction;

  constraint baud_rate_c {
    baud_rate inside {2400, 4800, 9600, 19200, 38400, 7600, 115200};
  }

  `uvm_object_utils_begin (uart_transaction)
    `uvm_field_enum   (direction_e, direction,  UVM_ALL_ON | UVM_HEX)
    `uvm_field_int    (data,                    UVM_ALL_ON | UVM_HEX)
    `uvm_field_int    (parity,                  UVM_ALL_ON | UVM_HEX)
    `uvm_field_int    (stop_bit,                UVM_ALL_ON | UVM_HEX)
    `uvm_field_int    (baud_rate,               UVM_ALL_ON | UVM_HEX)
  `uvm_object_utils_end

  function new(string name = "uart_transaction");
    super.new(name);
  endfunction

endclass
