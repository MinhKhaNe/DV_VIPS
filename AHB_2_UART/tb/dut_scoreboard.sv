`uvm_analysis_imp_decl(_ahb)
`uvm_analysis_imp_decl(_uart)
`uvm_analysis_imp_decl(_interrupt)

class dut_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(dut_scoreboard)

  uvm_analysis_imp_ahb        #(ahb_transaction, dut_scoreboard) ahb_a_export;
  uvm_analysis_imp_uart       #(uart_transaction, dut_scoreboard) uart_a_export;
  uvm_analysis_imp_interrupt  #(interrupt_transaction, dut_scoreboard) interrupt_a_export;

  uart_configuration  cfg;

  uart_transaction    expected_txd_q[$];
  uart_transaction    actual_txd_q[$];

  int         data_width;
  int         stop_bit;
  bit [1:0]   parity_mode;
  bit         check_interrupt_empty, check_interrupt_full;
  bit [31:0]  int_status;
  bit         osm_sel;
  bit [7:0]   dll;
  bit [7:0]   dlh;
  bit         bge, eps, pen, stb;
  bit [1:0]   wls;
  bit         en_parity_error, en_rx_fifo_empty, en_rx_fifo_full, en_tx_fifo_empty, en_tx_fifo_full;
  bit         parity_error_status, rx_empty_status, rx_full_Status, tx_empty_status, tx_full_status;
  bit [7:0]   tx_data;
  bit [7:0]   rx_data;
  bit [9:0]   address;
  bit [31:0]  ier_value, fsr_value, write_data, lcr;
  bit         dll_valid, dlh_valid;

  covergroup UART_CFG_GROUP;
    AHB_ADDRESS: coverpoint address{
      bins MDR = {10'h000};
      bins DLL = {10'h004};
      bins DLH = {10'h008};
      bins LCR = {10'h00C};
      bins IER = {10'h010};
      bins FSR = {10'h014};
      bins TBR = {10'h018};
      bins RBR = {10'h01C};

      bins RESERVED = {[10'h020: 10'h3FF]};
    }  

    //MODE_SAMPLING: coverpoint write_data[1] iff (address == 10'h000){
    MODE_SAMPLING: coverpoint osm_sel{
      bins MODE_X16 = {1'b0};
      bins MODE_X13 = {1'b1};
    }

    //WRITE_DATA: coverpoint write_data;
  
    //WRITE_ADDRESS: cross AHB_ADDRESS, WRITE_DATA;

    DATA_FRAME: coverpoint lcr[1:0] iff (address == 10'h00C){
      bins WIDTH_5 = {2'b00};
      bins WIDTH_6 = {2'b01};
      bins WIDTH_7 = {2'b10};
      bins WIDTH_8 = {2'b11};
    }

    STOP_BIT: coverpoint lcr[2] iff (address == 10'h00C){
      bins BIT_1 = {1'b0};
      bins BIT_2 = {1'b1};
    }

    PARITY_MODE: coverpoint lcr[4] iff (address == 10'h00C){
      bins EVEN = {1'b1};
      bins ODD  = {1'b0};
    }

    PARITY_ENABLE: coverpoint lcr[3] iff (address == 10'h00C){
      bins PARITY_NONE    = {1'b0};
      bins PARITY_ENABLE  = {1'b1};
    }

    BAUD_RATE_ENABLE: coverpoint lcr[5] iff (address == 10'h00C){
      bins BAUD_RATE_ENABLE = {1'b1};
    }

    //DLL: coverpoint write_data[7:0] iff (address == 10'h004){
    DLL: coverpoint dll{  
      bins DLL_X16_115200 = {8'h36};
      bins DLL_X13_115200 = {8'h43};
      bins DLL_X16_76800  = {8'h51};
      bins DLL_X13_76800  = {8'h64};
      bins DLL_X16_38400  = {8'hA3};
      bins DLL_X13_38400  = {8'hC8};
      bins DLL_X16_19200  = {8'h45};
      bins DLL_X13_19200  = {8'h91};
      bins DLL_X16_9600   = {8'h8B};
      bins DLL_X13_9600   = {8'h21};
      bins DLL_X16_4800   = {8'h16};
      bins DLL_X13_4800   = {8'h42};
      bins DLL_X16_2400   = {8'h2C};
      bins DLL_X13_2400   = {8'h85};
    }

    //DLH: coverpoint write_data[7:0] iff (address == 10'h008){
    DLH: coverpoint dlh{  
      bins DLH_X16_115200 = {8'h00};
      bins DLH_X13_115200 = {8'h00};
      bins DLH_X16_76800  = {8'h00};
      bins DLH_X13_76800  = {8'h00};
      bins DLH_X16_38400  = {8'h00};
      bins DLH_X13_38400  = {8'h00};
      bins DLH_X16_19200  = {8'h01};
      bins DLH_X13_19200  = {8'h01};
      bins DLH_X16_9600   = {8'h02};
      bins DLH_X13_9600   = {8'h03};
      bins DLH_X16_4800   = {8'h05};
      bins DLH_X13_4800   = {8'h06};
      bins DLH_X16_2400   = {8'h0A};
      bins DLH_X13_2400   = {8'h0C};   
    }

    //INTERRUPT: coverpoint write_data iff (address == 10'h010){
   INTERRUPT: coverpoint int_status{   
      bins EN_PARITY_ERROR  = {32'h10};
      bins EN_RX_FIFO_EMPTY = {32'h08};
      bins EN_RX_FIFO_FULL  = {32'h04};
      bins EN_TX_FIFO_EMPTY = {32'h02};
      bins EN_TX_FIFO_FULL  = {32'h01}; 
    }

    //parity_baudrate_stopbit_datawidth: cross PARITY_MODE, STOP_BIT, DATA_FRAME;
  endgroup

  typedef enum{
    INT_IDLE,
    INT_EMPTY_ASSERT,
    INT_EMPTY_DEASSERT,

    INT_FULL_DEASSERT
  } int_state_e;

  int_state_e int_empty_state = INT_IDLE;
  int_state_e int_full_state  = INT_IDLE;
 
  function new(string name = "dut_scoreboard", uvm_component parent);
    super.new(name, parent);
    UART_CFG_GROUP = new();
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    $display("ENTER SCOREBOARD BUILD PHASE");  

    ahb_a_export  = new("ahb_a_export", this);
    uart_a_export = new("uart_a_export", this);
    interrupt_a_export = new("interrupt_a_export", this);

    if(!uvm_config_db#(uart_configuration)::get(this, "", "cfg", cfg))
      `uvm_fatal("CFG", "CANNOT get uart_configuration")
    //else
    //  `uvm_info("CFG", "GET SUCCESSFULLY!!!!", UVM_NONE)

    //`uvm_info(get_type_name(), $sformatf("%s",cfg.sprint()), UVM_NONE)
  endfunction

  virtual task run_phase(uvm_phase phase);

  endtask

  function void write_ahb(ahb_transaction trans);
    bit [7:0]   data;
    //bit [31:0]  lcr;
    uart_transaction exp;

    address = trans.addr;
    data    = trans.data;

    //UART_CFG_GROUP.sample();

    if((trans.xact_type == ahb_transaction::WRITE)) begin
      case(trans.addr)
        10'h000: begin
          osm_sel = trans.data[0];
        end
        10'h004: begin
          dll = trans.data;
          dll_valid = 1;
        end
        10'h008: begin
          dlh = trans.data;
          dlh_valid = 1;
        end
      endcase

      //if(dll_valid && dlh_valid) begin
      //  UART_CFG_GROUP.sample();
      //end
    end
     if((trans.xact_type == ahb_transaction::WRITE) && (trans.addr == 10'h00C)) begin
      lcr = trans.data;
      if(lcr[3] == 1'b0) begin
        parity_mode = 2'b00;  //NONE
      end
      else begin
        parity_mode = lcr[4] ? 2'b10 : 2'b01; //EVEN : ODD
      end

      case(lcr[1:0])
        2'b11: data_width = 8;
        2'b10: data_width = 7;
        2'b01: data_width = 6;
        2'b00: data_width = 5;
      endcase

      stop_bit = lcr[2] ? 2 : 1;
    end

    if((trans.xact_type == ahb_transaction::WRITE) && (trans.addr == 10'h018)) begin
      exp   = uart_transaction::type_id::create("exp");
      //Assign data
      data      = trans.data & ((1 << data_width) - 1);
      exp.data  = data;
      //Assign Parity
      exp.parity  = parity_calculation(data, parity_mode);
      //Assign stop bit
      exp.stop_bit  = stop_bit;
      //Push transaction to queue
      expected_txd_q.push_back(exp);      

      `uvm_info("SCOREBOARD", $sformatf("\n===== Captured data from AHB: 0x%0h",trans.data), UVM_LOW)
    end
    
    if((trans.xact_type == ahb_transaction::WRITE) && (trans.addr == 10'h010)) begin
      int_status = trans.data;
      $display("===== Received Data from IER =====");
      if((int_status[3] == 1) || (int_status[1] == 1)) begin
        check_interrupt_empty = 1;
        int_empty_state = INT_EMPTY_ASSERT;
        $display("===== IER[3] || IER[1] enabled -> ASSERTED =====");
      end
      if((int_status[2] == 1) || (int_status[0] == 1)) begin
        check_interrupt_full = 1;
        int_full_state = INT_FULL_DEASSERT;
        $display("===== IER[2] || IER[1] enabled -> DEASSERTED =====");
      end
    end

    compare_txd();
    UART_CFG_GROUP.sample();
  endfunction

  function void write_uart(uart_transaction trans);
    if((trans.direction == uart_transaction::RX)) begin
      actual_txd_q.push_back(trans);
      `uvm_info("SCOREBOARD", $sformatf("\n===== Captured data from UART: 0x%0h",trans.data), UVM_LOW)
    end
    compare_txd();
  endfunction

  function void compare_txd();
    uart_transaction act;
    uart_transaction exp;

    while((expected_txd_q.size() > 0) && (actual_txd_q.size() > 0) && ((check_interrupt_empty | check_interrupt_full) == 0)) begin
      act   = actual_txd_q.pop_front();
      exp   = expected_txd_q.pop_front();

      `uvm_info(get_type_name(), $sformatf("\n\n=====[UART TXD] Data comparison =====\n"), UVM_LOW)
      //`uvm_info(get_type_name(), $sformatf("%s", act.sprint()), UVM_LOW)
      //`uvm_info(get_type_name(), $sformatf("%s", exp.sprint()), UVM_LOW)

      if(act.data != exp.data) begin
        `uvm_error(get_type_name(), $sformatf("\n=====[DATA FRAME: %0d] FAILED!!! Expected value is 0x%0h, Actual data is 0x%0h =====",data_width, exp.data,act.data))
      end
      else begin
        `uvm_info(get_type_name(), $sformatf("\n=====[DATA FRAME: %0d] PASSED SUCCESSFULLY!!! =====", data_width), UVM_LOW)
      end

      `uvm_info(get_type_name(), $sformatf("\n\n=====[UART TXD] Parity comparison =====\n"), UVM_LOW)   

      if(act.parity != exp.parity) begin
        `uvm_error(get_type_name(), $sformatf("\n=====[PARITY MODE: %0b] FAILED!!! Expected parity is %b, Actual parity is %b =====",parity_mode, exp.parity, act.parity))
      end
      else begin
        `uvm_info(get_type_name(), $sformatf("\n=====[PARITY MODE: %0b] PASSED SUCCESSFULLY!!! =====", parity_mode), UVM_LOW)
      end


    end
  endfunction

  function bit parity_calculation(bit [7:0] data, bit [1:0] parity_mode);
    case(parity_mode)
      2'b00: return 0;
      2'b10:  return ^(data);
      2'b01:   return ~(^data);
    endcase
  endfunction

  function void write_interrupt(interrupt_transaction trans);
    //`uvm_info(get_type_name(), $sformatf("Interurpt = %b, state = %s", trans.interrupt, int_state.name()), UVM_LOW)
    case(int_empty_state)
      INT_IDLE: begin

      end
      INT_EMPTY_ASSERT: begin
        if(trans.interrupt) begin
          `uvm_info(get_type_name(), $sformatf("===== Interrupt is asserted ====="), UVM_LOW)
          int_empty_state = INT_EMPTY_DEASSERT;
        end
        else begin
          `uvm_error(get_type_name(), $sformatf("===== Interrupt should be asserted ====="))
        end
      end
      INT_EMPTY_DEASSERT: begin
        if(!trans.interrupt) begin
          `uvm_info(get_type_name(), $sformatf("===== PASSED SUCCESSFULLY!!! ====="), UVM_LOW)
          int_empty_state = INT_IDLE;
        end
        else begin
          `uvm_error(get_type_name(), $sformatf("===== FAILED!!! Interrupt should be deasserted ====="))
        end
      end    
    endcase

    case(int_full_state)
      INT_IDLE: begin

      end
      INT_FULL_DEASSERT: begin
        if(trans.interrupt) begin
          `uvm_info(get_type_name(), $sformatf("===== PASSED SUCCESSFULLY!!! Interrupt is asserted ====="), UVM_LOW)
          int_full_state = INT_IDLE;
        end
        else begin
          `uvm_error(get_type_name(), $sformatf("===== Interrupt should be asserted ====="))
        end
      end
     
    endcase

  endfunction

endclass
