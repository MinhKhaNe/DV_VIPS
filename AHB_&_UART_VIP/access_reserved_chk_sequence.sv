class access_reserved_chk_sequence extends uvm_sequence #(ahb_transaction);
  `uvm_object_utils(access_reserved_chk_sequence)

  function new(string name = "access_reserved_chk_sequence");
    super.new(name);
  endfunction

  virtual task body();
    bit [31:0] address;
    bit [31:0] wdata;
    bit [31:0] rdata;
    bit        hresp;

    for(int i = 0; i < 10; i++) begin

      address = 32'h020 + $urandom_range(0, 991);
      wdata   = $urandom();

      write_read(address, wdata, rdata, hresp);

      if((rdata != 32'hFFFF_FFFF) && (hresp != 1'b1)) begin
        `uvm_error("ACCESS RESERVED", $sformatf("\n===== FAILED!!! Actual data is %h, Expected data is %h =====",rdata,32'hFFFF_FFFF))
        `uvm_error("ACCESS RESERVED", $sformatf("\n===== FAILED!!! HRESP is not high, HRESP = %b =====", hresp))
      end
      else begin
        `uvm_info("ACCESS RESERVED", $sformatf("\n===== PASSED SUCCESSFULLY!!! ====="), UVM_LOW)
      end
    end
  endtask

  task write_read(bit [31:0] haddr, bit [31:0] hwdata,output bit [31:0] hrdata, output bit hresp);
    ahb_transaction req;
    ahb_transaction rsp;

   //FOR WRITE TRANSACTION

    //uvm_event       xfer_done_e;

    //if(!uvm_config_db#(uvm_event)::get(m_sequencer, "", "xfer_done", xfer_done_e)) begin
    //  `uvm_fatal("ACCESS RESERVED", "FAILED to get xfer_done event form driver")
    //end
  
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
