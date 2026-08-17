class ahb_rxd_error_handling extends uvm_sequence #(ahb_transaction);
  `uvm_object_utils(ahb_rxd_error_handling)

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

  function new(string name = "ahb_rxd_error_handling");
    super.new(name);
  endfunction

  virtual task body();
    bit [31:0]  data;
    bit         hresp;
    //for(int i = 0; i < 3; i++) begin

      //READ RX_EMPTY_STATUS
//      read_ahb(FSR, data, hresp);
//      if(data[3] != 1) begin
//        `uvm_error(get_type_name(), $sformatf("\n===== FAILED!!! RX_EMPTY_STATUS is not right ====="))
//      end
      write_ahb(IER, 32'h06);

      
      read_ahb(FSR, data, hresp);
      
      if(data[3] == 1'b1) begin
        `uvm_info(get_type_name(), $sformatf("===== RX_EMPTY_STATUS is high, Start read value from RBR ====="), UVM_LOW)
      end
      read_ahb(RBR, data, hresp);
      `uvm_info(get_type_name(), $sformatf("===== Data read when RX is empty is : %h =====", data), UVM_LOW)
   
   //end
  endtask
  
  task write_ahb(bit [9:0] haddr, bit [31:0] hwdata);
    ahb_transaction req;
    //ahb_transaction rsp;

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
    //hrdata  = rsp.data;
    //hresp   = rsp.hresp;
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
