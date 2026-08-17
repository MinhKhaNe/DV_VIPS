class ahb_txd_empty_sequence extends uvm_sequence #(ahb_transaction);
  `uvm_object_utils(ahb_txd_empty_sequence)

  uart_configuration   cfg;

  localparam  MDR = 10'h000;
  localparam  DLL = 10'h004;
  localparam  DLH = 10'h008;
  localparam  LCR = 10'h00C;
  localparam  IER = 10'h010;
  localparam  FSR = 10'h014;
  localparam  TBR = 10'h018;
  localparam  RBR = 10'h01C;

  bit [31:0] lcr;

  bit [31:0] data;

  function new(string name = "ahb_txd_empty_sequence");
    super.new(name);
  endfunction

  virtual task body();
    bit [31:0]  data;
    bit         hresp;
    //for(int i = 0; i < 17; i++) begin
     data = $urandom();

      //Settings DUT
      //Setting Sampling MODE
      if(cfg.sampling == uart_configuration::MODE_X16) begin
        write_ahb(MDR, 32'h00);
      end
      else begin
        write_ahb(MDR, 32'h01);
      end

      //Setting BAUD RATE
      if(cfg.sampling == uart_configuration::MODE_X16) begin
        case(cfg.baud_rate)
          2400: begin
            write_ahb(DLL, 32'h2C);
            write_ahb(DLH, 32'h0A);
          end
          4800: begin
            write_ahb(DLL, 32'h16);
            write_ahb(DLH, 32'h05);
          end
          9600: begin
            write_ahb(DLL, 32'h8B);
            write_ahb(DLH, 32'h02);
          end
          19200: begin
            write_ahb(DLL, 32'h45);
            write_ahb(DLH, 32'h01);
          end
          38400: begin
           write_ahb(DLL, 32'hA3);
           write_ahb(DLH, 32'h00);
          end
          76800: begin
            write_ahb(DLL, 32'h51);
            write_ahb(DLH, 32'h00);
          end
          115200: begin
            write_ahb(DLL, 32'h36);
            write_ahb(DLH, 32'h00);
          end
        endcase
      end
      else begin
        case(cfg.baud_rate)
          2400: begin
            write_ahb(DLL, 32'h85);
            write_ahb(DLH, 32'h0C);
          end
          4800: begin
            write_ahb(DLL, 32'h42);
            write_ahb(DLH, 32'h06);
          end
          9600: begin
            write_ahb(DLL, 32'h21);
            write_ahb(DLH, 32'h03);
          end
          19200: begin
            write_ahb(DLL, 32'h91);
            write_ahb(DLH, 32'h01);
          end
          38400: begin
            write_ahb(DLL, 32'hC8);
            write_ahb(DLH, 32'h00);
          end
          76800: begin
            write_ahb(DLL, 32'h64);
            write_ahb(DLH, 32'h00);
          end
          115200: begin
            write_ahb(DLL, 32'h43);
            write_ahb(DLH, 32'h00);
          end
 
        endcase
      end

      //BGE
      lcr[5] = 1'b1;

      //EPS, PEN
      case(cfg.parity_mode)
        uart_configuration::UART_PARITY_NONE: lcr[4:3] = 2'b00;
        uart_configuration::UART_PARITY_ODD:  lcr[4:3] = 2'b01;
        uart_configuration::UART_PARITY_EVEN: lcr[4:3] = 2'b11;
      endcase
    
      //STB
      lcr[2] = (cfg.num_of_stop_bit == 2);

      //WLS
      case(cfg.data_width)
        8: lcr[1:0] = 2'b11;
        7: lcr[1:0] = 2'b10;
        6: lcr[1:0] = 2'b01;
        5: lcr[1:0] = 2'b00;
      endcase
      write_ahb(LCR, lcr);
      
      //TX_EMTPY_FULL_ENABLE
      write_ahb(IER, 32'h02);

      write_ahb(TBR, data);
      //READ RX_EMPTY_STATUS
//      read_ahb(FSR, data, hresp);
//      if(data[3] != 1) begin
//        `uvm_error(get_type_name(), $sformatf("\n===== FAILED!!! RX_EMPTY_STATUS is not right ====="))
//      end
//      do begin
//        read_ahb(FSR, data, hresp);
//      end
//      while(data[3] == 1'b1);
      
//   end
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

  task read_ahb(bit [9:0] haddr, output bit [31:0] hrdata, output bit hresp);
    ahb_transaction req;
    ahb_transaction rsp;

    //FOR WRITE TRANSACTION
    req   = ahb_transaction::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {
      addr        == haddr;
      //data        == hwdata;
      xact_type   == ahb_transaction::READ;
      xfer_size   == ahb_transaction::SIZE_32BIT; //WORD
      burst_type  == ahb_transaction::SINGLE;
    });
    finish_item(req);
    get_response(rsp);
    hrdata  = rsp.data;
    hresp   = rsp.hresp;
  endtask

 endclass
