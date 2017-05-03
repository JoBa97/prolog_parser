#include "flow_blocks.h"

std::vector<std::string>
WrapperBlock::toInstructions() const {
  std::vector<std::string> instructions;
  //TODO
  return instructions;
}

node_id_t
WrapperBlock::assignIds(node_id_t start) {
  //TODO
  return start;
}

std::vector<std::string>
EntryBlock::toInstructions() const {
  std::vector<std::string> instructions;
  instructions.push_back(m_e.repr());
  instructions.push_back(m_c.repr());
  return instructions;
}

node_id_t
EntryBlock::assignIds(node_id_t start) {
  m_e.assignId(start++);
  m_c.assignId(start++);
  return start;
}

std::vector<std::string>
ReturnBlock::toInstructions() const {
  std::vector<std::string> instructions;
  instructions.push_back(m_r.repr());
  return instructions;
}

node_id_t
ReturnBlock::assignIds(node_id_t start) {
  m_r.assignId(start++);
  return start;
}
