#include "symbol_table.h"

int id_counter = 0;
NamedId next_id(std::string name) {
  return NamedId { id_counter++, name};
}

void print_symbol_table(symbol_table_t& symbol_table){
  std::cout << "\nSymbol table ("
    << symbol_table.size() << " entries):\n[" << std::endl;
  for(auto& statement_info: symbol_table) {
    std::cout << "  {" << std::endl;
    for(auto& lit_info: statement_info) {
      std::cout << "    {" << std::endl;
      std::cout << "      " << lit_info.first.repr() << " -> " << std::endl;
      std::cout << "        [" << std::endl;
      std::cout << "          [" << std::endl;
      for(auto& var_id: lit_info.second.first) {
        std::cout << "            " << var_id.repr() << "," << std::endl;
      }
      std::cout << "          ]," << std::endl;
      std::cout << "          [" << std::endl;
      for(auto& const_id: lit_info.second.second) {
        std::cout << "            " << const_id.repr() << "," << std::endl;
      }
      std::cout << "          ]," << std::endl;
      std::cout << "        ]" << std::endl;
      std::cout << "    }," << std::endl;
    }
    std::cout << "  }, " << std::endl;
  }
  std::cout << "]" << std::endl;
}
