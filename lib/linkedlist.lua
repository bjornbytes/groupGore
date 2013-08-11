LinkedList = class()

function LinkedList.create()
  local list = {}
  list.head = nil
  list.tail = nil
  list.length = 0
  setmetatable(list, {
    __index = LinkedList
  })
  return list
end

function LinkedList:insert(val)
  local node = {
    val = val,
    next = self.head,
    prev = nil
  }
  
  if self.head then self.head.prev = node end
  if self.tail == nil then self.tail = node end
  
  self.head = node
  self.length = self.length + 1
  return node
end

function LinkedList:append(val)
  local node = {
    val = val,
    next = nil,
    prev = self.tail
  }
  
  if self.tail then self.tail.next = node end
  if self.head == nil then self.head = node end
  
  self.tail = node
  self.length = self.length + 1
  return node
end

function LinkedList:remove(node)
  if node.prev then node.prev.next = node.next else self.head = node.next end
  if node.next then node.next.prev = node.prev else self.tail = node.prev end
  node = nil
  self.length = self.length - 1
end
