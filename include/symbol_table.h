#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <utility>
#include <algorithm>

struct NamedId {
  int id;
  std::string name;

  std::string repr() const {
    std::string s("NamedId(");
    s+= std::to_string(id);
    s+= ", ";
    s+= name;
    s+= ')';
    return s;
  }

};

struct NamedIdCompare {
  bool operator() (const NamedId& lhs, const NamedId& rhs) const
  {
    return lhs.id < rhs.id;
  }
};

typedef NamedId lit_id_t, var_id_t, const_id_t;

typedef
std::pair<
  std::set<var_id_t, NamedIdCompare>,
  std::set<const_id_t, NamedIdCompare>
> var_info_t;

typedef
std::map<
  lit_id_t,
  var_info_t,
  NamedIdCompare
> lit_info_t;

typedef std::vector<
  lit_info_t
> symbol_table_t;

NamedId next_id(std::string name);

void print_symbol_table(symbol_table_t& symbol_table);

#endif /* SYMBOL_TABLE_H */
