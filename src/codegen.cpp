#include "codegen.h"

std::vector<std::string> generate_flow_code(const symbol_table_t& symbol_table) {

  std::vector<std::string> instructions;
  std::vector<std::unique_ptr<IBaseBlock>> all_blocks;

  for (auto& statement_info: symbol_table) {
    if (statement_info.size() > 1) {
      //TODO this algorithm
      for (size_t i = 1; i < statement_info.size(); i++) {
        //TODO gen block
        auto wrapper_block = new WrapperBlock(std::string("TODO replace with lit at position i"));
        if (i > 1) {
          //need to check dependecies
          //TODO
          for(size_t j = i - 1; j < i; j++) {
            int dependency = check_dependency(statement_info, j, i);
            if (4 != dependency) {
              auto element = get_dependency_element(dependency,
                              std::string("TODO get g_info"),
                              std::string("TODo get i_info"));
              //TODO
            } else {
              //independant
              //TODO
            }
          }
        } else {
          //first non head literal, no dependecies
          //TODO
          /* code */
        }
      }
    } else {
      //its a fact
      //simpy generate (e)-(r)

      auto entry_block = new EntryBlock(statement_info.begin()->first.repr());
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
  //TODO
  return 0;
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
