class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  dut_environment     env;
  uart_configuration  cfg;
  virtual   uart_if   uart_vif;
  virtual   ahb_if    ahb_vif;

  uvm_report_server   svr;
  uart_reg_block      regmodel;

  time   usr_timeout = 20s;
  function new(string name = "base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    cfg   = uart_configuration::type_id::create("cfg", this);

    if(!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif))
      `uvm_fatal(get_type_name(), $sformatf("FAILED to get uart_if from uvm_config_db"))

    if(!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif))
      `uvm_fatal(get_type_name(), $sformatf("FAILED to get ahb_if from uvm_config_db"))

    uvm_config_db#(uart_configuration)::set(this, "*", "cfg", cfg);
    uvm_config_db#(virtual uart_if)::set(this, "*", "uart_vif", uart_vif);
    uvm_config_db#(virtual ahb_if)::set(this, "*", "ahb_vif", ahb_vif);

    env   = dut_environment::type_id::create("env", this);

    uvm_top.set_timeout(usr_timeout);
  endfunction

  virtual function void start_of_simulation_phase(uvm_phase phase);

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    this.regmodel = env.regmodel;
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    svr = uvm_report_server::get_server();
    if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)) begin
      `uvm_info(get_type_name(), "-----------------------------------", UVM_NONE)
      `uvm_info(get_type_name(), "---         FAILED!!!           ---", UVM_NONE)
      `uvm_info(get_type_name(), "-----------------------------------", UVM_NONE)
    end
    else begin
      `uvm_info(get_type_name(), "-----------------------------------", UVM_NONE)
      `uvm_info(get_type_name(), "---   PASSED SUCCESSFULLY!!!    ---", UVM_NONE)
      `uvm_info(get_type_name(), "-----------------------------------", UVM_NONE) 
    end
  endfunction
endclass
