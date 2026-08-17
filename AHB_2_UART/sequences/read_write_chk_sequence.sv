class read_write_chk_sequence extends uvm_sequence #(ahb_transaction);
  `uvm_object_utils(read_write_chk_sequence)

  uart_reg_block  regmodel;
  uvm_status_e    status;
  uvm_reg_data_t  data;

  function new(string name = "read_write_chk_sequence");
    super.new(name);
  endfunction

  virtual task body();
    regmodel.MDR.write(status, 32'h01);
    regmodel.MDR.read(status, data);
    if(data != 32'h01) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'h01, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end
 
    regmodel.DLL.write(status, 32'hFF);
    regmodel.DLL.read(status, data);
    if(data != 32'hFF) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'hFF, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end

    regmodel.DLH.write(status, 32'hFF);
    regmodel.DLH.read(status, data);
    if(data != 32'hFF) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'hFF, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end
 
    regmodel.LCR.write(status, 32'h3F);
    regmodel.LCR.read(status, data);
    if(data != 32'h3F) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'h3F, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end

    regmodel.IER.write(status, 32'h1F);
    regmodel.IER.read(status, data);
    if(data != 32'h1F) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'h1F, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end
 
    regmodel.FSR.write(status, 32'hFF);
    regmodel.FSR.read(status, data);
    if(data != 32'h0A) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'h0A, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end

    regmodel.TBR.write(status, 32'hFF);
    regmodel.TBR.read(status, data);
    if(data != 32'h00) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'h00, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end
 
    regmodel.RBR.write(status, 32'hFF);
    regmodel.RBR.read(status, data);
    if(data != 32'hxx) begin
      `uvm_error("RAL", $sformatf("\n===== FAILED!!! Expected data = %h, Actual data = %h =====", 32'hxx, data))
    end
    else begin
      `uvm_info("RAL", "\n===== PASSED SUCCESSFULLY!!!! =====", UVM_LOW)
    end

  endtask

endclass
