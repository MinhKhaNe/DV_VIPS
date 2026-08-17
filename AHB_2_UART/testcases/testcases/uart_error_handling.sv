class uart_error_handling extends base_test;
  `uvm_component_utils(uart_error_handling)

  ahb_txd_sequence            tx_write;
  ahb_txd_full_sequence       tx_full;
  ahb_rxd_error_handling      rxd_error;
  ahb_txd_read_full_sequence  read_full;  
  ahb_txd_error_handling      txd_error;

  int baud_rate_a[7] = '{2400, 4800, 9600, 19200, 38400, 76800, 115200};

  function new(string name = "uart_error_handling", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    //Wait Reset signal
    
    for(int i = 0; i  < 1; i++) begin
      cfg.randomize() with{ parity_mode       == uart_configuration::UART_PARITY_NONE;  
                            sampling          == uart_configuration::MODE_X16;
                            num_of_stop_bit   == 1;
                            data_width        == 5;
                            baud_rate         == 115200;
                          };

    cfg.baud_rate_enable  = 1'b0;
    cfg.parity_enable     = 1'b0;
    
    rxd_error     = ahb_rxd_error_handling::type_id::create("rxd_error", this);
    rxd_error.cfg = cfg;
    rxd_error.start(env.ahb_agt.sequencer);

    for(int i = 0; i < 16; i++) begin
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

    $display("\n===== Data written after TXD full is 32'hFFFF_FFFF ====");
    //Write after full
    txd_error     = ahb_txd_error_handling::type_id::create("txd_error", this);
    txd_error.cfg = cfg;
    txd_error.data = 32'hFFFF_FFFF;
    txd_error.start(env.ahb_agt.sequencer);
    
    #10ms;
    end
    phase.drop_objection(this);
  endtask

endclass
