#include "symbol_table.h"

int id_counter = 0;
NamedId next_id(std::string name) {
  return NamedId { id_counter++, name};
}
