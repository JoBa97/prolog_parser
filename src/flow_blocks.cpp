#include "flow_blocks.h"

std::vector<std::string> EntryBlock::toInstructions() const {
  std::vector<std::string> instructions;
  std::ostringstream e_instr;
  e_instr << e_node_id
          << " E "
          << e_node_out_1.repr()
          << " (" << c_node_id << ", 1) "
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

  std::ostringstream u_instr;
  u_instr << u_1_node_id << " U (" << a_node_id << ", 1) - " << u_lit_info;
  instructions.push_back(u_instr.str());

  std::ostringstream a_instr;
  a_instr << a_node_id << " A (" << c_node_id << ", 1) - -";
  instructions.push_back(a_instr.str());

  std::ostringstream c_instr;
  c_instr << c_node_id << " C (" << u_2_node_id << ", 2) " << c_node_out_2.repr();
  instructions.push_back(c_instr.str());

  std::ostringstream u_2_instr;
  u_2_instr << u_2_node_id << " U " << u_node_out_1.repr() << " - ";
  instructions.push_back(u_2_instr.str());
  return instructions;
}
