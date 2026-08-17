class random_x16_chk_sequence extends uvm_sequence;
  `uvm_object_utils(random_x16_chk_sequence)

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

  bit [31:0] lcr;

  function new(string name = "random_x16_chk_sequence");
    super.new(name);
  endfunction

  virtual task body();
    bit [31:0] wdata;

    //for(int i = 0; i < 3; i++) begin
      wdata   = $urandom();

      //Settings DUT
      write_ahb(MDR, 32'h00);
      if(cfg.baud_rate == 2400) begin
        write_ahb(DLL, 32'h2C);
        write_ahb(DLH, 32'h0A);
      end
      else if(cfg.baud_rate == 4800) begin
        write_ahb(DLL, 32'h16);
        write_ahb(DLH, 32'h05);
      end
      else if(cfg.baud_rate == 9600) begin
        write_ahb(DLL, 32'h8B);
        write_ahb(DLH, 32'h02);
      end
      else if(cfg.baud_rate == 19200) begin
        write_ahb(DLL, 32'h45);
        write_ahb(DLH, 32'h01);
      end 
      else if(cfg.baud_rate == 38400) begin
        write_ahb(DLL, 32'hA4);
        write_ahb(DLH, 32'h00);
      end
      else if(cfg.baud_rate == 76800) begin
        write_ahb(DLL, 32'h51);
        write_ahb(DLH, 32'h00);
      end
      else begin
        write_ahb(DLL, 32'h36);
        write_ahb(DLH, 32'h00);
      end
      
      //BGE
      lcr[5] = 1'b1;

      //EPS, PEN
      case(cfg.parity_mode)
        uart_configuration::UART_PARITY_NONE: lcr[4:3]  = 2'b00;
        uart_configuration::UART_PARITY_ODD:  lcr[4:3]  = 2'b01;
        uart_configuration::UART_PARITY_EVEN: lcr[4:3]  = 2'b11;
      endcase

      //STB
      lcr[2] = (cfg.num_of_stop_bit == 2);

      //WLS
      case(cfg.data_width)
        8:  lcr[1:0] = 2'b11;
        7:  lcr[1:0] = 2'b10;
        6:  lcr[1:0] = 2'b01;
        5:  lcr[1:0] = 2'b00;
      endcase
      write_ahb(LCR, lcr);

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
