class uart_rxd_parity_status_clear extends base_test;
  `uvm_component_utils(uart_rxd_parity_status_clear)

  ahb_rxd_write_parity_status_sequence  ahb_write;
  ahb_rxd_clear_parity_status_sequence  ahb_clear;
  uart_rxd_write_sequence               uart_write;
  
  int baud_rate_a[7] = '{2400, 4800, 9600, 19200, 38400, 76800, 115200};

  function new(string name = "uart_rxd_parity_status_clear", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    //Wait Reset signal
    #150ns;
    
    for(int pm = 1; pm < 3; pm++) begin
      for(int dw = 5; dw <= 8; dw++) begin
        for(int sb = 1; sb <= 2; sb++) begin
          for(int br = 0; br < 7; br++) begin
            for(int m = 0; m < 2; m++) begin
              bit [7:0] data;

              cfg.randomize() with {parity_mode       == pm;
                                    sampling          == m;
                                    data_width        == dw;
                                    num_of_stop_bit   == sb;
                                    baud_rate         == baud_rate_a[br];
                              };
              data = $random();

              cfg.parity_enable     = 1'b1;
              cfg.baud_rate_enable  = 1'b0;
              `uvm_info(get_type_name(), $sformatf("%s", cfg.sprint()), UVM_LOW)

              ahb_write     = ahb_rxd_write_parity_status_sequence::type_id::create("ahb_write", this);
              ahb_write.cfg = cfg;
              ahb_write.start(env.ahb_agt.sequencer);

              uart_write    = uart_rxd_write_sequence::type_id::create("uart_write", this);
              uart_write.wdata = data;
              uart_write.start(env.uart_agt.seq);

              ahb_clear     = ahb_rxd_clear_parity_status_sequence::type_id::create("ahb_clear", this);
              ahb_clear.cfg = cfg;
              ahb_clear.exp = data;
              ahb_clear.regmodel = env.regmodel;
              ahb_clear.start(env.ahb_agt.sequencer);
              #10ms;
            end
          end
        end
      end
    end
    phase.drop_objection(this);
  endtask

endclass
