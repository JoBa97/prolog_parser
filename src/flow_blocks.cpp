#include "flow_blocks.h"

std::vector<std::string>
WrapperBlock::toInstructions() const {
  std::vector<std::string> instructions;
  instructions.push_back(m_u_from_entry_c.repr());
  //add all dep elem instr
  for (auto& dep_elem: m_dep_elements) {
    for (auto& instr: dep_elem->toInstructions()) {
      instructions.push_back(instr);
    }
  }
  instructions.push_back(m_a.repr());
  instructions.push_back(m_c.repr());
  instructions.push_back(m_u_from_prev_left_u.repr());
  return instructions;
}

node_id_t
WrapperBlock::assignIds(node_id_t start) {
  m_u_from_entry_c.assignId(start++);
  for (auto& dep_elem: m_dep_elements) {
    start = dep_elem->assignIds(start);
  }
  m_a.assignId(start++);
  m_c.assignId(start++);
  m_u_from_prev_left_u.assignId(start++);
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

std::vector<std::string>
ADependencyElement::toInstructions() const {
  std::vector<std::string> instructions;
  instructions.push_back(m_u.repr());
  return instructions;
}

node_id_t
ADependencyElement::assignIds(node_id_t start) {
  m_u.assignId(start++);
  return start;
}

std::vector<std::string>
BDependencyElement::toInstructions() const {
  std::vector<std::string> instructions;
  instructions.push_back(m_g.repr());
  instructions.push_back(m_u.repr());
  return instructions;
}

node_id_t
BDependencyElement::assignIds(node_id_t start) {
  m_g.assignId(start++);
  m_u.assignId(start++);
  return start;
}

std::vector<std::string>
CDependencyElement::toInstructions() const {
  std::vector<std::string> instructions;
  instructions.push_back(m_g.repr());
  instructions.push_back(m_i.repr());
  instructions.push_back(m_u.repr());
  return instructions;
}

node_id_t
CDependencyElement::assignIds(node_id_t start) {
  m_g.assignId(start++);
  m_i.assignId(start++);
  m_u.assignId(start++);
  return start;
}

std::vector<std::string>
DDependencyElement::toInstructions() const {
  std::vector<std::string> instructions;
  instructions.push_back(m_i.repr());
  instructions.push_back(m_u.repr());
  return instructions;
}

node_id_t
DDependencyElement::assignIds(node_id_t start) {
  m_i.assignId(start++);
  m_u.assignId(start++);
  return start;
}
