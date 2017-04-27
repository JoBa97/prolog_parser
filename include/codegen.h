#ifndef CODEGEN_H
#define CODEGEN_H

#include <string>
#include <vector>
#include <iostream>
#include <memory>

#include "symbol_table.h"
#include "flow_blocks.h"

std::vector<std::string> generate_flow_code(symbol_table_t& symbol_table);

void print_flow_code(std::vector<std::string>& instructions);

#endif /* CODEGEN_H */
