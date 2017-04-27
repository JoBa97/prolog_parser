#include "flow_blocks.h"

std::vector<std::string> EntryBlock::toInstructions() const {
  std::vector<std::string> instructions;
  std::ostringstream e_instr;
  e_instr << e_node_id
          << " E "
          << e_node_out_1.repr()
          << " ("
          << c_node_id
          << ", 1) "
          << e_lit_info;
  instructions.push_back(e_instr.str());
  std::ostringstream c_instr;
  c_instr << c_node_id
          << " C ";
  for(auto& iref: c_node_outs) {
    c_instr << iref.repr() << " ";
  }
  instructions.push_back(c_instr.str());
  return instructions;
}

std::vector<std::string> ReturnBlock::toInstructions() const {
  std::vector<std::string> instructions;
  std::ostringstream r_instr;
  r_instr << r_node_id << " R - - -";
  instructions.push_back(r_instr.str());
  return instructions;
}

std::vector<std::string> ABlock::toInstructions() const {
  std::vector<std::string> instructions;
  return instructions;
}

std::vector<std::string> BBlock::toInstructions() const {
  std::vector<std::string> instructions;
  return instructions;
}

std::vector<std::string> CBlock::toInstructions() const {
  std::vector<std::string> instructions;
  return instructions;
}

std::vector<std::string> DBlock::toInstructions() const {
  std::vector<std::string> instructions;
  return instructions;
}

std::vector<std::string> EBlock::toInstructions() const {
  std::vector<std::string> instructions;
  return instructions;
}
