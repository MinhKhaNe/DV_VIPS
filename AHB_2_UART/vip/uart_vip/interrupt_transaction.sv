class interrupt_transaction extends uvm_sequence_item;
  `uvm_object_utils(interrupt_transaction)

  bit   interrupt;
  time  int_time;

  function new(string name = "interrupt_transaction");
    super.new(name);
  endfunction

endclass
