class stop_bit_x13_chk_sequence extends uvm_sequence;
  `uvm_object_utils(stop_bit_x13_chk_sequence)

  ahb_transaction     ahb_trans;
  uart_transaction    uart_trans;
  uart_configuration  cfg;

  localparam  MDR = 10'h000;
  localparam  DLL = 10'h004;
  localparam  DLH = 10'h008;
  localparam  LCR = 10'h00C;
  localparam  IER = 10'h010;
  localparam  FSR = 10'h014;
  localparam  TBR = 10'h018;
  localparam  RBR = 10'h01C;

  //bit [31:0] lcr_value[3] = '{32'h20, 32'h21, 32'h22, 32'h23};

  function new(string name = "stop_bit_x13_chk_sequence");
    super.new(name);
  endfunction

  virtual task body();
    bit [31:0] wdata;

    //for(int i = 0; i < 3; i++) begin
      wdata   = $urandom();

      //Settings DUT
      write_ahb(MDR, 32'h01);
      write_ahb(DLL, 32'h43);
      write_ahb(DLH, 32'h00);
      if(cfg.num_of_stop_bit == 2) begin
        write_ahb(LCR, 32'h24);
      end
      else begin
        write_ahb(LCR, 32'h20);
      end
      write_ahb(TBR, wdata);
    //end
  endtask

  task write_ahb(bit [9:0] haddr, bit [31:0] hwdata);
    ahb_transaction req;
 
    //FOR WRITE TRANSACTION
    req   = ahb_transaction::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {
      addr        == haddr;
      data        == hwdata;
      xact_type   == ahb_transaction::WRITE;
      xfer_size   == ahb_transaction::SIZE_32BIT; //WORD
      burst_type  == ahb_transaction::SINGLE;
    });
    finish_item(req);
    get_response(rsp);
 endtask

  task read_uart();

  endtask

endclass
