class uart_txd_x13_baud_rate extends base_test;
  `uvm_component_utils(uart_txd_x13_baud_rate)

  baud_rate_x13_chk_sequence   br_seq;
  
  int baud_rate_a[7] = '{2400, 4800, 9600, 19200, 38400, 76800, 115200};

  function new(string name = "uart_txd_x13_baud_rate", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    //Wait Reset signal
    #150ns;
    
    for(int i = 0; i < 7; i++) begin
      cfg.randomize() with {parity_mode       == uart_configuration::UART_PARITY_NONE;
                            sampling          == uart_configuration::MODE_X13;
                            data_width        == 5;
                            num_of_stop_bit   == 1;
                            baud_rate         == baud_rate_a[i];
                            //baud_rate_enable  == 1'b1;
                            //parity_enable     == 1'b0;
                            };

      cfg.parity_enable     = 1'b0;
      cfg.baud_rate_enable  = 1'b1;
      `uvm_info(get_type_name(), $sformatf("%s", cfg.sprint()), UVM_LOW)
      br_seq      = baud_rate_x13_chk_sequence::type_id::create("df_seq", this);
      br_seq.cfg  = cfg;
      br_seq.start(env.ahb_agt.sequencer);

      #10ms;
    end
    phase.drop_objection(this);
  endtask

endclass
