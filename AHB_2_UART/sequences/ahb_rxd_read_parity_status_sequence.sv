class ahb_rxd_read_parity_status_sequence extends uvm_sequence #(ahb_transaction);
  `uvm_object_utils(ahb_rxd_read_parity_status_sequence)

  uart_reg_block      regmodel;
  uvm_status_e        status;
  uvm_reg_data_t      data;

  uart_configuration  cfg;

  localparam  MDR = 10'h000;
  localparam  DLL = 10'h004;
  localparam  DLH = 10'h008;
  localparam  LCR = 10'h00C;
  localparam  IER = 10'h010;
  localparam  FSR = 10'h014;
  localparam  TBR = 10'h018;
  localparam  RBR = 10'h01C;

  bit [7:0] exp;

  function new(string name = "ahb_rxd_read_parity_status_sequence");
    super.new(name);
  endfunction

  virtual task body();
    //if(cfg == null)
    //  `uvm_fatal(get_type_name(), "CFG NULL")

    //if(regmodel == null)
    //  `uvm_fatal(get_type_name(), "REGMODEL NULL")

    bit [7:0] mask;
    mask = (1 << cfg.data_width) - 1;

    //Check RX FIFO Status
    do begin
      regmodel.FSR.read(status, data);
    end
    while(data[3] == 1'b1);

    if(data[3] != 1'b1) begin
      regmodel.FSR.read(status, data);
      if(data[4] != 1) begin
        `uvm_error(get_type_name(), $sformatf("\n===== FAILED!!! Parity Error Status is actived not right ====="))
      end
      else begin
        `uvm_info(get_type_name(), $sformatf("\n===== PASSED SUCCESSFULLY!!! ====="), UVM_LOW)
      end
    end
  endtask

  task read_ahb(bit [9:0] haddr, output bit [31:0] hrdata, output bit hresp);
    ahb_transaction req;
    ahb_transaction rsp;
 
    //FOR READ TRANSACTION
    req   = ahb_transaction::type_id::create("req");
    start_item(req);
    assert(req.randomize() with {
      addr        == haddr;
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
