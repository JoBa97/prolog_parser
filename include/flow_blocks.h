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

class IBaseBlock {
  public:
    virtual std::vector<std::string> toInstructions() const = 0;
    /* returns the next free id */
    virtual node_id_t assignIds(node_id_t start) = 0;
};

class EntryBlock
  : public IBaseBlock {
  public:
    EntryBlock(std::string lit_info)
    : e_node_out_1(InputPortRef()),
      c_node_outs(std::vector<InputPortRef>()),
      e_node_id(-1),
      c_node_id(-1),
      e_lit_info(lit_info) {
    }

    std::vector<std::string> toInstructions() const;

    node_id_t assignIds(node_id_t start) {
      e_node_id = start++;
      c_node_id = start++;
      return start;
    }

    void setENodeOut1(const InputPortRef& ref) {
      e_node_out_1 = ref;
    }

    void addCnodeOut(const InputPortRef& ref) {
      c_node_outs.push_back(ref);
    }

  private:

    InputPortRef e_node_out_1;
    std::vector<InputPortRef> c_node_outs;
    node_id_t e_node_id, c_node_id;
    std::string e_lit_info;
};

class ReturnBlock
  : public IBaseBlock {
  public:
    ReturnBlock()
    : r_node_id(-1) {}

    std::vector<std::string> toInstructions() const;

    node_id_t assignIds(node_id_t start) {
      r_node_id = start++;
      return start;
    }

    InputPortRef rInput() const {
      return InputPortRef(1, &r_node_id);
    }

  private:
    node_id_t r_node_id;
};

class ABlock
  : public IBaseBlock {
  public:
    ABlock(std::string lit_info)
    : u_node_out_1(InputPortRef()),
      c_node_out_2(InputPortRef()),
      u_1_node_id(-1),
      u_2_node_id(-1),
      u_3_node_id(-1),
      a_node_id(-1),
      c_node_id(-1),
      u_lit_info(lit_info) {}

    std::vector<std::string> toInstructions() const;

    node_id_t assignIds(node_id_t start) {
      u_1_node_id = start++;
      u_2_node_id = start++;
      a_node_id = start++;
      c_node_id = start++;
      u_3_node_id = start++;
      return start;
    }

    void setUNodeOut1(const InputPortRef& ref) {
      u_node_out_1 = ref;
    }

    void setCNodeOut2(const InputPortRef& ref) {
      c_node_out_2 = ref;
    }

    InputPortRef u1Input() const {
      return InputPortRef(1, &u_1_node_id);
    }

    InputPortRef u2Input() const {
      return InputPortRef(1, &u_2_node_id);
    }

    InputPortRef u3Input() const {
      return InputPortRef(1, &u_3_node_id);
    }

  private:
    InputPortRef u_node_out_1, c_node_out_2;
    node_id_t u_1_node_id, u_2_node_id, u_3_node_id,
      a_node_id, c_node_id;
    std::string u_lit_info;
};

class BBlock
  : public IBaseBlock {
  public:
    BBlock(std::string lit_info, std::string ground_info)
    : u_node_out_1(InputPortRef()),
      c_node_out_2(InputPortRef()),
      u_1_node_id(-1),
      u_2_node_id(-1),
      u_3_node_id(-1),
      g_node_id(-1),
      a_node_id(-1),
      c_node_id(-2),
      u_lit_info(lit_info),
      g_info(ground_info) {}

    std::vector<std::string> toInstructions() const;

    node_id_t assignIds(node_id_t start) {
      u_1_node_id = start++;
      g_node_id   = start++;
      u_2_node_id = start++;
      a_node_id   = start++;
      c_node_id   = start++;
      u_3_node_id = start++;
      return start;
    }

    void setUNodeOut1(const InputPortRef& ref) {
      u_node_out_1 = ref;
    }

    void setCNodeOut2(const InputPortRef& ref) {
      c_node_out_2 = ref;
    }

    InputPortRef u1Input() const {
      return InputPortRef(1, &u_1_node_id);
    }

    InputPortRef u2Input() const {
      return InputPortRef(1, &u_2_node_id);
    }

    InputPortRef u3Input() const {
      return InputPortRef(1, &u_3_node_id);
    }

  private:
    InputPortRef u_node_out_1, c_node_out_2;
    node_id_t u_1_node_id, u_2_node_id, u_3_node_id,
      g_node_id, a_node_id, c_node_id;
    std::string u_lit_info, g_info;
};

//TODO the other classes

class CBlock
  : public IBaseBlock {
  public:
    CBlock(std::string lit_info, std::string ground_info, std::string independence_info)
    : u_node_out_1(InputPortRef()),
      c_node_out_2(InputPortRef()),
      u_1_node_id(-1),
      u_2_node_id(-1),
      u_3_node_id(-1),
      g_node_id(-1),
      i_node_id(-1),
      a_node_id(-1),
      c_node_id(-1),
      u_lit_info(lit_info),
      g_info(ground_info),
      i_info(independence_info) {}

    std::vector<std::string> toInstructions() const;

    node_id_t assignIds(node_id_t start) {
      u_1_node_id = start++;
      g_node_id   = start++;
      i_node_id   = start++;
      u_2_node_id = start++;
      a_node_id   = start++;
      c_node_id   = start++;
      u_3_node_id = start++;
      return start;
    }

    void setUNodeOut1(const InputPortRef& ref) {
      u_node_out_1 = ref;
    }

    void setCNodeOut2(const InputPortRef& ref) {
      c_node_out_2 = ref;
    }

    InputPortRef u1Input() const {
      return InputPortRef(1, &u_1_node_id);
    }

    InputPortRef u2Input() const {
      return InputPortRef(1, &u_2_node_id);
    }

    InputPortRef u3Input() const {
      return InputPortRef(1, &u_3_node_id);
    }

  private:
    InputPortRef u_node_out_1, c_node_out_2;
    node_id_t u_1_node_id, u_2_node_id, u_3_node_id,
      g_node_id, i_node_id, a_node_id, c_node_id;
    std::string u_lit_info, g_info, i_info;
};

class DBlock
  : public IBaseBlock {
  public:
    DBlock(std::string lit_info, std::string independence_info)
    : u_node_out_1(InputPortRef()),
      c_node_out_2(InputPortRef()),
      u_1_node_id(-1),
      u_2_node_id(-1),
      u_3_node_id(-1),
      i_node_id(-1),
      a_node_id(-1),
      c_node_id(-1),
      u_lit_info(lit_info),
      i_info(independence_info) {}

    std::vector<std::string> toInstructions() const;

    node_id_t assignIds(node_id_t start) {
      u_1_node_id = start++;
      i_node_id   = start++;
      u_2_node_id = start++;
      a_node_id   = start++;
      c_node_id   = start++;
      u_3_node_id = start++;
      return start;
    }

    void setUNodeOut1(const InputPortRef& ref) {
      u_node_out_1 = ref;
    }

    void setCNodeOut2(const InputPortRef& ref) {
      c_node_out_2 = ref;
    }

    InputPortRef u1Input() const {
      return InputPortRef(1, &u_1_node_id);
    }

    InputPortRef u2Input() const {
      return InputPortRef(1, &u_2_node_id);
    }

    InputPortRef u3Input() const {
      return InputPortRef(1, &u_3_node_id);
    }

  private:
    InputPortRef u_node_out_1, c_node_out_2;
    node_id_t u_1_node_id, u_2_node_id, u_3_node_id,
      i_node_id, a_node_id, c_node_id;
    std::string u_lit_info, i_info;
};

class EBlock
  : public IBaseBlock {
  public:
    EBlock(std::string lit_info)
    : u_node_out_1(InputPortRef()),
      c_node_out_2(InputPortRef()),
      u_1_node_id(-1),
      u_2_node_id(-1),
      a_node_id(-1),
      c_node_id(-1),
      u_lit_info(lit_info) {}

    std::vector<std::string> toInstructions() const;

    node_id_t assignIds(node_id_t start) {
      u_1_node_id = start++;
      a_node_id   = start++;
      c_node_id   = start++;
      u_2_node_id = start++;
      return start;
    }

    void setUNodeOut1(const InputPortRef& ref) {
      u_node_out_1 = ref;
    }

    void setCNodeOut2(const InputPortRef& ref) {
      c_node_out_2 = ref;
    }

    InputPortRef u1Input() const {
      return InputPortRef(1, &u_1_node_id);
    }

    InputPortRef u2Input() const {
      return InputPortRef(1, &u_2_node_id);
    }

  private:
    InputPortRef u_node_out_1, c_node_out_2;
    node_id_t u_1_node_id, u_2_node_id,
      a_node_id, c_node_id;
    std::string u_lit_info;
};

#endif /* FLOW_BLOCKS_H */
