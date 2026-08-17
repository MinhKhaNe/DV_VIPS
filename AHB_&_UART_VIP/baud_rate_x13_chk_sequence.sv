class baud_rate_x13_chk_sequence extends uvm_sequence;
  `uvm_object_utils(baud_rate_x13_chk_sequence)

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

  function new(string name = "baud_rate_x13_chk_sequence");
    super.new(name);
  endfunction

  virtual task body();
    bit [31:0] wdata;

    //for(int i = 0; i < 3; i++) begin
      wdata   = $urandom();

      //Settings DUT
      write_ahb(MDR, 32'h01);
      if(cfg.baud_rate == 2400) begin
        write_ahb(DLL, 32'h85);
        write_ahb(DLH, 32'h0C);
      end
      else if(cfg.baud_rate == 4800) begin
        write_ahb(DLL, 32'h42);
        write_ahb(DLH, 32'h06);
      end
      else if(cfg.baud_rate == 9600) begin
        write_ahb(DLL, 32'h21);
        write_ahb(DLH, 32'h03);
      end
      else if(cfg.baud_rate == 19200) begin
        write_ahb(DLL, 32'h91);
        write_ahb(DLH, 32'h01);
      end 
      else if(cfg.baud_rate == 38400) begin
        write_ahb(DLL, 32'hC8);
        write_ahb(DLH, 32'h00);
      end
      else if(cfg.baud_rate == 76800) begin
        write_ahb(DLL, 32'h64);
        write_ahb(DLH, 32'h00);
      end
      else begin
        write_ahb(DLL, 32'h43);
        write_ahb(DLH, 32'h00);
      end

      write_ahb(LCR, 32'h20);
      write_ahb(TBR, 8'b1111_1111);
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
