#include "codegen.h"

std::vector<std::string> generate_flow_code(const symbol_table_t& symbol_table) {

  std::vector<std::string> instructions;
  std::vector<std::shared_ptr<IBaseBlock>> all_blocks;

      //TODO this algorithm: wow

  for (auto& statement_info: symbol_table) {
    if (statement_info.size() > 1) {
      DEBUG("its a rule");

      std::vector<std::shared_ptr<WrapperBlock>> current_blocks;
      auto entry_block = new EntryBlock(statement_info.begin()->first.name);
      auto return_block = new ReturnBlock();
      std::shared_ptr<WrapperBlock> last_wrapper;

      auto map_iter = statement_info.begin();
      ++map_iter;
      for (size_t i = 1; i < statement_info.size(); i++) {
        auto wrapper_block =
          std::shared_ptr<WrapperBlock>(new WrapperBlock(map_iter->first.name));

        if(1==i) {
          //first non head literal, no dependecies
          // just generate wrapper and link to
          DEBUG("first non head litearal, no deps");
          entry_block->addCOutput(wrapper_block->entryCUInput());
          entry_block->addEOutput(wrapper_block->leftUInput());
          //auto dependency_element =
          //  std::unique_ptr<IBaseDependecyElement>(new EDependencyElement());
          //wrapper_block->addDependencyElement(std::move(dependency_element));
          //dont insert independant dependency here, since it bugs
          wrapper_block->finalizeConnections();
          current_blocks.emplace_back(wrapper_block);
          last_wrapper = wrapper_block;
        } else if (i > 1) {
          //need to check dependecies
          //TODO
          entry_block->addCOutput(wrapper_block->entryCUInput());
          last_wrapper->addUOutput(wrapper_block->leftUInput());
          for(size_t j = i - 1; j >= 1; j--) {
            DEBUG("dependency for i=" << i << " j=" << j)
            int dependency = check_dependency(statement_info, j, i);
            DEBUG("dependency type: " << dependency);
            if (4 != dependency) {
              auto dependency_element = get_dependency_element(dependency,
                              std::string("TODO get g_info"),
                              std::string("TODO get i_info"));
              last_wrapper->addCOutput(dependency_element->externInput());
              wrapper_block->addDependencyElement(std::move(dependency_element));
            } else {
              //independant
              //dont insert any dependency
            }
          }
          wrapper_block->finalizeConnections();
          current_blocks.emplace_back(wrapper_block);
          last_wrapper = wrapper_block;
        }
        ++map_iter;
      }

      // link to return
      last_wrapper->addUOutput(return_block->rInput());
      // add to all_blocks
      all_blocks.emplace_back(entry_block);
      for (auto& block: current_blocks) {
        all_blocks.emplace_back(block);
      }
      all_blocks.emplace_back(return_block);
    } else {
      //its a fact
      //simpy generate (e)-(r)
      DEBUG("its a fact");

      auto entry_block = new EntryBlock(statement_info.begin()->first.name);
      auto return_block = new ReturnBlock();
      entry_block->addEOutput(return_block->rInput());

      all_blocks.emplace_back(entry_block);
      all_blocks.emplace_back(return_block);

    }
  }


    /* TEST */
/*  auto entry_block = new EntryBlock(std::string("test"));
  auto return_block = new ReturnBlock();
  auto wrapper_1 = new WrapperBlock(std::string("test2"));
  auto wrapper_2 = new WrapperBlock(std::string("test3"));
  std::unique_ptr<IBaseDependecyElement> wrapped_2(new ADependencyElement());

  entry_block->addEOutput(wrapper_1->leftUInput());

  entry_block->addCOutput(wrapper_1->entryCUInput());
  entry_block->addCOutput(wrapper_2->entryCUInput());

  wrapper_1->finalizeConnections();

  wrapper_2->addDependencyElement(std::move(wrapped_2));
  wrapper_2->finalizeConnections();

  wrapper_1->addCOutput(wrapper_2->dependencyElementExternInput(0));
  wrapper_1->addUOutput(wrapper_2->leftUInput());
  wrapper_2->addUOutput(return_block->rInput());

  all_blocks.emplace_back(entry_block);
  all_blocks.emplace_back(wrapper_1);
  all_blocks.emplace_back(wrapper_2);
  all_blocks.emplace_back(return_block);
*/
  /* TEST END */


  // assign all the ids
  node_id_t next_id = 0;
  for(auto& block: all_blocks) {
    next_id = block->assignIds(next_id);
  }
  //generate all the lines
  for(auto& block: all_blocks) {
    for(auto& instr: block->toInstructions())
    instructions.push_back(instr);
  }

  return instructions;
}

void print_flow_code(const std::vector<std::string>& instructions) {
  std::cout << "\nflow code:" << std::endl;
  for(auto& instr: instructions) {
    std::cout << instr << std::endl;
  }
}

/*
0 = Dependent
1 = Ground test
2 = Ground/Independence test
3 = Independence test
4 = Independant
 */

int check_dependency(const lit_info_t& statement_info, int i, int j) {
  // i < j
  // swap if necessary
  if (i > j) {
    int tmp=j;
    j=i;
    i=tmp;
  }

  // initially empty
  std::set<var_id_t, VarIdCompare> known_vars;

  auto map_iter = statement_info.begin();
  std::advance(map_iter, i);
  const auto& block1Vars = map_iter->second.first;
  map_iter = statement_info.begin();
  std::advance(map_iter, j);
  const auto& block2Vars = map_iter->second.first;

  bool uniqueVars1 = false;
  bool uniqueVars2 = false;
  bool uniqueTemps1 = false;
  bool uniqueTemps2 = false;
  bool sharedVars = false;
  bool sharedTemps = false;

  // fill known_vars
  map_iter = statement_info.begin();
  for (size_t k = 0; k < i; k++) {
    known_vars.insert(map_iter->second.first.begin(), map_iter->second.first.end());
    ++map_iter;
  }

  for (auto& v : block1Vars) {
    if (known_vars.find(v) != known_vars.end()) {
      if (sharedVars && uniqueVars1) {
        continue;
      }
      if (block2Vars.find(v) != block2Vars.end()) {
        sharedVars = true;
      } else {
        uniqueVars1 = true;
      }
    } else {
      if (sharedTemps && uniqueTemps1) {
        continue;
      }
      if (block2Vars.find(v) != block2Vars.end()) {
        sharedTemps = true;
      } else {
        uniqueTemps1 = true;
      }
    }
    if (sharedTemps && sharedVars && uniqueTemps1 && uniqueVars1) {
      break;
    }
  }

  for(auto& v : block2Vars) {
      if (block1Vars.find(v) != block1Vars.end()) {
        continue;
      }
      if (known_vars.find(v) != known_vars.end()) {
        uniqueVars2 = true;
      } else {
        uniqueTemps2 = true;
      }
      if (uniqueVars2 && uniqueTemps2) {
        break;
      }
  }

  // now decide which case has been detected
  if(sharedTemps) {
    return 0;
  }
  if (sharedVars) {
    if (uniqueVars1 && uniqueVars2) {
      return 2;
    } else {
      return 1;
    }
  }
  if (uniqueVars1 && uniqueVars2) {
    return 3;
  }
  return 4;
}


std::unique_ptr<IBaseDependecyElement> get_dependency_element(int dep_type, const std::string& g_info, const std::string& i_info) {

  std::unique_ptr<IBaseDependecyElement> elem;
  switch (dep_type) {
    case 0:
      elem = std::unique_ptr<IBaseDependecyElement>{new ADependencyElement()};
      break;
    case 1:
    elem = std::unique_ptr<IBaseDependecyElement>{new BDependencyElement(g_info)};
      break;
    case 2:
    elem = std::unique_ptr<IBaseDependecyElement>{new CDependencyElement(g_info, i_info)};
      break;
    case 3:
    elem = std::unique_ptr<IBaseDependecyElement>{new DDependencyElement(i_info)};
      break;
    case 4:
    elem = std::unique_ptr<IBaseDependecyElement>{new EDependencyElement()};
      break;
  }

  return elem;
}
