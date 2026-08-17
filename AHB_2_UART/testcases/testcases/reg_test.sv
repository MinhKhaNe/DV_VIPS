class reg_test extends base_test;
  `uvm_component_utils(reg_test)

  default_value_chk_sequence    def_seq;
  read_write_chk_sequence       rw_seq;
  uvm_reg_hw_reset_seq          reset_seq;
  access_reserved_chk_sequence  arc_seq;

  function new(string name = "reg_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    #150ns;

    def_seq   = default_value_chk_sequence::type_id::create("def_seq");
    def_seq.regmodel  = env.regmodel;
    def_seq.start(null);

    rw_seq    = read_write_chk_sequence::type_id::create("rw_seq");
    rw_seq.regmodel   = env.regmodel;
    rw_seq.start(null);

    `uvm_info("REG_TEST", "\n===== START RESET DUT =====", UVM_LOW)

    ahb_vif.HRESETn = 1'b0;
    #100ns;
    ahb_vif.HRESETn = 1'b1;
    #50ns;
    reset_seq = uvm_reg_hw_reset_seq::type_id::create("reset_seq");
    reset_seq.model = env.regmodel;
    reset_seq.start(null);

    arc_seq   = access_reserved_chk_sequence::type_id::create("arc_seq", this);
    arc_seq.start(env.ahb_agt.sequencer);

    phase.drop_objection(this);
  endtask
endclass
