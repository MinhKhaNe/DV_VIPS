class uart_txd_x13_random extends base_test;
  `uvm_component_utils(uart_txd_x13_random)

  random_x13_chk_sequence   random_seq;
  
  int baud_rate_a[7] = '{2400, 4800, 9600, 19200, 38400, 76800, 115200};

  function new(string name = "uart_txd_x13_random", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    //Wait Reset signal
    #150ns;
    
    for(int pm = 0; pm < 3; pm++) begin
      for(int dw = 5; dw <= 8; dw++) begin
        for(int sb = 1; sb <= 2; sb++) begin
          for(int br = 0; br < 7; br++) begin
      
            cfg.randomize() with {parity_mode       == pm;
                                  sampling          == uart_configuration::MODE_X13;
                                  data_width        == dw;
                                  num_of_stop_bit   == sb;
                                  baud_rate         == baud_rate_a[br];
                            };

            cfg.parity_enable     = 1'b0;
            cfg.baud_rate_enable  = 1'b0;
            `uvm_info(get_type_name(), $sformatf("%s", cfg.sprint()), UVM_LOW)
            random_seq      = random_x13_chk_sequence::type_id::create("random_seq", this);
            random_seq.cfg  = cfg;
            random_seq.start(env.ahb_agt.sequencer);

            #10ms;
          end
        end
      end
    end
    phase.drop_objection(this);
  endtask

endclass
