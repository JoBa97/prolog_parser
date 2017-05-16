#ifndef FLOW_BLOCKS_H
#define FLOW_BLOCKS_H

#include <string>
#include <vector>
#include <sstream>
#include <memory>

typedef int node_id_t;

class InputPortRef {
  public:
    InputPortRef()
    : port_no(-1), node_ref(nullptr) {}

    InputPortRef(int port, const node_id_t* ref)
    : port_no(port), node_ref(ref) {}

    bool isValid() const {
      return (port_no > 0) && (node_ref) && (*node_ref >=0);
    }

    std::string repr() const {
      std::ostringstream repr;
      if (isValid()) {
        repr << "(" << *node_ref << ", " << port_no << ")";
      } else {
        repr << "-";
      }
      return repr.str();
    }

  private:
    int port_no;
    const node_id_t* node_ref;
};

class Node {
  public:
    Node(char type, const std::string& info)
    : m_id(-1),
      m_type(type),
      m_info(info),
      m_outputs() {}

    void assignId(node_id_t id) {
      m_id = id;
    }

    InputPortRef inputPort(int port_no) {
      return InputPortRef(port_no, &m_id);
    }

    void addOutput(InputPortRef input_ref) {
      m_outputs.push_back(input_ref);
    }

    std::string repr() const {
      std::ostringstream repr;
      repr << m_id
            << "\t" << m_type << "\t";
      for(auto& out: m_outputs) {
        repr << " " << out.repr();
      }
      repr << "\t" << m_info;
      return repr.str();
    }

  private:
    node_id_t m_id;
    char m_type;
    std::string m_info;
    std::vector<InputPortRef> m_outputs;
};

class IBaseBlock {
  public:
    virtual std::vector<std::string> toInstructions() const = 0;
    /* returns the next free id */
    virtual node_id_t assignIds(node_id_t start) = 0;
};

class IBaseDependecyElement
: public IBaseBlock {
  public:
    virtual InputPortRef internInput() = 0;
    virtual InputPortRef externInput() = 0;
    virtual void addInternOutput(InputPortRef input_ref) = 0;

};

//TODO this class
class WrapperBlock
: public IBaseBlock {
  public:
    WrapperBlock(const std::string& lit_info)
    : m_u_from_entry_c(Node('U', lit_info)),
      m_u_from_prev_left_u(Node('U', std::string())),
      m_a(Node('A', std::string())),
      m_c(Node('C', std::string())),
      m_dep_elements() {
        m_a.addOutput(m_c.inputPort(1));
        m_c.addOutput(m_u_from_prev_left_u.inputPort(2));
      }

      InputPortRef entryCUInput() {
        return m_u_from_entry_c.inputPort(1);
      }

      InputPortRef leftUInput() {
        return m_u_from_prev_left_u.inputPort(1);
      }

      void addDependencyElement(std::unique_ptr<IBaseDependecyElement> dep_elem) {
        m_dep_elements.emplace_back(std::move(dep_elem));
      }

      InputPortRef dependencyElementExternInput(size_t n) {
        return m_dep_elements[n]->externInput();
      }

      // only call once
      // wire up the inner dep and other nodes
      void finalizeConnections();

      void addUOutput(InputPortRef input_ref) {
        m_u_from_prev_left_u.addOutput(input_ref);
      }

      void addCOutput(InputPortRef input_ref) {
        m_c.addOutput(input_ref);
      }

    std::vector<std::string> toInstructions() const;
    node_id_t assignIds(node_id_t start);

  private:
    Node m_u_from_entry_c,
          m_u_from_prev_left_u,
          m_a,
          m_c;
    std::vector<std::unique_ptr<IBaseDependecyElement>> m_dep_elements;
};

class EntryBlock
:public IBaseBlock {
  public:
    EntryBlock(const std::string& lit_info)
    : m_e(Node('E', lit_info)),
     m_c(Node('C', std::string())) {
      m_e.addOutput(m_c.inputPort(1));
    }

    std::vector<std::string> toInstructions() const;
    node_id_t assignIds(node_id_t start);

    void addEOutput(InputPortRef input_ref) {
      m_e.addOutput(input_ref);
    }

    void addCOutput(InputPortRef input_ref) {
      m_c.addOutput(input_ref);
    }

  private:
    Node m_e,
          m_c;
};

class ReturnBlock
: public IBaseBlock {
  public:
    ReturnBlock()
    : m_r(Node('R', std::string())) {}

    std::vector<std::string> toInstructions() const;
    node_id_t assignIds(node_id_t start);

    InputPortRef rInput() {
      return m_r.inputPort(1);
    }

  private:
    Node m_r;
};

class ADependencyElement
: public IBaseDependecyElement {
  // unconditioned dependency
  public:
    ADependencyElement()
    : m_u(Node('U', std::string())) {}

    InputPortRef internInput() {
      return m_u.inputPort(2);
    }

    InputPortRef externInput() {
      return m_u.inputPort(1);
    }

    void addInternOutput(InputPortRef input_ref) {
      m_u.addOutput(input_ref);
    }

    std::vector<std::string> toInstructions() const;
    node_id_t assignIds(node_id_t start);

  private:
    Node m_u;
};

class BDependencyElement
: public IBaseDependecyElement {
  // ground test
  public:
    BDependencyElement(const std::string& g_info)
    : m_g(Node('G', g_info)),
      m_u(Node('U', std::string())) {
        m_g.addOutput(m_u.inputPort(2));
      }

    InputPortRef internInput() {
      return m_g.inputPort(1);
    }

    InputPortRef externInput() {
      return m_u.inputPort(1);
    }

    void addInternOutput(InputPortRef input_ref) {
      m_g.addOutput(input_ref);
      m_u.addOutput(input_ref);
    }

    std::vector<std::string> toInstructions() const;
    node_id_t assignIds(node_id_t start);

  private:
    Node m_g, m_u;
};

class CDependencyElement
: public IBaseDependecyElement {
  // ground/independence test
  public:
    CDependencyElement(const std::string& g_info, const std::string& i_info)
    : m_g(Node('G', g_info)),
      m_i(Node('I', i_info)),
      m_u(Node('U', std::string())) {
        m_g.addOutput(m_u.inputPort(2));
        m_g.addOutput(m_i.inputPort(1));
        m_i.addOutput(m_u.inputPort(2));
      }

    InputPortRef internInput() {
      return m_g.inputPort(1);
    }

    InputPortRef externInput() {
      return m_u.inputPort(1);
    }

    void addInternOutput(InputPortRef input_ref) {
      m_i.addOutput(input_ref);
      m_u.addOutput(input_ref);
    }

    std::vector<std::string> toInstructions() const;
    node_id_t assignIds(node_id_t start);

  private:
    Node m_g, m_i, m_u;
};

class DDependencyElement
: public IBaseDependecyElement {
  // independence test
  public:
    DDependencyElement(const std::string& i_info)
    : m_i(Node('I', i_info)),
      m_u(Node('U', std::string())) {
        m_i.addOutput(m_u.inputPort(2));
      }

    InputPortRef internInput() {
      return m_i.inputPort(1);
    }

    InputPortRef externInput() {
        return m_u.inputPort(1);
    }

    void addInternOutput(InputPortRef input_ref) {
        m_i.addOutput(input_ref);
        m_u.addOutput(input_ref);
    }

    std::vector<std::string> toInstructions() const;
    node_id_t assignIds(node_id_t start);

  private:
    Node m_i, m_u;
};

//TODO does  this work ?
//TODO no dont use this, just dont insert any dep
 //handeled by empty dependency in wrapper
class EDependencyElement
: public IBaseDependecyElement {
  //independant
  public:
    EDependencyElement()
    : m_pass_through(InputPortRef()) {}

    InputPortRef internInput() {
      return m_pass_through;
    }

    InputPortRef externInput() {
      //not used
      return InputPortRef();
    }

    void addInternOutput(InputPortRef input_ref) {
      //not really adding
      m_pass_through = input_ref;
    }

    std::vector<std::string> toInstructions() const {
      std::vector<std::string> instructions;
      return instructions;
    }

    node_id_t assignIds(node_id_t start) {
      return start;
    }

  private:
    InputPortRef m_pass_through;
};


#endif /* FLOW_BLOCKS_H */
