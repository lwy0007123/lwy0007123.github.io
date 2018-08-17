---
title: How to revert Singly Linked List
date: 2018-08-17 22:27:45
categories: algorithm
tags:
- cpp
- LinkdList
---

Here is the struct of Singly Linked List and Print method:

```cpp
struct Link {
  Link* next;
  DType data;
  Link(DType data) { this->data = data; }
};

void Print(Link* head) {
  while (head != NULL) {
    cout << head->data << ' ';
    head = head->next;
  }
  cout << endl;
}
```

Two ways to revert the Singly Linked List.

* Non-Recursion version

```cpp
Link* Reverse(Link* head) {
  if (head == NULL)
    return NULL;
  Link *r, *p, *q;
  p = head;
  q = head->next;
  head->next = NULL;
  while (q != NULL) {
    r = q->next;
    q->next = p;
    p = q;
    q = r;
  }
  return p;
}
```

* Recursion version

```cpp
Link* Reverse2(Link* head, Link*& nhead) {
  nhead = NULL;
  if (head == NULL)
    return NULL;
  if (head->next == NULL) {
    nhead = head;
    return head;
  }
  Link* tail = Reverse2(head->next, nhead);
  tail->next = head;
  head->next = NULL;
  return head;
}
```

main function & result:

```cpp
int main() {
  Link *root, *p;
  for (int i = 0; i < 10; i++) {
    if (i == 0) {
      root = p = new Link(i);
    } else {
      p->next = new Link(i);
      p = p->next;
    }
  }
  Print(root);
  // 0 1 2 3 4 5 6 7 8 9

  root = Reverse(root);
  Print(root);
  // 9 8 7 6 5 4 3 2 1 0

  Link* nroot;
  Reverse2(root, nroot);
  Print(nroot);
  // 0 1 2 3 4 5 6 7 8 9

  return 0;
}
```