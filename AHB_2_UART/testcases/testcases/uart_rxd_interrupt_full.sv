class uart_rxd_interrupt_full extends base_test;
  `uvm_component_utils(uart_rxd_interrupt_full)

  ahb_rxd_rx_full_sequence       rx_full;
  uart_rxd_write_sequence        uart_write;
  ahb_rxd_rx_read_full_sequence  read_full;
  
  int baud_rate_a[7] = '{2400, 4800, 9600, 19200, 38400, 76800, 115200};

  function new(string name = "uart_rxd_interrupt_full", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    //Wait Reset signal
    
    for(int pm = 0; pm < 3; pm++) begin
      for(int dw = 5; dw <= 8; dw++) begin
        for(int sb = 1; sb <= 2; sb++) begin
          for(int br = 0; br < 7; br++) begin
            for(int m = 0; m < 2; m++) begin
              bit [7:0] data;

              ahb_vif.HRESETn = 1'b0;
              #100ns;
              ahb_vif.HRESETn = 1'b1;
              #50ns;

              cfg.randomize() with {parity_mode       == pm;
                                    sampling          == m;
                                    data_width        == dw;
                                    num_of_stop_bit   == sb;
                                    baud_rate         == baud_rate_a[br];
                              };
//              data = $urandom();

              cfg.parity_enable     = 1'b0;
              cfg.baud_rate_enable  = 1'b0;
              `uvm_info(get_type_name(), $sformatf("%s", cfg.sprint()), UVM_LOW)

              rx_full     = ahb_rxd_rx_full_sequence::type_id::create("rx_full", this);
              rx_full.cfg = cfg;
              rx_full.start(env.ahb_agt.sequencer);
             $display(" after rx full");
              for(int i = 0; i < 16; i++) begin
                data = $urandom();
                $display("before uart write %d",i);
                uart_write    = uart_rxd_write_sequence::type_id::create("uart_write", this);
                uart_write.wdata = data;
                uart_write.start(env.uart_agt.seq);
                $display("after uart write");
            end

              $display("before read");
              read_full     = ahb_rxd_rx_read_full_sequence::type_id::create("read_full", this);
              read_full.cfg = cfg;
              read_full.start(env.ahb_agt.sequencer);
              $display("after read");

              #10ms;
            end
          end
        end
      end
    end
    phase.drop_objection(this);
  endtask

endclass
