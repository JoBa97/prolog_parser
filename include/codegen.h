#ifndef CODEGEN_H
#define CODEGEN_H

#include <string>
#include <vector>
#include <iostream>
#include <memory>
#include <iterator>

#include "symbol_table.h"
#include "flow_blocks.h"
#include "debug.h"

std::vector<std::string> generate_flow_code(const symbol_table_t& symbol_table);

void print_flow_code(const std::vector<std::string>& instructions);

/*
0 = Dependent
1 = Ground test
2 = Ground/Independence test
3 = Independence test
4 = Independant
 */

int check_dependency(const lit_info_t& statement_info, int i, int j);

std::unique_ptr<IBaseDependecyElement> get_dependency_element(int dep_type, const std::string& g_info, const std::string& i_info);

#endif /* CODEGEN_H */
