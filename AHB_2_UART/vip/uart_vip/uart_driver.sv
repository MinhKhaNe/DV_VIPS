class uart_driver extends uvm_driver #(uart_transaction);
  `uvm_component_utils(uart_driver)

  uvm_analysis_port #(uart_transaction) uart_a_port;

  virtual uart_if   uart_vif;
  uart_configuration  cfg;

  function new(string name = "uart_driver", uvm_component parent);
    super.new(name, parent);
    uart_a_port = new("uart_a_port", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(uart_configuration)::get(this, "", "cfg", cfg))
      `uvm_fatal(get_type_name(), $sformatf("FAILED to get UART_CONFIG from uvm_config_db"))

    if(!uvm_config_db#(virtual uart_if)::get(this, "", "uart_vif", uart_vif))
      `uvm_fatal(get_type_name(), $sformatf("FAILED to get UART_INTERFACE from uvm_config_db"))

  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get(req);
      //`uvm_info("uart_driver", $sformatf("DRIVER received transaction: %0s", req.sprint()), UVM_LOW)
      if(cfg.data_width != 8) begin 
        req.data &= ((1 << cfg.data_width) -1);
      end
     drive_uart(req);

      $cast(rsp, req.clone());
      rsp.set_id_info(req);
      seq_item_port.put(rsp);
      //`uvm_info("uart_driver", $sformatf("Transaction back to DRIVER: %0s", rsp.sprint()), UVM_LOW)
      
      //Drive Analysis Port to Scoreboard
      //req.data_frame  = cfg.data_width;
      uart_a_port.write(req);
    end
  endtask

  task drive_uart(uart_transaction trans);
    time clk;

    //TRANSFER TIMING CALCULATION
    clk = 1s / cfg.baud_rate;
    //case(cfg.baud_rate)
    //  2400:   clk = 416.667us;
    //  4800:   clk = 208.333us;
    //  9600:   clk = 104.167us;
    //  19200:  clk = 52.083us;
    //  38400:  clk = 26.042us;
    //  76800:  clk = 13.021us;
    //  115200: clk = 8.681us;
    //endcase
    //IDLE
    uart_vif.tx  <= 1'b1; 
    
    //START BIT
    uart_vif.tx  <= 1'b0;
    #(clk);

    //TRANSFER DATA
    for(int i = 0; i < cfg.data_width; i++) begin
      uart_vif.tx  <= trans.data[i];
      #(clk);
    end

    //PARITY BIT
    if(cfg.parity_mode != uart_configuration::UART_PARITY_NONE) begin
      if(!cfg.parity_enable) begin
        uart_vif.tx    <= parity_calculation(trans.data);
        //trans.parity  = parity_calculation(trans.data);
        #(clk);
      end
      else begin
        uart_vif.tx   <= inject_parity(trans.data);
        #(clk);
      end
    end

    //STOP BIT
    repeat(cfg.num_of_stop_bit) begin
     uart_vif.tx  <= 1'b1;
     // trans.stop_bit = trans.stop_bit + 1'b1;
      #(clk);
    end

  endtask

  function bit parity_calculation(bit [7:0] data);
    case(cfg.parity_mode)
      uart_configuration::UART_PARITY_NONE:   return 0 ;
      uart_configuration::UART_PARITY_EVEN:   return ^(data);
      uart_configuration::UART_PARITY_ODD:    return ~(^data);
    endcase
  endfunction

  function bit inject_parity(bit [7:0] data);
    case(cfg.parity_mode)
      uart_configuration::UART_PARITY_NONE:   return 1;
      uart_configuration::UART_PARITY_ODD:   return ^(data);
      uart_configuration::UART_PARITY_EVEN:    return ~(^data);
    endcase
  endfunction

endclass
