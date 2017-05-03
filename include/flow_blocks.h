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
            << " " << m_type;
      for(auto& out: m_outputs) {
        repr << " " << out.repr();
      }
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

//TODO this class
class WrapperBlock
: public IBaseBlock {
  public:
    WrapperBlock() {}

    std::vector<std::string> toInstructions() const;
    node_id_t assignIds(node_id_t start);

  private:
/*    Node m_u_from_entry_c,
          m_u_from_prev_left_u,
          m_a,
          m_c;*/
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


#endif /* FLOW_BLOCKS_H */
