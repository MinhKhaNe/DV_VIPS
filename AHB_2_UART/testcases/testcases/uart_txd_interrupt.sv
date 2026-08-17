class uart_txd_interrupt extends base_test;
  `uvm_component_utils(uart_txd_interrupt)

  ahb_txd_sequence            tx_write;
  ahb_txd_full_sequence       tx_full;
  ahb_txd_empty_sequence      tx_empty;
  ahb_txd_read_full_sequence  read_full;
  ahb_txd_read_empty_sequence read_empty;  

  int baud_rate_a[7] = '{2400, 4800, 9600, 19200, 38400, 76800, 115200};

  function new(string name = "uart_txd_interrupt", uvm_component parent);
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
              //data = $urandom();

              cfg.parity_enable     = 1'b0;
              cfg.baud_rate_enable  = 1'b0;
              `uvm_info(get_type_name(), $sformatf("%s", cfg.sprint()), UVM_LOW)
  
              for(int i = 0; i < 1; i++) begin
                //data = $urandom();
                tx_empty     = ahb_txd_empty_sequence::type_id::create("tx_empty", this);
                tx_empty.cfg = cfg;
                //tx_write.data = data;
                tx_empty.start(env.ahb_agt.sequencer);
                //#100ns;
              end

              //read_empty     = ahb_txd_read_empty_sequence::type_id::create("read_empty", this);
              //read_empty.cfg = cfg;
              //read_empty.start(env.ahb_agt.sequencer);
           
              for(int i = 0; i < 15; i++) begin
                //data = $urandom();
                tx_write     = ahb_txd_sequence::type_id::create("tx_write", this);
                tx_write.cfg = cfg;
                //tx_write.data = data;
                tx_write.start(env.ahb_agt.sequencer);
                //#100ns;
              end

              tx_full     = ahb_txd_full_sequence::type_id::create("tx_full", this);
              tx_full.cfg = cfg;
              //tx_write.data = data;
              tx_full.start(env.ahb_agt.sequencer);
                            
              read_full     = ahb_txd_read_full_sequence::type_id::create("read_full", this);
              read_full.cfg = cfg;
              read_full.start(env.ahb_agt.sequencer);

              #10ms;
            end
          end
        end
      end
    end
    phase.drop_objection(this);
  endtask

endclass
