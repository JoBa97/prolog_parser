#include "codegen.h"

std::vector<std::string> generate_flow_code(symbol_table_t& symbol_table) {
  std::vector<std::string> instructions;


  /* TEST */
  std::vector<std::unique_ptr<IBaseBlock>> blocks;

  auto entry_block = new EntryBlock(std::string("test"));
  auto return_block = new ReturnBlock();

  entry_block->addEOutput(return_block->rInput());

  blocks.emplace_back(entry_block);
  blocks.emplace_back(return_block);

  node_id_t next_id = 0;
  for(auto& block: blocks) {
    next_id = block->assignIds(next_id);
  }
  for(auto& block: blocks) {
    for(auto& instr: block->toInstructions())
    instructions.push_back(instr);
  }

  return instructions;
}

void print_flow_code(std::vector<std::string>& instructions) {
  std::cout << "\nflow code:" << std::endl;
  for(auto& instr: instructions) {
    std::cout << instr << std::endl;
  }
}
