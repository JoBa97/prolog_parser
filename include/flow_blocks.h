#ifndef FLOW_BLOCKS_H
#define FLOW_BLOCKS_H

#include <string>
#include <vector>

class IToInstructions {
  public:
    virtual const std::vector<std::string> toInstructions() const = 0;
};


class EntryBlock
  : public IToInstructions {

};

class ReturnBlock
  : public IToInstructions {

};

class ABlock
  : public IToInstructions {

};

class BBlock
  : public IToInstructions {

};

class CBlock
  : public IToInstructions {

};

class DBlock
  : public IToInstructions {

};

#endif /* FLOW_BLOCKS_H */
