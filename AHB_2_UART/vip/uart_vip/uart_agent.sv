class uart_agent extends uvm_agent;
  `uvm_component_utils(uart_agent)

  uart_monitor    mon;
  uart_driver     drv;
  uart_sequencer  seq;

  virtual   uart_if   uart_vif;
  uart_configuration  cfg;

  function new(string name = "uart_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(uart_configuration)::get(this, "", "cfg", cfg))
      `uvm_fatal(get_type_name(), $sformatf("FAILED to get UART_CONFIG from uvm_config_db"))

     if(!uvm_config_db #(virtual uart_if)::get(this, "", "uart_vif", uart_vif))
      `uvm_fatal(get_type_name(), $sformatf("FAILED to get UART_INTERFACE from uvm_config_db"))

    if(is_active == UVM_ACTIVE) begin
      `uvm_info(get_type_name(), $sformatf("Active agent is configured"), UVM_LOW)

      drv   = uart_driver::type_id::create("driver", this);
      mon   = uart_monitor::type_id::create("monitor", this);
      seq   = uart_sequencer::type_id::create("sequencer", this);

      uvm_config_db#(uart_configuration)::set(this, "driver", "cfg", cfg);
      uvm_config_db#(uart_configuration)::set(this, "monitor", "cfg", cfg);

      uvm_config_db#(virtual uart_if)::set(this, "driver", "uart_vif", uart_vif);
      uvm_config_db#(virtual uart_if)::set(this, "monitor", "uart_vif", uart_vif);
    end
    else begin
      `uvm_info(get_type_name(), $sformatf("Passive agent is configured"), UVM_LOW)

      mon   = uart_monitor::type_id::create("monitor", this);

      uvm_config_db#(uart_configuration)::set(this, "monitor", "cfg", cfg);
      uvm_config_db#(virtual uart_if)::set(this, "monitor", "uart_vif", uart_vif);
    end

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seq.seq_item_export);
    end
  endfunction

endclass
