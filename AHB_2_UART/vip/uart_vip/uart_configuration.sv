class uart_configuration extends uvm_object;
  //`uvm_object_utils(uart_configuration)
  
  typedef enum {
    UART_PARITY_NONE,
    UART_PARITY_ODD,
    UART_PARITY_EVEN
  } parity_mode_e;

  typedef enum {
    MODE_X16,
    MODE_X13
  } sampling_mode_e;

  randc   parity_mode_e   parity_mode;
  randc   sampling_mode_e sampling;
  randc   int   unsigned  data_width;
  randc   int   unsigned  num_of_stop_bit;
  randc   int   unsigned  baud_rate;

  bit     baud_rate_enable;
  bit     parity_enable;
  bit     interrupt_enable;

  constraint uart_config {
    baud_rate         inside   {2400, 4800, 9600, 19200, 38400, 76800, 115200};
    data_width        inside   {5, 6, 7, 8};
    num_of_stop_bit   inside   {1, 2};
  }

  `uvm_object_utils_begin(uart_configuration)
    `uvm_field_enum(parity_mode_e, parity_mode, UVM_ALL_ON | UVM_HEX)
    `uvm_field_enum(sampling_mode_e, sampling,  UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(data_width,                  UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(num_of_stop_bit,             UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(baud_rate,                   UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(baud_rate_enable,            UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(parity_enable,               UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(interrupt_enable,            UVM_ALL_ON | UVM_HEX)
  `uvm_object_utils_end

  function new(string name = "uart_configuration");
    super.new(name);
    //Default value
    //parity_mode     = UART_PARITY_NONE;
    //data_width      = 8;
    //num_of_stop_bit = 1;
    //baud_rate       = 115200;
    //baud_rate_enable = 0;
    //parity_enable   = 0;
  endfunction

endclass
