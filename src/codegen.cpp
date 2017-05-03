#include "codegen.h"

std::vector<std::string> generate_flow_code(symbol_table_t& symbol_table) {
  std::vector<std::string> instructions;


  /* TEST */
  std::vector<std::unique_ptr<IBaseBlock>> blocks;
  auto e  = new EntryBlock(std::string("test"));
  auto eb = new EBlock(std::string("test2"));
  auto ab = new ABlock(std::string("test3"));
  auto r  = new ReturnBlock();
  e->setENodeOut1(eb->u2Input());
  e->addCnodeOut(eb->u1Input());
  e->addCnodeOut(ab->u1Input());
  eb->setUNodeOut1(ab->u3Input());
  eb->setCNodeOut2(ab->u2Input());
  ab->setUNodeOut1(r->rInput());
  blocks.emplace_back(e);
  blocks.emplace_back(eb);
  blocks.emplace_back(ab);
  blocks.emplace_back(r);
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
