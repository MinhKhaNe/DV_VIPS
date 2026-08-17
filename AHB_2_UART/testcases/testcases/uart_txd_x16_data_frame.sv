class uart_txd_x16_data_frame extends base_test;
  `uvm_component_utils(uart_txd_x16_data_frame)

  data_frame_x16_chk_sequence   df_seq;

  function new(string name = "uart_txd_x16_data_frame", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    //Wait Reset signal
    #150ns;
    
    for(int i = 5; i < 9; i++) begin
      cfg.randomize() with {parity_mode       == uart_configuration::UART_PARITY_NONE;
                            sampling          == uart_configuration::MODE_X16;
                            data_width        == i;
                            num_of_stop_bit   == 1;
                            baud_rate         == 115200;
                            baud_rate_enable  == 1'b0;
                            parity_enable     == 1'b0;
                            };
          
      cfg.baud_rate_enable = 1'b0;
      cfg.parity_enable = 1'b0;

      df_seq      = data_frame_x16_chk_sequence::type_id::create("df_seq", this);
      df_seq.cfg  = cfg;
      df_seq.start(env.ahb_agt.sequencer);

      #420us;
    end
    phase.drop_objection(this);
  endtask

endclass
