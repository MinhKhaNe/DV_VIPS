class dut_environment extends uvm_env;
  `uvm_component_utils(dut_environment)

  virtual   ahb_if      ahb_vif;
  virtual   uart_if     uart_vif;
  uart_agent            uart_agt;
  ahb_agent             ahb_agt;
  uart_reg_block        regmodel;
  uart_reg2ahb_adapter  ahb_adapter;
  uart_configuration    cfg;
  dut_scoreboard        dut_sb;

  uvm_reg_predictor #(ahb_transaction) ahb_predictor;

  function new(string name = "dut_environment", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif))
      `uvm_fatal(get_type_name(), $sformatf("FAILED to get ahb_vif from uvm_config_db"))

    if(!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif))
      `uvm_fatal(get_type_name(), $sformatf("FAILED to get uart_vif from uvm_config_db"))

    if(!uvm_config_db#(uart_configuration)::get(this, "", "cfg", cfg))
      `uvm_fatal(get_type_name(), $sformatf("FAILED to get uart_config from uvm_config_db"))

    //cfg             = uart_configuration::type_id::create("cfg", this);
    dut_sb          = dut_scoreboard::type_id::create("dut_sb", this); 

    ahb_agt         = ahb_agent::type_id::create("ahb_agt", this);
    uart_agt        = uart_agent::type_id::create("uart_agt", this);

    ahb_predictor   = uvm_reg_predictor#(ahb_transaction)::type_id::create("ahb_predictor", this);
    regmodel        = uart_reg_block::type_id::create("regmodel", this);
    regmodel.build();
    ahb_adapter     = uart_reg2ahb_adapter::type_id::create("ahb_adapter", this);

    uvm_config_db#(virtual ahb_if)::set(this, "ahb_agt", "ahb_vif", ahb_vif); 
    uvm_config_db#(virtual uart_if)::set(this, "uart_agt", "uart_vif", uart_vif);
    uvm_config_db#(uart_configuration)::set(this, "uart_agt", "cfg", cfg);
    uvm_config_db#(uart_configuration)::set(this, "dut_sb", "cfg", cfg);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //Connect uart_monitor to Scoreboard
    uart_agt.mon.uart_a_port.connect(dut_sb.uart_a_export);
    uart_agt.mon.interrupt_a_port.connect(dut_sb.interrupt_a_export);
 
    //Connect RAL
    if(regmodel.get_parent() == null)
      regmodel.ahb_map.set_sequencer(ahb_agt.sequencer, ahb_adapter);

    //Predictor connection
    ahb_predictor.map     = regmodel.ahb_map;
    ahb_predictor.adapter = ahb_adapter;
    ahb_agt.monitor.a_port.connect(ahb_predictor.bus_in);

    //Connect ahb_monitor to Scoreboard
    ahb_agt.monitor.a_port.connect(dut_sb.ahb_a_export);
  endfunction
endclass
