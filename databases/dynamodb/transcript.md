# Dynamo: Amazon's Highly Available Key-value Store
## 10-Minute Presentation Script

---

## [0:00 – 1:00] THE PROBLEM

Imagine you're Amazon. It's Black Friday. Millions of users simultaneously adding items
to their cart. Now imagine one server crashes. Or a datacenter loses power.
What happens to those users?

The traditional answer is: the system goes down, or rejects writes until it's safe again.
Amazon couldn't accept that. Their own words in the paper say it clearly:

> *"customers should be able to view and add items to their shopping cart even if disks
> are failing, network routes are flapping, or data centers are being destroyed by tornados"*

Failure is the normal state.

---

## [1:00 – 2:00] THE CORE TRADEOFF

Atheorem in distributed systems called 
CAP = Consistency (C), Availability (A), and Partition Tolerance (P)
> you cannot have strong consistency AND high availability
> at the same time when the network can fail.

Most traditional databases choose consistency. 
They say: 

> if I'm not sure the data is
> correct, I'd rather reject your request than give you wrong data.

Dynamo choose availability. 

> writes are NEVER rejected, even during failures.

---

## [2:00 – 2:30] THE ROADMAP

To make this work at scale, they combined five different techniques. **Table 1** in the paper

- Consistent hashing for partitioning
- Vector clocks for versioning
- Sloppy quorum with hinted handoff for temporary failures
- Merkle trees for permanent failures
- Gossip protocol for membership
    - which nodes are currently active members of this cluster?

---

## [2:30 – 3:30] TECHNIQUE 1 — CONSISTENT HASHING

how do you distribute data across hundreds of nodes, and how do you add
or remove nodes without reshuffling everything?

Dynamo uses **consistent hashing**. Think of all possible keys arranged in a circle — a
ring. Each node owns a segment of that ring. When you store a key, you hash it, find its
position on the ring, and walk clockwise until you hit a node. That node stores it.

The elegant property: if a node joins or leaves, only its immediate neighbors are
affected. The rest of the ring is untouched.

But there's a catch: if nodes are placed randomly on the ring, some get way more data
than others. Dynamo solves this with **virtual nodes** — each physical machine gets
multiple positions on the ring. A more powerful server gets more positions. This gives
you load balance AND handles heterogeneous hardware.

*(Figure 2)* — Key K is stored at nodes B, C, and D, which are the next three clockwise
positions from where K lands on the ring.

---

## [3:30 – 4:30] TECHNIQUE 2 — VECTOR CLOCKS

Now, since data is replicated across multiple nodes, you can end up with different
versions of the same object. How do you know which is newer? Or if two versions conflict?

Dynamo uses **vector clocks**. Every version of an object carries a list of
(node, counter) pairs. Every time a node writes an update, it increments its counter.
This creates a causal history.

*(Figure 3)* — A client writes, node Sx handles it — you get D1 with clock [(Sx,1)].
Another write, same node — D2 with [(Sx,2)]. So far straightforward, D2 clearly
supersedes D1.

Now two different clients read D2 simultaneously and both write updates — but to
different nodes, Sy and Sz. You get:
- D3 with [(Sx,2),(Sy,1)]
- D4 with [(Sx,2),(Sz,1)]

These are on parallel branches. Neither supersedes the other. This is a conflict.

The system returns BOTH versions to the next client that reads them. That client — or
the application logic — merges them into D5. For a shopping cart, that merge is
literally: take all items from both versions.

---

## [4:30 – 5:30] TECHNIQUE 3 — SLOPPY QUORUM + HINTED HANDOFF

Third technique: how do you handle writes when some nodes are temporarily down?

First, the quorum setup: Dynamo has three parameters — **N, R, W**.
- N = how many replicas exist
- R = how many must respond to a read
- W = how many must acknowledge a write

Setting R + W greater than N guarantees you'll always have at least one node with the
latest data. In production they use **N=3, R=2, W=2**. One node can be down and the
system keeps working.

But what if that node is down during a write? Dynamo uses **hinted handoff**. Say node A
is down. A neighbor — node D — accepts the write temporarily, but stores a hint:
"this data actually belongs to A". When A comes back, D delivers it automatically.

The write is only rejected if ALL nodes in the system are unavailable. Otherwise, it
goes through.

---

## [5:30 – 6:15] TECHNIQUE 4 — MERKLE TREES

Fourth: what about longer outages, where a node misses many updates? When it comes back,
how do you efficiently sync it without transferring gigabytes of data?

They use **Merkle trees** — hash trees where each leaf is a hash of a key's value, and
parent nodes are hashes of their children. Two nodes that want to check if they're in
sync just compare the root hash:
- Root hashes match → everything is identical, done
- Root hashes differ → walk down the tree to find exactly which keys differ, transfer only those

This minimizes both data transferred and disk reads during sync. Very elegant solution
to what could otherwise be a very expensive operation.

---

## [6:15 – 7:00] TECHNIQUE 5 — GOSSIP PROTOCOL

Finally: how do nodes know who else is in the cluster, and who is alive or dead?

No central registry — that would be a single point of failure, exactly what they're
trying to avoid. Instead, **every node contacts a random peer every second** and they
exchange membership information. This gossip spreads knowledge of joins, leaves, and
failures throughout the cluster quickly.

To prevent isolated partitions, some nodes act as **seeds** — known to everyone as
anchors. All nodes periodically reconcile with seeds, so the cluster always converges
to a consistent view of membership.
