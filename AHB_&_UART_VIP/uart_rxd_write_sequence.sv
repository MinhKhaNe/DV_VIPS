class uart_rxd_write_sequence extends uvm_sequence #(uart_transaction);
  `uvm_object_utils(uart_rxd_write_sequence)

  uart_configuration  cfg;

  localparam  MDR = 10'h000;
  localparam  DLL = 10'h004;
  localparam  DLH = 10'h008;
  localparam  LCR = 10'h00C;
  localparam  IER = 10'h010;
  localparam  FSR = 10'h014;
  localparam  TBR = 10'h018;
  localparam  RBR = 10'h01C;

  bit [31:0] wdata;

  function new(string name = "uart_rxd_write_sequence");
    super.new(name);
  endfunction

  virtual task body();
     //Write UART TRANSACTION
      write_uart(wdata);
  endtask
 
  task write_uart(bit [31:0] wdata);
    uart_transaction req;

    req   = uart_transaction::type_id::create("req");
    start_item(req);

    req.direction = uart_transaction::TX;
    req.data      = wdata;
      
    finish_item(req);
    get_response(rsp);     
  endtask  

endclass
