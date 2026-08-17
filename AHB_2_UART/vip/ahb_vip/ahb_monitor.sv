class ahb_monitor extends uvm_monitor;
  `uvm_component_utils(ahb_monitor)

  virtual   ahb_if  ahb_vif;

  uvm_analysis_port #(ahb_transaction) a_port;

  function new(string name="ahb_monitor", uvm_component parent);
    super.new(name,parent);
    a_port  = new("a_port",this);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif))
      `uvm_fatal(get_type_name(),$sformatf("FAILED to get ahb_vif from uvm_config_db"))

  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    ahb_transaction ahb_trans;

    forever begin
      @(posedge ahb_vif.HCLK);
      if(ahb_vif.HTRANS[1]) begin
        ahb_trans = new("ahb_trans");

        ahb_trans.addr        = ahb_vif.HADDR;
        ahb_trans.xact_type   = ahb_transaction::xact_type_enum'(ahb_vif.HWRITE);
        ahb_trans.burst_type  = ahb_transaction::burst_type_enum'(ahb_vif.HBURST);
        ahb_trans.xfer_size   = ahb_transaction::xfer_size_enum'(ahb_vif.HSIZE);
        ahb_trans.prot        = ahb_vif.HPROT;
        ahb_trans.lock        = ahb_vif.HMASTLOCK;
        ahb_trans.hresp       = ahb_vif.HRESP;

        @(posedge ahb_vif.HCLK);
        if(ahb_trans.xact_type) begin
          ahb_trans.data      = ahb_vif.HWDATA;
        end
        else begin
          repeat(2) @(posedge ahb_vif.HCLK);
          ahb_trans.data      = ahb_vif.HRDATA;
        end
        //`uvm_info("ahb_monitor", $sformatf("Data read from DUT is %0s", ahb_trans.sprint()), UVM_LOW)

        a_port.write(ahb_trans);
      end
    end
  endtask: run_phase

endclass: ahb_monitor

