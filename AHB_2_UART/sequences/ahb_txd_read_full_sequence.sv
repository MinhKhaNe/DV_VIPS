class ahb_txd_read_full_sequence extends uvm_sequence #(ahb_transaction);
  `uvm_object_utils(ahb_txd_read_full_sequence)

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

  function new(string name = "ahb_txd_read_full_sequence");
    super.new(name);
  endfunction

  virtual task body();
    bit [31:0]  data;
    bit         hresp;
    //for(int i = 0; i < 17; i++) begin
      //data = $urandom();

      //Settings DUT
      //Setting Sampling MODE
      //READ RX_EMPTY_STATUS
      //if(i == 1) begin
      //  read_ahb(FSR, data, hresp);
      //  if(data[1] == 1) begin
      //    `uvm_error(get_type_name(), $sformatf("\n===== FAILED!!! RX_EMPTY_STATUS is not right ====="))
      //  end
      //end    

      //WRITE TXD VALUE
      //write_ahb(TBR, data);
      
      //if(i == 16) begin
      //READ RX_EMPTY_STATUS
        do begin
          read_ahb(FSR, data, hresp);
        end
        while(data[0] == 1'b0);
        if(data[0] == 1'b1) begin
          `uvm_info(get_type_name(), $sformatf("\n===== PASSED SUCCESSFULLY!!! TX FULL Status is high ====="), UVM_LOW)
        end
      //end
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
