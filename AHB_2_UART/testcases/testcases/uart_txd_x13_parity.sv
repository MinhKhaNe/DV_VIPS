class uart_txd_x13_parity extends base_test;
  `uvm_component_utils(uart_txd_x13_parity)

  parity_x13_chk_sequence   parity_seq;

  function new(string name = "uart_txd_x13_parity", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    //Wait Reset signal
    #150ns;
    
    for(int i = 0; i < 3; i++) begin
      cfg.randomize() with {parity_mode       == i;
                            sampling          == uart_configuration::MODE_X13;
                            data_width        == 5;
                            num_of_stop_bit   == 1;
                            baud_rate         == 115200;
                            //baud_rate_enable  == 1'b0;
                            //parity_enable     == 1'b0;
                            };
      cfg.baud_rate_enable = 1'b0;
      cfg.parity_enable = 1'b0;
      parity_seq      = parity_x13_chk_sequence::type_id::create("parity_seq", this);
      parity_seq.cfg  = cfg;
      parity_seq.start(env.ahb_agt.sequencer);

      #420us;
    end
    phase.drop_objection(this);
  endtask

endclass
