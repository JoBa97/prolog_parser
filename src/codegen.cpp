#include "codegen.h"

std::vector<std::string> generate_flow_code(symbol_table_t& symbol_table) {
  std::vector<std::string> instructions;


  /* TEST */
  std::vector<std::unique_ptr<IBaseBlock>> blocks;

  auto entry_block = new EntryBlock(std::string("test"));
  auto return_block = new ReturnBlock();
  auto wrapper_1 = new WrapperBlock(std::string("test2"));
  auto wrapper_2 = new WrapperBlock(std::string("test3"));
  std::unique_ptr<IBaseDependecyElement> wrapped_2(new ADependencyElement());

  entry_block->addEOutput(wrapper_1->leftUInput());

  entry_block->addCOutput(wrapper_1->entryCUInput());
  entry_block->addCOutput(wrapper_2->entryCUInput());

  wrapper_1->finalizeConnections();
  wrapper_2->addDependencyElement(std::move(wrapped_2));
  wrapper_2->finalizeConnections();

  wrapper_1->addCOutput(wrapper_2->dependencyElementExternInput(0));
  wrapper_1->addUOutput(wrapper_2->leftUInput());
  wrapper_2->addUOutput(return_block->rInput());

  blocks.emplace_back(entry_block);
  blocks.emplace_back(wrapper_1);
  blocks.emplace_back(wrapper_2);
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
