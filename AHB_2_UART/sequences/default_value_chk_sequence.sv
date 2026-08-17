class default_value_chk_sequence extends uvm_sequence #(ahb_transaction);
  `uvm_object_utils(default_value_chk_sequence)

  uart_reg_block  regmodel;
  uvm_status_e    status;
  uvm_reg_data_t  data;

  function new(string name = "default_value_chk_sequence");
    super.new(name);
  endfunction

  virtual task body();
    regmodel.MDR.read(status, data);
    if(data != 32'h0) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'h0, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end

    regmodel.DLL.read(status, data);
    if(data != 32'h0) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'h0, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end

    regmodel.DLH.read(status, data);
    if(data != 32'h0) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'h0, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end

    regmodel.LCR.read(status, data);
    if(data != 32'h03) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'h03, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end

    regmodel.IER.read(status, data);
    if(data != 32'h0) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'h0, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end

    regmodel.FSR.read(status, data);
    if(data != 32'h0A) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'h0A, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end

    regmodel.TBR.read(status, data);
    if(data != 32'h0) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'h0, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end

    regmodel.RBR.read(status, data);
    if(data != 32'hxx) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'h0xx, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end

  endtask

endclass
