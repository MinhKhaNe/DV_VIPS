class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)

  virtual uart_if   uart_vif;

  uart_configuration  cfg;
  
  uvm_analysis_port #(uart_transaction) uart_a_port;
  uvm_analysis_port #(interrupt_transaction) interrupt_a_port;

  covergroup  UART_CFG_GROUP;
    parity_mode: coverpoint cfg.parity_mode{
      bins  NONE  = {uart_configuration::UART_PARITY_NONE};
      bins  ODD   = {uart_configuration::UART_PARITY_ODD};
      bins  EVEN  = {uart_configuration::UART_PARITY_EVEN};
    }

    baud_rate: coverpoint cfg.baud_rate{
      bins  baud_2400 = {2400};
      bins  baud_4800 = {4800};
      bins  baud_9600 = {9600};
      bins  baud_19200 = {19200};
      bins  baud_57600 = {57600};
      bins  baud_115200 = {115200};
    }

    stop_bit: coverpoint cfg.num_of_stop_bit{
      bins  num_1   = {1};
      bins  num_2   = {2};
    }

    data_width: coverpoint cfg.data_width{
      bins  width_5 = {5};
      bins  width_6 = {6};
      bins  width_7 = {7};
      bins  width_8 = {8};
    }

    cross_parity_baudrate_stopbit_datawidth : cross parity_mode , baud_rate , stop_bit , data_width;
  endgroup

  function new(string name = "uart_monitor", uvm_component parent);
    super.new(name, parent);
    uart_a_port       = new("uart_a_port", this);
    interrupt_a_port  = new("interrupt_a_port", this);
    UART_CFG_GROUP    = new();
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(uart_configuration)::get(this, "", "cfg", cfg))
      `uvm_fatal(get_type_name(), $sformatf("FAILED to get UART_CONFIG from uvm_config_db"))
  
    if(!uvm_config_db #(virtual uart_if)::get(this, "", "uart_vif", uart_vif))
      `uvm_fatal(get_type_name(), $sformatf("FAILED to get UART_INTERFACE from uvm_config_db"))
  
  endfunction

  virtual task run_phase(uvm_phase phase);
    
    time period;

      fork    
  
        forever begin
          tx_monitor();
          UART_CFG_GROUP.sample();

        end
        
        forever begin
          rx_monitor();
          UART_CFG_GROUP.sample();
      
        end

        forever begin
          check_baud_rate();
          UART_CFG_GROUP.sample();
        end
        
        forever begin 
         // wait(cfg.interrupt_enable)
            interrupt_monitor();
        end
      join        
          
  endtask

  virtual task check_baud_rate();
      time T1, T2, period;
      forever begin
        wait(cfg.baud_rate_enable == 1'b1);

        @(negedge uart_vif.rx);
        T1 = $realtime;
        period = 1s/cfg.baud_rate;
        @(posedge uart_vif.rx);
        T2 = $realtime;

        `uvm_info(get_type_name(), $sformatf("\n===== Baud rate actual is %d, Baud rate expected is %d =====",(1s / (T2-T1)), cfg.baud_rate ), UVM_LOW)
       
        cfg.baud_rate_enable = 1'b0;

      end
  endtask

  virtual task tx_monitor();
          uart_transaction  trans;
          time period;
          trans   = uart_transaction::type_id::create("trans");
      
          //trans.data_frame = cfg.data_width;
          //having start bi
          @(negedge uart_vif.tx);

          period = 1s / (cfg.baud_rate);
 
          #(period/2.00);

          //data
          for(int i = 0; i < cfg.data_width; i++) begin
            #(period);
            trans.data[i] =  uart_vif.tx;
          end
          //parity
          if(cfg.parity_mode != uart_configuration::UART_PARITY_NONE) begin
            #(period);
            trans.parity  = uart_vif.tx;
          end
          //stop bit
          repeat (cfg.num_of_stop_bit) begin
            #(period);
            if(uart_vif.tx != 1'b1) begin
              `uvm_error(get_type_name(), "===== stop bit error detected =====")
            end
            else begin
              trans.stop_bit = uart_vif.tx;
            end
          end
          trans.direction = uart_transaction::TX;
          trans.baud_rate = cfg.baud_rate;
          //`uvm_info("uart_monitor", $sformatf("Data read from DUT is %0s", trans.sprint()), UVM_LOW)
          uart_a_port.write(trans);
  endtask


  virtual task rx_monitor();
          uart_transaction trans;
          time period;
          trans   = uart_transaction::type_id::create("trans");
      
          //trans.data_frame = cfg.data_width;
          //having start bi
          @(negedge uart_vif.rx);
         
          period = 1s / (cfg.baud_rate);
          
          #(period/2.00);

          //data
          for(int i = 0; i < cfg.data_width; i++) begin
            #(period);
            trans.data[i] =  uart_vif.rx;
          end
          //parity
          if(cfg.parity_mode != uart_configuration::UART_PARITY_NONE) begin
            #(period);
            trans.parity  = uart_vif.rx;
          end
          //stop bit
          repeat (cfg.num_of_stop_bit) begin
            #(period);
            if(uart_vif.rx != 1'b1) begin
           //   `uvm_error(get_type_name(), "===== stop bit error detected =====")
            end
            else begin
              trans.stop_bit = uart_vif.rx;
            end
          end
          trans.direction = uart_transaction::RX;
          trans.baud_rate = cfg.baud_rate;
          //`uvm_info("uart_monitor", $sformatf("Data read from DUT is %0s", trans.sprint()), UVM_LOW)
          uart_a_port.write(trans);
  endtask

  virtual task interrupt_monitor();
    interrupt_transaction   trans;
    $display("===== ENTER MONITOR =====");
    forever begin
      @(posedge uart_vif.interrupt);
      $display("===== POSITIVE INTERRUPT DETECTED =====");
      trans           = interrupt_transaction::type_id::create("trans");
      trans.interrupt = 1'b1;
      trans.int_time  = $time;
      interrupt_a_port.write(trans);

      @(negedge uart_vif.interrupt);
      $display("===== NEGEDGE INTERRUPT DETECTED =====");
      trans           = interrupt_transaction::type_id::create("trans");
      trans.interrupt = 1'b0;
      trans.int_time  = $time;
      interrupt_a_port.write(trans);

    end
  endtask
endclass
