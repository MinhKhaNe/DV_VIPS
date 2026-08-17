class ahb_driver extends uvm_driver #(ahb_transaction);
  `uvm_component_utils(ahb_driver)

  virtual ahb_if ahb_vif;
  //uvm_event xfer_done_e;

  function new(string name="ahb_driver", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    /** Applying the virtual interface received through the config db - learn detail in next session*/
    if(!uvm_config_db#(virtual ahb_if)::get(null,"*","ahb_vif",ahb_vif))
      `uvm_fatal(get_type_name(),$sformatf("Failed to get from uvm_config_db. Please check!"))

    //xfer_done_e = new("xfer_done_e");
    //uvm_config_db#(uvm_event)::set(get_parent(), "*", "xfer_done", xfer_done_e);
  endfunction: build_phase

  /** User can use ahb_vif to control real interface like systemverilog part*/
  virtual task run_phase(uvm_phase phase);
    wait(ahb_vif.HRESETn);
    forever begin
      seq_item_port.get(req);
      //`uvm_info("driver",$sformatf("Driver received transaction: %0s",req.sprint()),UVM_LOW)
      #10ns;
      //xfer_done_e.reset();
      if(req.xact_type == ahb_transaction::WRITE) begin
        ahb_write(req);
        //`uvm_info("driver",$sformatf("Start drive value to AHB: %0s",req.sprint()),UVM_LOW)
      end
      else if(req.xact_type == ahb_transaction::READ) begin
        ahb_read(req);
        //`uvm_info("driver",$sformatf("Start read value of AHB: %0s",req.sprint()),UVM_LOW)
      end
      $cast(rsp, req.clone());
      rsp.set_id_info(req);
      seq_item_port.put(rsp);
      //`uvm_info("driver",$sformatf("Transaction drives back: %0s",rsp.sprint()),UVM_LOW)
    end 
  endtask: run_phase

  task ahb_write(ahb_transaction pkt);
    wait(ahb_vif.HREADYOUT);      
    @(posedge ahb_vif.HCLK);
    //address phase
    ahb_vif.HADDR   <= pkt.addr;
    ahb_vif.HWRITE  <= pkt.xact_type;
    ahb_vif.HBURST  <= pkt.burst_type;
    ahb_vif.HPROT   <= pkt.prot;
    ahb_vif.HTRANS  <= 2'b10;
    ahb_vif.HSIZE   <= pkt.xfer_size;
    ahb_vif.HWDATA  <= 32'h0;
    //ahb_vif.HRDATA  <= 32'h0; 
   
    //data phase
    @(posedge ahb_vif.HCLK);
    ahb_vif.HADDR   <= 10'h0;
    ahb_vif.HWRITE  <= 1'b0;
    ahb_vif.HBURST  <= 3'h0;
    ahb_vif.HPROT   <= 4'h0;
    ahb_vif.HTRANS  <= 2'h0;
    ahb_vif.HSIZE   <= 3'h0;
    ahb_vif.HWDATA  <= pkt.data;
    
    repeat(2) @(posedge ahb_vif.HCLK);
    //else begin
    //  `uvm_error(get_type_name(), $sformatf("===== HREADYOUT should be high ====="))
    //end
  endtask

  task ahb_read(ahb_transaction pkt);
    wait(ahb_vif.HREADYOUT);
    @(posedge ahb_vif.HCLK);
    //address phase
    ahb_vif.HADDR   <= pkt.addr;
    ahb_vif.HWRITE  <= pkt.xact_type;
    ahb_vif.HBURST  <= pkt.burst_type;
    ahb_vif.HPROT   <= pkt.prot;
    ahb_vif.HTRANS  <= 2'b10;
    ahb_vif.HSIZE   <= pkt.xfer_size;
    ahb_vif.HWDATA  <= 32'h0;  
    //ahb_vif.HRDATA  <= 32'h0;
    //data phase
    @(posedge ahb_vif.HCLK);
    ahb_vif.HADDR   <= 10'h0;
    ahb_vif.HWRITE  <= 1'b0;
    ahb_vif.HBURST  <= 3'h0;
    ahb_vif.HPROT   <= 4'h0;
    ahb_vif.HTRANS  <= 2'h0;
    ahb_vif.HSIZE   <= 3'h0;
    
    repeat(2) @(posedge ahb_vif.HCLK);
    //ahb_vif.HRDATA  <= pkt.data;
    #10;
    //->xfer_done_e;
    pkt.data        = ahb_vif.HRDATA;
    pkt.hresp       = ahb_vif.HRESP;
    
    //else begin
    //  `uvm_error(get_type_name(), $sformatf("===== HREADYOUT should be high ====="))
    //end
  endtask


endclass: ahb_driver

