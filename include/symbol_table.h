#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <string>
#include <vector>
#include <map>
#include <set>
#include <utility>

struct NamedId {
  int id;
  std::string name;
};

typedef NamedId lit_t, var_t, const_t;

typedef
std::map<
  lit_t,
  std::pair<
    std::set<var_t>,
    std::set<const_t>
  >
> statement_t;
//TODO "statement" might be ambigiuos since it can also be used for other things

typedef std::vector<
  statement_t
> symbol_table_t;

NamedId next_id(std::string name);

#endif /* SYMBOL_TABLE_H */
