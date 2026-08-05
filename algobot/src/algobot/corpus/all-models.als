// Generated 2026-07-31T17:34:56Z
// from https://github.com/AlloyTools/models/
// at commit 886447d3369a9036aa4c3b49a82d7c557ab2e5f9

// Model: software-abstractions-book/chapter6/hotel1.als
module chapter6/hotel1 --- the model up to the top of page 191

open util/ordering[Time] as to
open util/ordering[Key] as ko

sig Key {}
sig Time {}

sig Room {
	keys: set Key,
	currentKey: keys one -> Time
	}

fact DisjointKeySets {
	-- each key belongs to at most one room
	Room<:keys   in   Room lone-> Key
	}

one sig FrontDesk {
	lastKey: (Room -> lone Key) -> Time,
	occupant: (Room -> Guest) -> Time
	}

sig Guest {
	keys: Key -> Time
	}

fun nextKey [k: Key, ks: set Key]: set Key {
	min [k.nexts & ks]
	}

pred init [t: Time] {
	no Guest.keys.t
	no FrontDesk.occupant.t
	all r: Room | FrontDesk.lastKey.t [r] = r.currentKey.t
	}

pred entry [t, t": Time, g: Guest, r: Room, k: Key] {
	k in g.keys.t
	let ck = r.currentKey |
		(k = ck.t and ck.t" = ck.t) or
		(k = nextKey[ck.t, r.keys] and ck.t" = k)
	noRoomChangeExcept [t, t", r]
	noGuestChangeExcept [t, t", none]
	noFrontDeskChange [t, t"]
	}

pred noFrontDeskChange [t, t": Time] {
	FrontDesk.lastKey.t = FrontDesk.lastKey.t"
	FrontDesk.occupant.t = FrontDesk.occupant.t"
	}

pred noRoomChangeExcept [t, t": Time, rs: set Room] {
	all r: Room - rs | r.currentKey.t = r.currentKey.t"
	}
	
pred noGuestChangeExcept [t, t": Time, gs: set Guest] {
	all g: Guest - gs | g.keys.t = g.keys.t"
	}

pred checkout [t, t": Time, g: Guest] {
	let occ = FrontDesk.occupant {
		some occ.t.g
		occ.t" = occ.t - Room ->g
		}
	FrontDesk.lastKey.t = FrontDesk.lastKey.t"
	noRoomChangeExcept [t, t", none]
	noGuestChangeExcept [t, t", none]
	}

pred checkin [t, t": Time, g: Guest, r: Room, k: Key] {
	g.keys.t" = g.keys.t + k
	let occ = FrontDesk.occupant {
		no occ.t [r]
		occ.t" = occ.t + r -> g
		}
	let lk = FrontDesk.lastKey {
		lk.t" = lk.t ++ r -> k
		k = nextKey [lk.t [r], r.keys]
		}
	noRoomChangeExcept [t, t", none]
	noGuestChangeExcept [t, t", g]
	}

fact traces {
	init [first]
	all t: Time-last | let t" = t.next |
		some g: Guest, r: Room, k: Key |
			entry [t, t", g, r, k]
			or checkin [t, t", g, r, k]
			or checkout [t, t", g]
	}

assert NoBadEntry {
	all t: Time, r: Room, g: Guest, k: Key |
		let t" = t.next, o = FrontDesk.occupant.t[r] |
			entry [t, t", g, r, k] and some o => g in o
	}

// This generates a counterexample similar to Fig 6.6
check NoBadEntry for 3 but 2 Room, 2 Guest, 5 Time

// Model: software-abstractions-book/chapter6/hotel2.als
module chapter6/hotel2 --- the final model in Fig 6.7

open util/ordering[Time] as to
open util/ordering[Key] as ko

sig Key {}
sig Time {}

sig Room {
	keys: set Key,
	currentKey: keys one -> Time
	}

fact DisjointKeySets {
	-- each key belongs to at most one room
	Room<:keys   in   Room lone-> Key
	}

one sig FrontDesk {
	lastKey: (Room -> lone Key) -> Time,
	occupant: (Room -> Guest) -> Time
	}

sig Guest {
	keys: Key -> Time
	}

fun nextKey [k: Key, ks: set Key]: set Key {
	min [k.nexts & ks]
	}

pred init [t: Time] {
	no Guest.keys.t
	no FrontDesk.occupant.t
	all r: Room | FrontDesk.lastKey.t [r] = r.currentKey.t
	}

pred entry [t, t": Time, g: Guest, r: Room, k: Key] {
	k in g.keys.t
	let ck = r.currentKey |
		(k = ck.t and ck.t" = ck.t) or
		(k = nextKey[ck.t, r.keys] and ck.t" = k)
	noRoomChangeExcept [t, t", r]
	noGuestChangeExcept [t, t", none]
	noFrontDeskChange [t, t"]
	}

pred noFrontDeskChange [t, t": Time] {
	FrontDesk.lastKey.t = FrontDesk.lastKey.t"
	FrontDesk.occupant.t = FrontDesk.occupant.t"
	}

pred noRoomChangeExcept [t, t": Time, rs: set Room] {
	all r: Room - rs | r.currentKey.t = r.currentKey.t"
	}
	
pred noGuestChangeExcept [t, t": Time, gs: set Guest] {
	all g: Guest - gs | g.keys.t = g.keys.t"
	}

pred checkout [t, t": Time, g: Guest] {
	let occ = FrontDesk.occupant {
		some occ.t.g
		occ.t" = occ.t - Room ->g
		}
	FrontDesk.lastKey.t = FrontDesk.lastKey.t"
	noRoomChangeExcept [t, t", none]
	noGuestChangeExcept [t, t", none]
	}

pred checkin [t, t": Time, g: Guest, r: Room, k: Key] {
	g.keys.t" = g.keys.t + k
	let occ = FrontDesk.occupant {
		no occ.t [r]
		occ.t" = occ.t + r -> g
		}
	let lk = FrontDesk.lastKey {
		lk.t" = lk.t ++ r -> k
		k = nextKey [lk.t [r], r.keys]
		}
	noRoomChangeExcept [t, t", none]
	noGuestChangeExcept [t, t", g]
	}

fact traces {
	init [first]
	all t: Time-last | let t" = t.next |
		some g: Guest, r: Room, k: Key |
			entry [t, t", g, r, k]
			or checkin [t, t", g, r, k]
			or checkout [t, t", g]
	}

fact NoIntervening {
	all t: Time-last | let t" = t.next, t"" = t".next |
		all g: Guest, r: Room, k: Key |
			checkin [t, t", g, r, k] => (entry [t", t"", g, r, k] or no t"")
	}

assert NoBadEntry {
	all t: Time, r: Room, g: Guest, k: Key |
		let t" = t.next, o = FrontDesk.occupant.t[r] |
			entry [t, t", g, r, k] and some o => g in o
	}

// After adding the NoIntervening fact,
// these commands no longer generate counterexamples
check NoBadEntry for 3 but 2 Room, 2 Guest, 5 Time
check NoBadEntry for 3 but 3 Room, 3 Guest, 7 Time
check NoBadEntry for 5 but 3 Room, 3 Guest, 9 Time

// Model: software-abstractions-book/chapter6/hotel3.als
module chapter6/hotel3 --- model in Fig 6.10 without the NonIntervening fact

open util/ordering[Time] as to
open util/ordering[Key] as ko

sig Key, Time {}

sig Room {
	keys: set Key,
	currentKey: keys one -> Time
	}

fact {
	Room <: keys in Room lone -> Key
	}

one sig FrontDesk {
	lastKey: (Room -> lone Key) -> Time,
	occupant: (Room -> Guest) -> Time
	}

sig Guest {
	keys: Key -> Time
	}

fun nextKey [k: Key, ks: set Key]: set Key {
	min [k.nexts & ks]
	}

pred init [t: Time] {
	no Guest.keys.t
	no FrontDesk.occupant.t
	all r: Room | FrontDesk.lastKey.t [r] = r.currentKey.t
	}

abstract sig Event {
	pre, post: Time,
	guest: Guest
	}

abstract sig RoomKeyEvent extends Event {
	room: Room,
	key: Key
	}

sig Entry extends RoomKeyEvent { } {
	key in guest.keys.pre
	let ck = room.currentKey |
		(key = ck.pre and ck.post = ck.pre) or 
		(key = nextKey[ck.pre, room.keys] and ck.post = key)
	currentKey.post = currentKey.pre ++ room->key
	}

sig Checkin extends RoomKeyEvent { } {
	keys.post = keys.pre + guest -> key
	let occ = FrontDesk.occupant {
		no occ.pre [room]
		occ.post = occ.pre + room -> guest
		}
	let lk = FrontDesk.lastKey {
		lk.post = lk.pre ++ room -> key
		key = nextKey [lk.pre [room], room.keys]
		}
	}

sig Checkout extends Event { } {
	let occ = FrontDesk.occupant {
		some occ.pre.guest
		occ.post = occ.pre - Room -> guest
		}
	}

fact Traces {
	init [first]
	all t: Time-last |
		let t" = t.next |
			some e: Event {
				e.pre = t and e.post = t"
				currentKey.t != currentKey.t" => e in Entry
				occupant.t != occupant.t" => e in Checkin + Checkout
				(lastKey.t != lastKey.t" or keys.t != keys.t") => e in Checkin
			}
	}

assert NoBadEntry {
	all e: Entry |
		let o=FrontDesk.occupant.(e.pre) [e.room] | 
			some o => e.guest in o
	}

// This generates a counterexample similar to Fig 6.13
check NoBadEntry for 5 but 3 Room, 3 Guest, 5 Time, 4 Event

// Model: software-abstractions-book/chapter6/hotel4.als
module chapter6/hotel4 --- model in Fig 6.10 with the NonIntervening fact

open util/ordering[Time] as to
open util/ordering[Key] as ko

sig Key, Time {}

sig Room {
	keys: set Key,
	currentKey: keys one -> Time
	}

fact {
	Room <: keys in Room lone -> Key
	}

one sig FrontDesk {
	lastKey: (Room -> lone Key) -> Time,
	occupant: (Room -> Guest) -> Time
	}

sig Guest {
	keys: Key -> Time
	}

fun nextKey [k: Key, ks: set Key]: set Key {
	min [k.nexts & ks]
	}

pred init [t: Time] {
	no Guest.keys.t
	no FrontDesk.occupant.t
	all r: Room | FrontDesk.lastKey.t [r] = r.currentKey.t
	}

abstract sig Event {
	pre, post: Time,
	guest: Guest
	}

abstract sig RoomKeyEvent extends Event {
	room: Room,
	key: Key
	}

sig Entry extends RoomKeyEvent { } {
	key in guest.keys.pre
	let ck = room.currentKey |
		(key = ck.pre and ck.post = ck.pre) or 
		(key = nextKey[ck.pre, room.keys] and ck.post = key)
	currentKey.post = currentKey.pre ++ room->key
	}

sig Checkin extends RoomKeyEvent { } {
	keys.post = keys.pre + guest -> key
	let occ = FrontDesk.occupant {
		no occ.pre [room]
		occ.post = occ.pre + room -> guest
		}
	let lk = FrontDesk.lastKey {
		lk.post = lk.pre ++ room -> key
		key = nextKey [lk.pre [room], room.keys]
		}
	}

sig Checkout extends Event { } {
	let occ = FrontDesk.occupant {
		some occ.pre.guest
		occ.post = occ.pre - Room -> guest
		}
	}

fact Traces {
	init [first]
	all t: Time-last |
		let t" = t.next |
			some e: Event {
				e.pre = t and e.post = t"
				currentKey.t != currentKey.t" => e in Entry
				occupant.t != occupant.t" => e in Checkin + Checkout
				(lastKey.t != lastKey.t" or keys.t != keys.t") => e in Checkin
			}
	}

assert NoBadEntry {
	all e: Entry |
		let o=FrontDesk.occupant.(e.pre) [e.room] | 
			some o => e.guest in o
	}

fact NoIntervening {
	all c: Checkin |
		c.post = last
		or some e: Entry {
			e.pre = c.post
			e.room = c.room
			e.guest = c.guest
		}
	}

// After adding the NoIntervening fact,
// this command no longer generates a counterexample
check NoBadEntry for 5 but 3 Room, 3 Guest, 9 Time, 8 Event

// Model: software-abstractions-book/chapter6/mediaAssets.als
module chapter6/mediaAssets

sig ApplicationState {
	catalogs: set Catalog,
	catalogState: catalogs -> one CatalogState,
	currentCatalog: catalogs,
	buffer: set Asset
	}

sig Catalog, Asset {}

sig CatalogState {
	assets: set Asset,
	disj hidden, showing: set assets,
	selection: set assets + Undefined
	} {
	hidden+showing = assets
	}

one sig Undefined {}

pred catalogInv [cs: CatalogState] {
	cs.selection = Undefined or (some cs.selection and cs.selection in cs.showing)
	}

pred appInv [xs: ApplicationState] {
	all cs: xs.catalogs | catalogInv [xs.catalogState[cs]]
	}

pred showSelected [cs, cs": CatalogState] {
	cs.selection != Undefined
	cs".showing = cs.selection
	cs".selection = cs.selection
	cs".assets = cs.assets
	}

pred hideSelected [cs, cs": CatalogState] {
	cs.selection != Undefined
	cs".hidden = cs.hidden + cs.selection
	cs".selection = Undefined
	cs".assets = cs.assets
	}

pred cut [xs, xs": ApplicationState] {
	let cs = xs.currentCatalog.(xs.catalogState), sel = cs.selection {
		sel != Undefined
		xs".buffer = sel
		some cs": CatalogState {
			cs".assets = cs.assets - sel
			cs".showing = cs.showing - sel
			cs".selection = Undefined
			xs".catalogState = xs.catalogState ++ xs.currentCatalog -> cs"
			}
		}
	xs".catalogs = xs.catalogs
	xs".currentCatalog = xs.currentCatalog
	}

pred paste [xs, xs": ApplicationState] {
	let cs = xs.currentCatalog.(xs.catalogState), buf = xs.buffer {
		xs".buffer = buf
		some cs": CatalogState {
			cs".assets = cs.assets + buf
			cs".showing = cs.showing + (buf - cs.assets)
			cs".selection = buf - cs.assets
			xs".catalogState = xs.catalogState ++ xs.currentCatalog -> cs"
			}
		}
	xs".catalogs = xs.catalogs
	xs".currentCatalog = xs.currentCatalog
	}

assert HidePreservesInv {
	all cs, cs": CatalogState |
		catalogInv [cs] and hideSelected [cs, cs"] => catalogInv [cs"]
	}

// This check should not find any counterexample
check HidePreservesInv

pred sameApplicationState [xs, xs": ApplicationState] {
	xs".catalogs = xs.catalogs
	all c: xs.catalogs | sameCatalogState [c.(xs.catalogState), c.(xs".catalogState)]
	xs".currentCatalog = xs.currentCatalog
	xs".buffer = xs.buffer
	}

pred sameCatalogState [cs, cs": CatalogState] {
	cs".assets = cs.assets
	cs".showing = cs.showing
	cs".selection = cs.selection
	}

assert CutPaste {
	all xs, xs", xs"": ApplicationState |
		(appInv [xs] and cut [xs, xs"] and paste [xs", xs""]) => sameApplicationState [xs, xs""]
	}

// This check should find a counterexample
check CutPaste

assert PasteCut {
	all xs, xs", xs"": ApplicationState |
		(appInv [xs] and paste [xs, xs"] and cut [xs", xs""]) => sameApplicationState [xs, xs""]
	}

// This check should find a counterexample
check PasteCut

assert PasteNotAffectHidden {
	all xs, xs": ApplicationState |
		(appInv [xs] and paste [xs, xs"]) =>
			let c = xs.currentCatalog | xs".catalogState[c].hidden = xs.catalogState[c].hidden
	}

// This check should not find any counterexample
check PasteNotAffectHidden

// Model: software-abstractions-book/chapter6/ringElection1.als
module chapter6/ringElection1 --- the version up to the top of page 181

open util/ordering[Time] as TO
open util/ordering[Process] as PO

sig Time {}

sig Process {
	succ: Process,
	toSend: Process -> Time,
	elected: set Time
	}

fact ring {
	all p: Process | Process in p.^succ
	}

pred init [t: Time] {
	all p: Process | p.toSend.t = p
	}

pred step [t, t": Time, p: Process] {
	let from = p.toSend, to = p.succ.toSend |
		some id: from.t {
			from.t" = from.t - id
			to.t" = to.t + (id - p.succ.prevs)
		}
	}

fact defineElected {
	no elected.first
	all t: Time-first | elected.t = {p: Process | p in p.toSend.t - p.toSend.(t.prev)}
	}

fact traces {
	init [first]
	all t: Time-last |
		let t" = t.next |
			all p: Process |
				step [t, t", p] or step [t, t", succ.p] or skip [t, t", p]
	}

pred skip [t, t": Time, p: Process] {
	p.toSend.t = p.toSend.t"
	}

pred show { some elected }
run show for 3 Process, 4 Time
// This generates an instance similar to Fig 6.4

assert AtMostOneElected { lone elected.Time }
check AtMostOneElected for 3 Process, 7 Time
// This should not find any counterexample

assert AtLeastOneElected { some t: Time | some elected.t }
check AtLeastOneElected for 3 Process, 7 Time
// This generates a counterexample in which nothing happens

// Model: software-abstractions-book/chapter6/ringElection2.als
module chapter6/ringElection2 --- the final version (as depicted in Fig 6.1)

open util/ordering[Time] as TO
open util/ordering[Process] as PO

sig Time {}

sig Process {
	succ: Process,
	toSend: Process -> Time,
	elected: set Time
	}

fact ring {
	all p: Process | Process in p.^succ
	}

pred init [t: Time] {
	all p: Process | p.toSend.t = p
	}

pred step [t, t": Time, p: Process] {
	let from = p.toSend, to = p.succ.toSend |
		some id: from.t {
			from.t" = from.t - id
			to.t" = to.t + (id - p.succ.prevs)
		}
	}

fact defineElected {
	no elected.first
	all t: Time-first | elected.t = {p: Process | p in p.toSend.t - p.toSend.(t.prev)}
	}

fact traces {
	init [first]
	all t: Time-last |
		let t" = t.next |
			all p: Process |
				step [t, t", p] or step [t, t", succ.p] or skip [t, t", p]
	}

pred skip [t, t": Time, p: Process] {
	p.toSend.t = p.toSend.t"
	}

pred show { some elected }
run show for 3 Process, 4 Time
// This generates an instance similar to Fig 6.4

assert AtMostOneElected { lone elected.Time }
check AtMostOneElected for 3 Process, 7 Time
// This should not find any counterexample

pred progress  {
	all t: Time - TO/last |
		let t" = TO/next [t] |
			some Process.toSend.t => some p: Process | not skip [t, t", p]
	}

assert AtLeastOneElected { progress => some elected.Time }
check AtLeastOneElected for 3 Process, 7 Time
// This should not find any counterexample

pred looplessPath { no disj t, t": Time | toSend.t = toSend.t" }

// This produces an instance
run looplessPath for 3 Process, 12 Time

// This does not produce an instance
run looplessPath for 3 Process, 13 Time

// Therefore, we can conclude that a scope of 12 for Time is
// sufficient to reach all states of the protocol for a three-node ring.

// Model: software-abstractions-book/chapter6/memory/abstractMemory.als
module chapter6/memory/abstractMemory [Addr, Data] ----- the model from page 217

sig Memory {
	data: Addr -> lone Data
	}

pred init [m: Memory] {
	no m.data
	}

pred write [m, m": Memory, a: Addr, d: Data] {
	m".data = m.data ++ a -> d
	}

pred read [m: Memory, a: Addr, d: Data] {
	let d" = m.data [a] | some d" implies d = d"
	}

fact Canonicalize {
	no disj m, m": Memory | m.data = m".data
	}

// This command should not find any counterexample
WriteRead: check {
	all m, m": Memory, a: Addr, d1, d2: Data |
		write [m, m", a, d1] and read [m", a, d2] => d1 = d2
	}

// This command should not find any counterexample
WriteIdempotent: check {
	all m, m", m"": Memory, a: Addr, d: Data |
		write [m, m", a, d] and write [m", m"", a, d] => m" = m""
	}

// Model: software-abstractions-book/chapter6/memory/cacheMemory.als
module chapter6/memory/cacheMemory [Addr, Data] ----- the model from page 219

sig CacheSystem {
	main, cache: Addr -> lone Data
	}

pred init [c: CacheSystem] {
	no c.main + c.cache
	}

pred write [c, c": CacheSystem, a: Addr, d: Data] {
	c".main = c.main
	c".cache = c.cache ++ a -> d
	}

pred read [c: CacheSystem, a: Addr, d: Data] {
	some d
	d = c.cache [a]
	}

pred load [c, c": CacheSystem] {
	some addrs: set c.main.Data - c.cache.Data |
		c".cache = c.cache ++ addrs <: c.main
	c".main = c.main
	}

pred flush [c, c": CacheSystem] {
	some addrs: some c.cache.Data {
		c".main = c.main ++ addrs <: c.cache
		c".cache = c.cache - addrs -> Data
		}
	}

// This command should not find any counterexample
LoadNotObservable: check {
	all c, c", c"": CacheSystem, a1, a2: Addr, d1, d2, d3: Data |
		{
		read [c, a2, d2]
		write [c, c", a1, d1]
		load [c", c"]
		read [c"", a2, d3]
		} implies d3 = (a1=a2 => d1 else d2)
	}

// Model: software-abstractions-book/chapter6/memory/checkCache.als
module chapter6/memory/checkCache [Addr, Data]

open chapter6/memory/cacheMemory [Addr, Data] as cache
open chapter6/memory/abstractMemory [Addr, Data] as amemory

fun alpha [c: CacheSystem]: Memory {
	{m: Memory | m.data = c.main ++ c.cache}
	}

// This check should not produce a counterexample
ReadOK: check {
	// introduction of m, m" ensures that they exist, and gives witnesses if counterexample
	all c: CacheSystem, a: Addr, d: Data, m: Memory |
		cache/read [c, a, d] and m = alpha [c] => amemory/read [m, a, d]
	}

// This check should not produce a counterexample
WriteOK: check {
	all c, c": CacheSystem, a: Addr, d: Data, m, m": Memory |
		cache/write [c, c", a, d] and m = alpha [c] and m" = alpha [c"]
			=> amemory/write [m, m", a, d]
	}

// This check should not produce a counterexample
LoadOK: check {
	all c, c": CacheSystem, m, m": Memory |
		cache/load [c, c"] and m = alpha [c] and m" = alpha [c"] => m = m"
	}

// This check should not produce a counterexample
FlushOK: check {
	all c, c": CacheSystem, m, m": Memory |
		cache/flush [c, c"] and m = alpha [c] and m" = alpha [c"] => m = m"
	}

// Model: software-abstractions-book/chapter6/memory/checkFixedSize.als
module chapter6/memory/checkFixedSize [Addr, Data]

open chapter6/memory/fixedSizeMemory_H [Addr, Data] as fmemory
open chapter6/memory/abstractMemory [Addr, Data] as amemory

// define abstraction function from history-extended concrete state to abstract state
pred alpha [fm: fmemory/Memory_H, am: amemory/Memory] {
	am.data = fm.data - (fm.unwritten -> Data)
	}

// This check should not find a counterexample
initOk: check {
	all fm: fmemory/Memory_H, am: amemory/Memory |
		fmemory/init [fm] and alpha [fm, am] => amemory/init [am]
	}

// This check should not find a counterexample
readOk: check {
	all fm: fmemory/Memory_H, a: Addr, d: Data, am: amemory/Memory |
		fmemory/read [fm, a, d] and alpha [fm, am] => amemory/read [am, a, d]
	}

// This check should not find a counterexample
writeOk: check {
	all fm, fm": fmemory/Memory_H, a: Addr, d: Data, am, am": amemory/Memory |
		fmemory/write [fm, fm", a, d] and alpha [fm, am] and alpha [fm", am"]
		implies amemory/write [am, am", a, d]
	}

// Model: software-abstractions-book/chapter6/memory/fixedSizeMemory.als
module chapter6/memory/fixedSizeMemory [Addr, Data]

sig Memory {
	data: Addr -> one Data	
	}

pred init [m: Memory] {
	// This predicate is empty in order to allow non-deterministic initialization
	}

pred write [m, m": Memory, a: Addr, d: Data] {
	m".data = m.data ++ a -> d
	}

pred read [m: Memory, a: Addr, d: Data] {
	d = m.data [a]
	}

fact Canonicalize {
	no disj m, m": Memory | m.data = m".data
	}

// Model: software-abstractions-book/chapter6/memory/fixedSizeMemory_H.als
module chapter6/memory/fixedSizeMemory_H [Addr, Data]

open chapter6/memory/fixedSizeMemory [Addr, Data] as memory

sig Memory_H extends memory/Memory {
	unwritten: set Addr
	}

pred init [m: Memory_H] {
	memory/init [m]
	m.unwritten = Addr
	}

pred read [m: Memory_H, a: Addr, d: Data] {
	memory/read [m, a, d]
	}

pred write [m, m": Memory_H, a: Addr, d: Data] {
	memory/write [m, m", a, d]
	m".unwritten = m.unwritten - a
	}

// Model: software-abstractions-book/appendixA/addressBook1.als
module appendixA/addressBook1

abstract sig Name {
	address: set Addr+Name
	}

sig Alias, Group extends Name { }

sig Addr { }

fact {
	// the invariants should go here
	}

pred show {
	// simulation constraints should go here
	}

run show for 3

// Model: software-abstractions-book/appendixA/addressBook2.als
module appendixA/addressBook2

sig Addr, Name { }

sig Book {
	addr: Name -> (Name + Addr)
	}

pred inv [b: Book] {
	let addr = b.addr |
		all n: Name {
			n not in n.^addr
			some addr.n => some n.^addr & Addr
		}
	}

pred add [b, b": Book, n: Name, t: Name+Addr] {
	b".addr = b.addr + n->t
	}

pred del [b, b": Book, n: Name, t: Name+Addr] {
	b".addr = b.addr - n->t
	}

fun lookup [b: Book, n: Name] : set Addr {
	n.^(b.addr) & Addr
	}

// Model: software-abstractions-book/appendixA/barbers.als
module appendixA/barbers

sig Man { shaves: set Man }

one sig Barber extends Man { }

fact {
	Barber.shaves = { m: Man | m not in m.shaves }
	}

// Model: software-abstractions-book/appendixA/closure.als
module appendixA/closure

pred transCover [R, r: univ->univ] {
	// You have to fill in the appropriate formula here
}

pred transClosure [R, r: univ->univ] {
	transCover [R, r]
	// You have to fill in the appropriate formula here
}

assert Equivalence {
	all R, r: univ->univ | transClosure [R,r] iff R = ^r
}

check Equivalence for 3

// Model: software-abstractions-book/appendixA/distribution.als
module appendixA/distribution

assert union {
	all s: set univ, p, q: univ->univ | s.(p+q) = s.p + s.q
}

check union for 4

// Model: software-abstractions-book/appendixA/phones.als
module appendixA/phones

sig Phone {
	requests: set Phone,
	connects: lone Phone
	}

// Model: software-abstractions-book/appendixA/prison.als
module appendixA/prison

sig Gang { members: set Inmate }

sig Inmate { room: Cell }

sig Cell { }

pred safe {
	// your constraints should go here
	}

pred show {
	// your constraints should go here
	}

run show

// Model: software-abstractions-book/appendixA/properties.als
module appendixA/properties

pred show {
	some r: univ->univ {
		some r			-- nonempty
		r.r in r			-- transitive
		no iden & r		-- irreflexive
		~r in r			-- symmetric
		~r.r in iden		-- functional
		r.~r in iden		-- injective
		univ in r.univ	-- total
		univ in univ.r	-- onto
		}
	}

run show for 4

assert ReformulateNonEmptinessOK {
	all r: univ->univ |
		some r iff (some x, y: univ | x->y in r)
	}

check ReformulateNonEmptinessOK

// Model: software-abstractions-book/appendixA/ring.als
module appendixA/ring

sig Node { next: set Node }

pred isRing {
	// You have to fill in the appropriate formula here
}

run isRing for exactly 4 Node

// Model: software-abstractions-book/appendixA/spanning.als
module appendixA/spanning

pred isTree [r: univ->univ] {
	// You have to fill in the appropriate formula here
}

pred spans [r1, r2: univ->univ] {
	// You have to fill in the appropriate formula here
}

pred show [r, t1, t2: univ->univ] {
	spans [t1,r] and isTree [t1]
	spans [t2,r] and isTree [t2]
	t1 != t2
}

run show for 3

// Model: software-abstractions-book/appendixA/tree.als
module appendixA/tree

pred isTree [r:univ->univ] {
	// You have to fill in the appropriate formula here
}

run isTree for 4

// Model: software-abstractions-book/appendixA/tube.als
module appendixA/tube

abstract sig Station {
	jubilee, central, circle: set Station
	}

sig Jubilee, Central, Circle in Station {}

one sig
	Stanmore, BakerStreet, BondStreet, Westminster, Waterloo,
	WestRuislip, EalingBroadway, NorthActon, NottingHillGate,
	LiverpoolStreet, Epping
	extends Station {}

fact {
	// the constraints should go here
	}

pred show {}

run show

// Model: software-abstractions-book/appendixA/undirected.als
module appendixA/undirected

sig Node { adjs: set Node }

pred acyclic {
	adjs = ~adjs
	// You have to fill in additional formula here
}

run acyclic for 4


// Model: software-abstractions-book/chapter5/addressBook.als
module chapter5/addressBook --- the model in fig 5.1

abstract sig Target {}

sig Addr extends Target {}
sig Name extends Target {}
sig Book {addr: Name -> Target}

fact Acyclic {all b: Book | no n: Name | n in n.^(b.addr)}

pred add [b, b": Book, n: Name, t: Target] {
	b".addr = b.addr + n -> t
	}

// This command should produce an instance similar to Fig 5.2
run add for 3 but 2 Book

fun lookup [b: Book, n: Name]: set Addr {n.^(b.addr) & Addr}

assert addLocal {
	all b,b": Book, n,n": Name, t: Target |
		add [b,b",n,t] and n != n" => lookup [b,n"] = lookup [b",n"]
	}

// This command should produce a counterexample similar to Fig 5.3
check addLocal for 3 but 2 Book

// Model: software-abstractions-book/chapter5/lists.als
module chapter5/lists ---- page 157

some sig Element {}

abstract sig List {}
one sig EmptyList extends List {}
sig NonEmptyList extends List {
	element: Element,
	rest: List
	}

fact ListGenerator {
	all list: List, e: Element |
		some list": List | list".rest = list and list".element = e
	}

assert FalseAssertion {
	all list: List | list != list
	}

// This check finds no counterexample since
// the only possible counterexamples are infinite.
check FalseAssertion

// Model: software-abstractions-book/chapter5/sets1.als
module chapter5/sets1 ----- page 156

sig Set {
	elements: set Element
}

sig Element {}

assert Closed {
	all s0, s1: Set |
		some s2: Set |
			s2.elements = s0.elements + s1.elements
	}

// This check should produce a counterexample
check Closed

// Model: software-abstractions-book/chapter5/sets2.als
module chapter5/sets2 ----- page 157

sig Set {
	elements: set Element
}

sig Element {}

assert Closed {
	all s0, s1: Set |
		some s2: Set |
			s2.elements = s0.elements + s1.elements
	}

fact SetGenerator {
	some s: Set | no s.elements
	all s: Set, e: Element | some s": Set | s".elements = s.elements + e
	}

// This check should not produce a counterexample
check Closed for 4 Element, 16 Set

// Model: software-abstractions-book/chapter2/addressBook1a.als
module tour/addressBook1a ----- Page 6

sig Name, Addr { }

sig Book {
	addr: Name -> lone Addr
}

pred show { }

// This command generates an instance similar to Fig 2.1
run show for 3 but 1 Book

// Model: software-abstractions-book/chapter2/addressBook1b.als
module tour/addressBook1b ----- Page 8

sig Name, Addr { }

sig Book {
	addr: Name -> lone Addr
}

pred show [b: Book] {
	#b.addr > 1
}

// This command generates an instance similar to Fig 2.2
run show for 3 but 1 Book

// Model: software-abstractions-book/chapter2/addressBook1c.als
module tour/addressBook1c ----- Page 8

sig Name, Addr { }

sig Book {
	addr: Name -> lone Addr
}

pred show [b: Book] {
	#b.addr > 1
	some n: Name | #n.(b.addr) > 1
}

// This command should not find any instance.
run show for 3 but 1 Book

// Model: software-abstractions-book/chapter2/addressBook1d.als
module tour/addressBook1d ----- Page 9

sig Name, Addr { }

sig Book {
	addr: Name -> lone Addr
}

pred show [b: Book] {
	#b.addr > 1
	#Name.(b.addr) > 1
}

// This command generates an instance similar to Fig 2.3
run show for 3 but 1 Book

// Model: software-abstractions-book/chapter2/addressBook1e.als
module tour/addressBook1e ----- Page 11

sig Name, Addr { }

sig Book {
	addr: Name -> lone Addr
}

pred add [b, b": Book, n: Name, a: Addr] {
	b".addr = b.addr + n->a
}

// This command generates an instance similar to Fig 2.4
run add for 3 but 2 Book

// Model: software-abstractions-book/chapter2/addressBook1f.als
module tour/addressBook1f ----- Page 12

sig Name, Addr { }

sig Book {
	addr: Name -> lone Addr
}

pred add [b, b": Book, n: Name, a: Addr] {
	b".addr = b.addr + n->a
}

pred showAdd [b, b": Book, n: Name, a: Addr] {
	add [b, b", n, a]
	#Name.(b".addr) > 1
}

// This command generates an instance similar to Fig 2.5
run showAdd for 3 but 2 Book

// Model: software-abstractions-book/chapter2/addressBook1g.als
module tour/addressBook1g ----- Page 14

sig Name, Addr { }

sig Book {
	addr: Name -> lone Addr
}

pred add [b, b": Book, n: Name, a: Addr] {
	b".addr = b.addr + n->a
}

pred del [b, b": Book, n: Name] {
	b".addr = b.addr - n->Addr
}

fun lookup [b: Book, n: Name] : set Addr {
	n.(b.addr)
}

assert delUndoesAdd {
	all b, b", b"": Book, n: Name, a: Addr |
		add [b, b", n, a] and del [b", b"", n]
		implies
		b.addr = b"".addr
}

// This command generates an instance similar to Fig 2.6
check delUndoesAdd for 3

// Model: software-abstractions-book/chapter2/addressBook1h.als
module tour/addressBook1h ------- Page 14..16

sig Name, Addr { }

sig Book {
	addr: Name -> lone Addr
}

pred show [b: Book] {
	#b.addr > 1
	#Name.(b.addr) > 1
}
run show for 3 but 1 Book

pred add [b, b": Book, n: Name, a: Addr] {
	b".addr = b.addr + n->a
}

pred del [b, b": Book, n: Name] {
	b".addr = b.addr - n->Addr
}

fun lookup [b: Book, n: Name] : set Addr {
	n.(b.addr)
}

pred showAdd [b, b": Book, n: Name, a: Addr] {
	add [b, b", n, a]
	#Name.(b".addr) > 1
}
run showAdd for 3 but 2 Book

assert delUndoesAdd {
	all b, b", b"": Book, n: Name, a: Addr |
		no n.(b.addr) and add [b, b", n, a] and del [b", b"", n]
		implies
		b.addr = b"".addr
}

assert addIdempotent {
	all b, b", b"": Book, n: Name, a: Addr |
		add [b, b", n, a] and add [b", b"", n, a]
		implies
		b".addr = b"".addr
}

assert addLocal {
	all b, b": Book, n, n": Name, a: Addr |
		add [b, b", n, a] and n != n"
		implies
		lookup [b, n"] = lookup [b", n"]
}

// This command should not find any counterexample.
check delUndoesAdd for 3

// This command should not find any counterexample.
check delUndoesAdd for 10 but 3 Book

// This command should not find any counterexample.
check addIdempotent for 3

// This command should not find any counterexample.
check addLocal for 3 but 2 Book

// Model: software-abstractions-book/chapter2/addressBook2a.als
module tour/addressBook2a ----- Page 18

abstract sig Target { }
sig Addr extends Target { }
abstract sig Name extends Target { }

sig Alias, Group extends Name { }

sig Book {
	addr: Name->Target
}

pred show [b:Book]   { some b.addr }

// This command generates an instance similar to Fig 2.9
run show for 3 but 1 Book

// Model: software-abstractions-book/chapter2/addressBook2b.als
module tour/addressBook2b ----- Page 19

abstract sig Target { }
sig Addr extends Target { }
abstract sig Name extends Target { }

sig Alias, Group extends Name { }

sig Book {
	addr: Name->Target
} {
	no n: Name | n in n.^addr
}

pred show [b:Book]   { some b.addr }

// This command generates an instance similar to Fig 2.10
run show for 3 but 1 Book

// Model: software-abstractions-book/chapter2/addressBook2c.als
module tour/addressBook2c ----- Page 20

abstract sig Target { }
sig Addr extends Target { }
abstract sig Name extends Target { }

sig Alias, Group extends Name { }

sig Book {
	addr: Name->Target
} {
	no n: Name | n in n.^addr
}

pred show [b:Book]   { some Alias.(b.addr) }

// This command generates an instance similar to Fig 2.11
run show for 3 but 1 Book

// Model: software-abstractions-book/chapter2/addressBook2d.als
module tour/addressBook2d ----- Page 21

abstract sig Target { }
sig Addr extends Target { }
abstract sig Name extends Target { }

sig Alias, Group extends Name { }

sig Book {
	addr: Name->Target
} {
	no n: Name | n in n.^addr
	all a: Alias | lone a.addr
}

pred show [b:Book]   { some Alias.(b.addr) }

// This command generates an instance similar to Fig 2.12
run show for 3 but 1 Book

// Model: software-abstractions-book/chapter2/addressBook2e.als
module tour/addressBook2e --- this is the final model in Fig 2.14

abstract sig Target { }
sig Addr extends Target { }
abstract sig Name extends Target { }

sig Alias, Group extends Name { }

sig Book {
	names: set Name,
	addr: names->some Target
} {
	no n: Name | n in n.^addr
	all a: Alias | lone a.addr
}

pred add [b, b": Book, n: Name, t: Target] { b".addr = b.addr + n->t }
pred del [b, b": Book, n: Name, t: Target] { b".addr = b.addr - n->t }
fun lookup [b: Book, n: Name] : set Addr { n.^(b.addr) & Addr }

assert delUndoesAdd {
	all b, b", b"": Book, n: Name, t: Target |
		no n.(b.addr) and add [b, b", n, t] and del [b", b"", n, t]
		implies
		b.addr = b"".addr
}

// This should not find any counterexample.
check delUndoesAdd for 3

assert addIdempotent {
	all b, b", b"": Book, n: Name, t: Target |
		add [b, b", n, t] and add [b", b"", n, t]
		implies
		b".addr = b"".addr
}

// This should not find any counterexample.
check addIdempotent for 3

assert addLocal {
	all b, b": Book, n, n": Name, t: Target |
		add [b, b", n, t] and n != n"
		implies
		lookup [b, n"] = lookup [b", n"]
}

// This shows a counterexample similar to Fig 2.13
check addLocal for 3 but 2 Book

assert lookupYields {
	all b: Book, n: b.names | some lookup [b,n]
}

// This shows a counterexample similar to Fig 2.12
check lookupYields for 4 but 1 Book

// Model: software-abstractions-book/chapter2/addressBook3a.als
module tour/addressBook3a ----- Page 25

open util/ordering [Book] as BookOrder

abstract sig Target { }
sig Addr extends Target { }
abstract sig Name extends Target { }

sig Alias, Group extends Name { }

sig Book {
	names: set Name,
	addr: names->some Target
} {
	no n: Name | n in n.^addr
	all a: Alias | lone a.addr
}

pred add [b, b": Book, n: Name, t: Target] { b".addr = b.addr + n->t }
pred del [b, b": Book, n: Name, t: Target] { b".addr = b.addr - n->t }
fun lookup [b: Book, n: Name] : set Addr { n.^(b.addr) & Addr }

pred init [b: Book]  { no b.addr }

fact traces {
	init [first]
	all b: Book-last |
	  let b" = b.next |
	    some n: Name, t: Target |
	      add [b, b", n, t] or del [b, b", n, t]
}

------------------------------------------------------

pred show { }

// This command generates an instance similar to Fig 2.15
run show for 4

// Model: software-abstractions-book/chapter2/addressBook3b.als
module tour/addressBook3b ----- Page 26

open util/ordering [Book] as BookOrder

abstract sig Target { }
sig Addr extends Target { }
abstract sig Name extends Target { }

sig Alias, Group extends Name { }

sig Book {
	names: set Name,
	addr: names->some Target
} {
	no n: Name | n in n.^addr
	all a: Alias | lone a.addr
}

pred add [b, b": Book, n: Name, t: Target] { b".addr = b.addr + n->t }
pred del [b, b": Book, n: Name, t: Target] { b".addr = b.addr - n->t }
fun lookup [b: Book, n: Name] : set Addr { n.^(b.addr) & Addr }

pred init [b: Book]  { no b.addr }

fact traces {
	init [first]
	all b: Book-last |
	  let b" = b.next |
	    some n: Name, t: Target |
	      add [b, b", n, t] or del [b, b", n, t]
}

------------------------------------------------------

assert delUndoesAdd {
	all b, b", b"": Book, n: Name, t: Target |
		no n.(b.addr) and add [b, b", n, t] and del [b", b"", n, t]
		implies
		b.addr = b"".addr
}

// This should not find any counterexample.
check delUndoesAdd for 3

------------------------------------------------------

assert addIdempotent {
	all b, b", b"": Book, n: Name, t: Target |
		add [b, b", n, t] and add [b", b"", n, t]
		implies
		b".addr = b"".addr
}

// This should not find any counterexample.
check addIdempotent for 3

------------------------------------------------------

assert addLocal {
	all b, b": Book, n, n": Name, t: Target |
		add [b, b", n, t] and n != n"
		implies
		lookup [b, n"] = lookup [b", n"]
}

// This should not find any counterexample.
check addLocal for 3 but 2 Book

------------------------------------------------------

assert lookupYields {
	all b: Book, n: b.names | some lookup [b,n]
}

// This shows a counterexample similar to Fig 2.16
check lookupYields for 3 but 4 Book

// Model: software-abstractions-book/chapter2/addressBook3c.als
module tour/addressBook3c ----- Page 27

open util/ordering [Book] as BookOrder

abstract sig Target { }
sig Addr extends Target { }
abstract sig Name extends Target { }

sig Alias, Group extends Name { }

sig Book {
	names: set Name,
	addr: names->some Target
} {
	no n: Name | n in n.^addr
	all a: Alias | lone a.addr
}

pred add [b, b": Book, n: Name, t: Target] {
	t in Addr or some lookup [b, Name&t]
	b".addr = b.addr + n->t
}

pred del [b, b": Book, n: Name, t: Target] { b".addr = b.addr - n->t }

fun lookup [b: Book, n: Name] : set Addr { n.^(b.addr) & Addr }

pred init [b: Book]  { no b.addr }

fact traces {
	init [first]
	all b: Book-last |
	  let b" = b.next |
	    some n: Name, t: Target |
	      add [b, b", n, t] or del [b, b", n, t]
}

------------------------------------------------------

assert delUndoesAdd {
	all b, b", b"": Book, n: Name, t: Target |
		no n.(b.addr) and add [b, b", n, t] and del [b", b"", n, t]
		implies
		b.addr = b"".addr
}

// This should not find any counterexample.
check delUndoesAdd for 3

------------------------------------------------------

assert addIdempotent {
	all b, b", b"": Book, n: Name, t: Target |
		add [b, b", n, t] and add [b", b"", n, t]
		implies
		b".addr = b"".addr
}

// This should not find any counterexample.
check addIdempotent for 3

------------------------------------------------------

assert addLocal {
	all b, b": Book, n, n": Name, t: Target |
		add [b, b", n, t] and n != n"
		implies
		lookup [b, n"] = lookup [b", n"]
}

// This should not find any counterexample.
check addLocal for 3 but 2 Book

------------------------------------------------------

assert lookupYields {
	all b: Book, n: b.names | some lookup [b,n]
}

// This shows a counterexample similar to Fig 2.17
check lookupYields for 3 but 4 Book

// Model: software-abstractions-book/chapter2/addressBook3d.als
module tour/addressBook3d ----- this is the final model in fig 2.18

open util/ordering [Book] as BookOrder

abstract sig Target { }
sig Addr extends Target { }
abstract sig Name extends Target { }

sig Alias, Group extends Name { }

sig Book {
	names: set Name,
	addr: names->some Target
} {
	no n: Name | n in n.^addr
	all a: Alias | lone a.addr
}

pred add [b, b": Book, n: Name, t: Target] {
	t in Addr or some lookup [b, Name&t]
	b".addr = b.addr + n->t
}

pred del [b, b": Book, n: Name, t: Target] {
	no b.addr.n or some n.(b.addr) - t
	b".addr = b.addr - n->t
}

fun lookup [b: Book, n: Name] : set Addr { n.^(b.addr) & Addr }

pred init [b: Book]  { no b.addr }

fact traces {
	init [first]
	all b: Book-last |
	  let b" = b.next |
	    some n: Name, t: Target |
	      add [b, b", n, t] or del [b, b", n, t]
}

------------------------------------------------------

assert delUndoesAdd {
	all b, b", b"": Book, n: Name, t: Target |
		no n.(b.addr) and add [b, b", n, t] and del [b", b"", n, t]
		implies
		b.addr = b"".addr
}

// This should not find any counterexample.
check delUndoesAdd for 3

------------------------------------------------------

assert addIdempotent {
	all b, b", b"": Book, n: Name, t: Target |
		add [b, b", n, t] and add [b", b"", n, t]
		implies
		b".addr = b"".addr
}

// This should not find any counterexample.
check addIdempotent for 3

------------------------------------------------------

assert addLocal {
	all b, b": Book, n, n": Name, t: Target |
		add [b, b", n, t] and n != n"
		implies
		lookup [b, n"] = lookup [b", n"]
}

// This should not find any counterexample.
check addLocal for 3 but 2 Book

------------------------------------------------------

assert lookupYields {
	all b: Book, n: b.names | some lookup [b,n]
}

// This should not find any counterexample.
check lookupYields for 3 but 4 Book

// This should not find any counterexample.
check lookupYields for 6

// Model: software-abstractions-book/chapter4/filesystem.als
module chapter4/filesystem ----- The model from page 125

abstract sig Object {}

sig Dir extends Object {contents: set Object}

one sig Root extends Dir { }

sig File extends Object {}

fact {
	Object in Root.*contents
	}

assert SomeDir {
	all o: Object - Root | some contents.o
	}
check SomeDir // This assertion is valid

assert RootTop {
	no o: Object | Root in o.contents
	}
check RootTop // This assertion should produce a counterexample

assert FileInDir {
	all f: File | some contents.f
	}
check FileInDir // This assertion is valid

// Model: software-abstractions-book/chapter4/grandpa1.als
module language/grandpa1 ---- Page 84, 85

abstract sig Person {
	father: lone Man,
	mother: lone Woman
	}

sig Man extends Person {
	wife: lone Woman
	}

sig Woman extends Person {
	husband: lone Man
	}

fact {
	no p: Person | p in p.^(mother+father)
	wife = ~husband
	}

assert NoSelfFather {
	no m: Man | m = m.father
	}

// This should not find any counterexample.
check NoSelfFather

fun grandpas [p: Person] : set Person {
	p.(mother+father).father
	}

pred ownGrandpa [p: Person] {
	p in p.grandpas
	}

// This should not find any instance.
run ownGrandpa for 4 Person

assert NoSelfGrandpa {
	no p: Person | p in p.grandpas
	}

// This should not find any counterexample
check NoSelfGrandpa for 4 Person

// Model: software-abstractions-book/chapter4/grandpa2.als
module language/grandpa2 ---- Page 86

abstract sig Person {
	father: lone Man,
	mother: lone Woman
	}

sig Man extends Person {
	wife: lone Woman
	}

sig Woman extends Person {
	husband: lone Man
	}

fact {
	no p: Person | p in p.^(mother+father)
	wife = ~husband
	}

assert NoSelfFather {
	no m: Man | m = m.father
	}

// This should not find any counterexample.
check NoSelfFather

fun grandpas [p: Person] : set Person {
	let parent = mother + father + father.wife + mother.husband |
		p.parent.parent & Man
	}

pred ownGrandpa [p: Person] {
	p in p.grandpas
	}

// This generates an instance similar to Fig 4.2
run ownGrandpa for 4 Person

// Model: software-abstractions-book/chapter4/grandpa3.als
module language/grandpa3 ---- the final model in fig 4.4

abstract sig Person {
	father: lone Man,
	mother: lone Woman
	}

sig Man extends Person {
	wife: lone Woman
	}

sig Woman extends Person {
	husband: lone Man
	}

fact Biology {
	no p: Person | p in p.^(mother+father)
	}

fact Terminology {
	wife = ~husband
	}

fact SocialConvention {
	no (wife+husband) & ^(mother+father)
	}

------------------------------------------

assert NoSelfFather {
	no m: Man | m = m.father
	}

// This should not find any counterexample.
check NoSelfFather

------------------------------------------

fun grandpas [p: Person] : set Person {
	let parent = mother + father + father.wife + mother.husband |
		p.parent.parent & Man
	}

pred ownGrandpa [p: Person] {
	p in p.grandpas
	}

// This generates an instance similar to Fig 4.3
run ownGrandpa for 4 Person

------------------------------------------

pred SocialConvention1 {
	no (wife + husband) & ^(mother + father)
	}

pred SocialConvention2 {
	let parent = mother + father {
		no m: Man | some m.wife and m.wife in m.*parent.mother
		no w: Woman | some w.husband and w.husband in w.*parent.father
		}
	}

// This assertion was described on page 90.
assert Same {
	SocialConvention1 iff SocialConvention2
	}

// This should not find any counterexample
check Same

// Model: software-abstractions-book/chapter4/lights.als
module chapter4/lights ----- The model from page 127

abstract sig Color {}

one sig Red, Yellow, Green extends Color {}

fun colorSequence: Color -> Color {
	Color <: iden + Red->Green + Green->Yellow + Yellow->Red
	}

sig Light {}
sig LightState {color: Light -> one Color}
sig Junction {lights: set Light}

fun redLights [s: LightState]: set Light { s.color.Red }

pred mostlyRed [s: LightState, j: Junction] {
	lone j.lights - redLights[s]
	}

pred trans [s, s": LightState, j: Junction] {
	lone x: j.lights | s.color[x] != s".color[x]
	all x: j.lights |
		let step = s.color[x] -> s".color[x] {
			step in colorSequence
			step in Red->(Color-Red) => j.lights in redLights[s]
		}
	}

assert Safe {
	all s, s": LightState, j: Junction |
		mostlyRed [s, j] and trans [s, s", j] => mostlyRed [s", j]
	}

check Safe for 3 but 1 Junction

//assert ColorSequenceDeterministic {
//	all c: Color | lone c.colorSequence
//	}
//
//check ColorSequenceDeterministic

// Model: software-abstractions-book/appendixE/p300-hotel.als
module hotel

open util/ordering [Time] as timeOrder

sig Key, Time {}

sig Card {
	fst, snd: Key
	}

sig Room {
	key: Key one->Time
	}

one sig Desk {
	issued: Key->Time,
	prev: (Room->lone Key)->Time
	}

sig Guest {
	cards: Card->Time
	}

pred init [t: Time] {
	Desk.prev.t = key.t
	no issued.t and no cards.t ------ bug! (see page 303)
	}

pred checkin [t,t": Time, r: Room, g: Guest] {
	some c: Card {
		c.fst = r.(Desk.prev.t)
		c.snd not in Desk.issued.t
		cards.t" = cards.t + g->c ------------- bug! (see page 306)
		Desk.issued.t" = Desk.issued.t + c.snd
		Desk.prev.t" = Desk.prev.t ++ r->c.snd
		}
	key.t = key.t"
	}

pred enter [t,t": Time, r: Room, g: Guest] {
	some c: g.cards.t |
		let k = r.key.t {
			c.snd = k and key.t" = key.t
			or c.fst = k and key.t" = key.t ++ r->c.snd
			}
	issued.t = issued.t" and (Desk<:prev).t = prev.t"
	cards.t = cards.t"
	}

fact Traces {
	init [first]
	all t: Time - last | some g: Guest, r: Room |
		checkin [t, t.next, r, g] or enter[t, t.next, r, g]
	}

assert NoIntruder {
	no t1: Time, g: Guest, g": Guest-g, r: Room |
		let t2=t1.next, t3=t2.next, t4=t3.next {
			enter [t1, t2, r, g]
			enter [t2, t3, r, g"]
			enter [t3, t4, r, g]
		}
	}

-- This check reveals a bug (similar to Fig E.3) in which the initial key was issued twice.
check NoIntruder for 3 but 6 Time, 1 Room, 2 Guest

// Model: software-abstractions-book/appendixE/p303-hotel.als
module hotel

open util/ordering [Time] as timeOrder

sig Key, Time {}

sig Card {
	fst, snd: Key
	}

sig Room {
	key: Key one->Time
	}

one sig Desk {
	issued: Key->Time,
	prev: (Room->lone Key)->Time
	}

sig Guest {
	cards: Card->Time
	}

pred init [t: Time] {
	Desk.prev.t = key.t
	Desk.issued.t = Room.key.t and no cards.t
	}

pred checkin [t,t": Time, r: Room, g: Guest] {
	some c: Card {
		c.fst = r.(Desk.prev.t)
		c.snd not in Desk.issued.t
		cards.t" = cards.t + g->c ------------- bug! (see page 306)
		Desk.issued.t" = Desk.issued.t + c.snd
		Desk.prev.t" = Desk.prev.t ++ r->c.snd
		}
	key.t = key.t"
	}

pred enter [t,t": Time, r: Room, g: Guest] {
	some c: g.cards.t |
		let k = r.key.t {
			c.snd = k and key.t" = key.t
			or c.fst = k and key.t" = key.t ++ r->c.snd
			}
	issued.t = issued.t" and (Desk<:prev).t = prev.t"
	cards.t = cards.t"
	}

fact Traces {
	init [first]
	all t: Time - last | some g: Guest, r: Room |
		checkin [t, t.next, r, g] or enter[t, t.next, r, g]
	}

assert NoIntruder {
	no t1: Time, g: Guest, g": Guest-g, r: Room |
		let t2=t1.next, t3=t2.next, t4=t3.next {
			enter [t1, t2, r, g]
			enter [t2, t3, r, g"]
			enter [t3, t4, r, g]
		}
	}

-- This check now succeeds without finding any counterexample.
check NoIntruder for 3 but 6 Time, 1 Room, 2 Guest

-- To increase our confidence, we can increase the scope.
-- This time, it finds a counterexample.
check NoIntruder for 4 but 7 Time, 1 Room, 2 Guest

// Model: software-abstractions-book/appendixE/p306-hotel.als
module hotel

open util/ordering [Time] as timeOrder

sig Key, Time {}

sig Card {
	fst, snd: Key
	}

sig Room {
	key: Key one->Time
	}

one sig Desk {
	issued: Key->Time,
	prev: (Room->lone Key)->Time
	}

sig Guest {
	cards: Card->Time
	}

pred init [t: Time] {
	Desk.prev.t = key.t
	Desk.issued.t = Room.key.t and no cards.t
	}

pred checkin [t,t": Time, r: Room, g: Guest] {
	some c: Card {
		c.fst = r.(Desk.prev.t)
		c.snd not in Desk.issued.t
		cards.t" = cards.t ++ g->c
		Desk.issued.t" = Desk.issued.t + c.snd
		Desk.prev.t" = Desk.prev.t ++ r->c.snd
		}
	key.t = key.t"
	}

pred enter [t,t": Time, r: Room, g: Guest] {
	some c: g.cards.t |
		let k = r.key.t {
			c.snd = k and key.t" = key.t
			or c.fst = k and key.t" = key.t ++ r->c.snd
			}
	issued.t = issued.t" and (Desk<:prev).t = prev.t"
	cards.t = cards.t"
	}

fact Traces {
	init [first]
	all t: Time - last | some g: Guest, r: Room |
		checkin [t, t.next, r, g] or enter[t, t.next, r, g]
	}

assert NoIntruder {
	no t1: Time, g: Guest, g": Guest-g, r: Room |
		let t2=t1.next, t3=t2.next, t4=t3.next {
			enter [t1, t2, r, g]
			enter [t2, t3, r, g"]
			enter [t3, t4, r, g]
		}
	}

-- This check now succeeds without finding any counterexample.
check NoIntruder for 3 but 6 Time, 1 Room, 2 Guest

-- This check now succeeds without finding any counterexample.
check NoIntruder for 4 but 7 Time, 1 Room, 2 Guest

-- We can try to increase the scope further.
-- This check also succeeds without finding any counterexample.
check NoIntruder for 6 but 12 Time, 3 Room, 3 Guest

// Model: algorithms/mapping/view-backing.als
/*
 * Model of views in object-oriented programming.
 *
 * Two object references, called the view and the backing,
 * are related by a view mechanism when changes to the
 * backing are automatically propagated to the view. Note
 * that the state of a view need not be a projection of the
 * state of the backing; the keySet method of Map, for
 * example, produces two view relationships, and for the
 * one in which the map is modified by changes to the key
 * set, the value of the new map cannot be determined from
 * the key set. Note that in the iterator view mechanism,
 * the iterator is by this definition the backing object,
 * since changes are propagated from iterator to collection
 * and not vice versa. Oddly, a reference may be a view of
 * more than one backing: there can be two iterators on the
 * same collection, eg. A reference cannot be a view under
 * more than one view type.
 *
 * A reference is made dirty when it is a backing for a view
 * with which it is no longer related by the view invariant.
 * This usually happens when a view is modified, either
 * directly or via another backing. For example, changing a
 * collection directly when it has an iterator invalidates
 * it, as does changing the collection through one iterator
 * when there are others.
 *
 * More work is needed if we want to model more closely the
 * failure of an iterator when its collection is invalidated.
 *
 * As a terminological convention, when there are two
 * complementary view relationships, we will give them types
 * t and t". For example, KeySetView propagates from map to
 * set, and KeySetView" propagates from set to map.
 *
 * author: Daniel Jackson
 */

open util/ordering[State] as so
open util/relation as rel

sig Ref {}
sig Object {}

-- t->b->v in views when v is view of type t of backing b
-- dirty contains refs that have been invalidated
sig State {
  refs: set Ref,
  obj: refs -> one Object,
  views: ViewType -> refs -> refs,
  dirty: set refs
--  , anyviews: Ref -> Ref -- for visualization
  }
-- {anyviews = ViewType.views}

sig Map extends Object {
  keys: set Ref,
  map: keys -> one Ref
  }{all s: State |  keys + Ref.map in s.refs}
sig MapRef extends Ref {}
fact {State.obj[MapRef] in Map}

sig Iterator extends Object {
  left, done: set Ref,
  lastRef: lone done
  }{all s: State | done + left + lastRef in s.refs}
sig IteratorRef extends Ref {}
fact {State.obj[IteratorRef] in Iterator}

sig Set extends Object {
  elts: set Ref
  }{all s: State | elts in s.refs}
sig SetRef extends Ref {}
fact {State.obj[SetRef] in Set}

abstract sig ViewType {}
one sig KeySetView, KeySetView", IteratorView extends ViewType {}
fact ViewTypes {
  State.views[KeySetView] in MapRef -> SetRef
  State.views[KeySetView"] in SetRef -> MapRef
  State.views[IteratorView] in IteratorRef -> SetRef
  all s: State | s.views[KeySetView] = ~(s.views[KeySetView"])
  }

/**
 * mods is refs modified directly or by view mechanism
 * doesn't handle possibility of modifying an object and its view at once?
 * should we limit frame conds to non-dirty refs?
 */
pred modifies [pre, post: State, rs: set Ref] {
  let vr = pre.views[ViewType], mods = rs.*vr {
    all r: pre.refs - mods | pre.obj[r] = post.obj[r]
    all b: mods, v: pre.refs, t: ViewType |
      b->v in pre.views[t] => viewFrame [t, pre.obj[v], post.obj[v], post.obj[b]]
    post.dirty = pre.dirty +
      {b: pre.refs | some v: Ref, t: ViewType |
          b->v in pre.views[t] && !viewFrame [t, pre.obj[v], post.obj[v], post.obj[b]]
      }
    }
  }

pred allocates [pre, post: State, rs: set Ref] {
  no rs & pre.refs
  post.refs = pre.refs + rs
  }

/** 
 * models frame condition that limits change to view object from v to v" when backing object changes to b"
 */
pred viewFrame [t: ViewType, v, v", b": Object] {
  t in KeySetView => v".elts = dom [b".map]
  t in KeySetView" => b".elts = dom [v".map]
  t in KeySetView" => (b".elts) <: (v.map) = (b".elts) <: (v".map)
  t in IteratorView => v".elts = b".left + b".done
  }

pred MapRef.keySet [pre, post: State, setRefs: SetRef] {
  post.obj[setRefs].elts = dom [pre.obj[this].map]
  modifies [pre, post, none]
  allocates [pre, post, setRefs]
  post.views = pre.views + KeySetView->this->setRefs + KeySetView"->setRefs->this
  }

pred MapRef.put [pre, post: State, k, v: Ref] {
  post.obj[this].map = pre.obj[this].map ++ k->v
  modifies [pre, post, this]
  allocates [pre, post, none]
  post.views = pre.views
  }

pred SetRef.iterator [pre, post: State, iterRef: IteratorRef] {
  let i = post.obj[iterRef] {
    i.left = pre.obj[this].elts
    no i.done + i.lastRef
    }
  modifies [pre,post,none]
  allocates [pre, post, iterRef]
  post.views = pre.views + IteratorView->iterRef->this
  }

pred IteratorRef.remove [pre, post: State] {
  let i = pre.obj[this], i" = post.obj[this] {
    i".left = i.left
    i".done = i.done - i.lastRef
    no i".lastRef
    }
  modifies [pre,post,this]
  allocates [pre, post, none]
  pre.views = post.views
  }

pred IteratorRef.next [pre, post: State, ref: Ref] {
  let i = pre.obj[this], i" = post.obj[this] {
    ref in i.left
    i".left = i.left - ref
    i".done = i.done + ref
    i".lastRef = ref
    }
  modifies [pre, post, this]
  allocates [pre, post, none]
  pre.views = post.views
  }

pred IteratorRef.hasNext [s: State] {
  some s.obj[this].left
  }

assert zippishOK {
  all
    ks, vs: SetRef,
    m: MapRef,
    ki, vi: IteratorRef,
    k, v: Ref |
    let s0=so/first,
    s1=so/next[s0],
    s2=so/next[s1],
    s3=so/next[s2],
    s4=so/next[s3],
    s5=so/next[s4],
    s6=so/next[s5],
    s7=so/next[s6] |
  ({
    precondition [s0, ks, vs, m]
    no s0.dirty
    ks.iterator [s0, s1, ki]
    vs.iterator [s1, s2, vi]
    ki.hasNext [s2]
    vi.hasNext [s2]
    ki.this/next [s2, s3, k]
    vi.this/next [s3, s4, v]
    m.put [s4, s5, k, v]
    ki.remove [s5, s6]
    vi.remove [s6, s7]
  } => no State.dirty)
  }

pred precondition [pre: State, ks, vs, m: Ref] {
  // all these conditions and other errors discovered in scope of 6 but 8,3
  // in initial state, must have view invariants hold
  (all t: ViewType, b, v: pre.refs |
    b->v in pre.views[t] => viewFrame [t, pre.obj[v], pre.obj[v], pre.obj[b]])
  // sets are not aliases
--  ks != vs
  // sets are not views of map
--  no (ks+vs)->m & ViewType.pre.views
  // no iterator currently on either set
--  no Ref->(ks+vs) & ViewType.pre.views
  }

check zippishOK for 6 but 8 State, 3 ViewType expect 1

/** 
 * experiment with controlling heap size
 */
fact {all s: State | #s.obj < 5}

// Model: algorithms/distributed-hashtable/chord.als
/*
 * Models the chord distributed hash table lookup protocol.
 *
 * For a detailed description, see:
 *
 * Chord: A Scalable Peer-to-peer Lookup Service for Internet Applications
 * Ion Stoica, Robert Morris, David Karger, M. Frans Kaashoek, and Hari Balakrishnan.
 *
 */

open util/relation as rel

sig Id {next: Id}
fact {all i: Id | Id in i.*next}

/**
 * true iff i precedes j in the order starting at from
 */
pred less_than [from, i,j: Id] {
        let next" = Id<:next - (Id->from) | j in i.^next"  // if from=j, returns true if # nodes > 1
        }
pred less_than_eq [from, i,j: Id] {
        let next" = Id<:next - (Id->from) | j in i.*next"
        }

sig Node {id: Id}
fact {all m,n: Node | m!=n => m.id != n.id}


sig NodeData {
        prev, next: Node,
        finger: Id -> lone Node,
        closest_preceding_finger: Id -> one Node,
        find_predecessor: Id -> one Node,
        find_successor: Id -> one Node
        }

sig State {
        active: set Node,
        data: active -> one NodeData
        }

/**
 * node n"s next node is defined to be the m where n"s finger table maps the id
 * that follows n.id to m
 * next holds the first entry of the finger table
 */
fact {all s: State | all n: s.active | n.(s.data).next = n.(s.data).finger[n.id.next]}

pred NextCorrect [s: State] {
        all n: s.active {
                -- no intervening node (ie, close enough)
                no n": s.active - n | less_than [n.id, n".id, n.(s.data).next.id]
                -- can reach all other active nodes (ie, far enough)
                -- need this because can"t rule out case of next being node itself (because of 1-node ring)
                -- s.active in n.*(s.data.next)
                n.(s.data).next != n || #s.active = 1
                }
        }

pred NextCorrect" [s: State] {
-- next seems to be correct for 1,2,3 nodes
        all n: s.active | let nd = (s.data)[n] {
                let next" = Id<:next - (Id -> nd.next.id) {
                        no n" : s.active { n".id in n.id.^next" }
                }}
        }

// valid
assert Same1 {all s: State | NextCorrect[s] => NextCorrect"[s]}
check Same1 for 3 but 1 State expect 0

// valid unless active condition removed
assert Same2 {all s: State | s.active = Node => (NextCorrect"[s] => NextCorrect[s])}
check Same2 for 3 but 1 State expect 0

-- assert NextInFinger {all s: State | all n: s.active | some n.s.data.finger[n.id.next] }


-- says that finger entry maps an id to a node so that there are no intervening nodes
-- between the id and the node
pred FingersCorrect [s: State] {
        all nd: s.active.(s.data) | all start:nd.finger.univ |
                nd.finger[start] in s.active &&
                (no n" : s.active | less_than [start, n".id, nd.finger[start].id])
        }


pred FingersCorrect" [s: State] {
        all n: s.active | let nd = (s.data)[n] | all start: Node.~(nd.finger) {
                nd.finger[start] in s.active &&
                (let next" = Id<:next - (nd.finger[start].id -> Id) {
                        no n" : s.active - nd.finger[start] {
                                n".id in start.*next"
                        }
                })
            }
        }


assert SameFC {all s: State | FingersCorrect [s] iff FingersCorrect"[s]}
check SameFC for 3 but 1 State expect 0


pred ShowMeFC {
        all s : State | s.active = Node && FingersCorrect[s]
}

run ShowMeFC for 2 but 1 State expect 1

pred ClosestPrecedingFinger[s: State] {
        all n: s.active | let nd = n.(s.data) |
                all i: Id | let cpf = nd.closest_preceding_finger[i] {
                        no n": nd.finger[Id] + n - cpf | less_than [cpf.id, n".id, i]
                        cpf in nd.finger[Id] + n
                        cpf.id != i || # s.active = 1
                        //less_than (n.id, cpf.id, i)
                }
        }


pred ClosestPrecedingFinger"[s: State] {
        all n: s.active | let nd = (s.data)[n] | all i: Id {
                let next" = Id<:next - (Id -> i) {
                        nd.next.id in n.id.^next" =>
                                // nd.closest_preceding_finger[i] = nd.next,
                                (some n1: nd.finger[Id] {
                                        nd.closest_preceding_finger[i] = n1
                                        //n1 in nd.finger[Id]
                                        n1.id in n.id.^next"
                                        no n2: nd.finger[Id] | n2.id in n1.id.^next"
                                }) else
                        nd.closest_preceding_finger[i] = n
                }}
        }


assert SameCPF {all s: State | FingersCorrect[s] => (ClosestPrecedingFinger [s] iff ClosestPrecedingFinger" [s])}
assert SameCPF1 {all s: State | FingersCorrect[s] => (ClosestPrecedingFinger [s] => ClosestPrecedingFinger" [s])}
assert SameCPF2 {
        all s: State | ((s.active = Node && FingersCorrect[s] && ClosestPrecedingFinger" [s])
         => ClosestPrecedingFinger [s]) }

check SameCPF for 3 but 1 State expect 0
check SameCPF1 for 2 but 1 State expect 0
check SameCPF2 for 3 but 1 State expect 0


pred ShowMeCPF {
        all s : State | s.active = Node && FingersCorrect[s] &&
        // not ClosestPrecedingFinger(s) && ClosestPrecedingFinger"(s)
        ClosestPrecedingFinger[s]
        //all s : State | all nd : s.active.s.data | nd.finger[Id] = Node
        # Node = 2
        # State = 1
}


run ShowMeCPF for 2 but 1 State expect 1


pred FindPredecessor[s: State] {
        all n: s.active | let nd = n.(s.data) | all i: Id {
                nd.find_predecessor[i] =
                        (less_than_eq [n.id, i, nd.next.id] && (n.id != i || # s.active = 1)
                        => n
                        else (nd.closest_preceding_finger[i].(s.data).find_predecessor)[i])
                }
        }


assert FPisActive {
        all s: State | FingersCorrect[s] && ClosestPrecedingFinger[s] && FindPredecessor[s]
        => (all n: s.active | all nd: n.(s.data) | nd.find_predecessor[Id] in s.active) }
check FPisActive for 3 but 1 State expect 1


pred FindPredecessor"[s: State] {
        all n: s.active | let nd = (s.data)[n] | all i: Id {
                let next" = Id<:next - (nd.next.id -> Id) {
                        one s.active or i in n.id.^next" =>  // *next" -> ^next" 1/8/02
                        nd.find_predecessor[i] = n else
                        nd.find_predecessor[i] =
                        ((s.data)[nd.closest_preceding_finger[i]]).find_predecessor[i]
                }}
        }


assert SameFP {all s: State | FingersCorrect[s] // && s.active = Node
        => (FindPredecessor [s] iff FindPredecessor" [s])}

assert SameFP1 {
        all s: State | FingersCorrect[s] && s.active = Node
                => (FindPredecessor [s] => FindPredecessor" [s])}
assert SameFP2 {
        all s: State | FingersCorrect[s] && s.active = Node
                => (FindPredecessor" [s] => FindPredecessor [s])}

check SameFP for 3 but 1 State expect 1
check SameFP1 for 3 but 1 State expect 0
check SameFP2 for 3 but 1 State expect 0


pred FindSuccessor[s: State] {
        all n: s.active | let nd = (s.data)[n] | all i: Id {
                nd.find_successor[i] = ((s.data)[nd.find_predecessor[i]]).next
        }}


// should be able to check that closest_p_f, etc returns
// only active nodes if FingersCorrect.


pred ShowMe1Node  {
        #Node = 1
        all s : State | NextCorrect[s]
        State.active = Node
}

run ShowMe1Node for 2 but 1 State, 1 Node expect 1

pred ShowMe1  {
        #Node = 2
        #State = 1
        all s : State | NextCorrect[s]
        State.active = Node
}


pred ShowMe2  {
        #Node = 3
        #State = 1
        all s : State | NextCorrect[s] && FingersCorrect[s]
        State.active = Node
        //all n: NodeData | one n.finger[Id]
}


assert OK1 {
        #Node = 3 &&
        #State = 1 &&
        (all s : State | NextCorrect[s] && FingersCorrect[s]) &&
        State.active = Node
}


run ShowMe1 for 3 expect 1
run ShowMe2 for 3 expect 1

assert InjectiveIds {all i, j: Id | i!=j => i.next != j.next}
check InjectiveIds for 5 expect 0


assert FindSuccessorWorks {
        all s: State, i: Id |
                let nd = s.active.(s.data) |
                let succ = nd.find_successor [i] |
                        FingersCorrect [s] // && s.active = Node
                                => (no n": s.active | less_than [i, n".id, succ.id])
        }
check FindSuccessorWorks for 3 but 1 State expect 1

// Model: algorithms/distributed-hashtable/chord2.als

/*
 * Models the chord distributed hash table lookup protocol.
 *
 * For a detailed description, see:
 *
 * Chord: A Scalable Peer-to-peer Lookup Service for Internet Applications
 * Ion Stoica, Robert Morris, David Karger, M. Frans Kaashoek, and Hari Balakrishnan.
 *
 */

open util/relation as rel

sig Id {next: Id}
fact {all i: Id | Id in i.*next}

/**
 * true iff i precedes j in the order starting at from
 */
pred less_than [from, i,j: Id] {
  let next" = Id<:next - (Id->from) | j in i.^next"  // if from=j, returns true if # nodes > 1
  }
pred less_than_eq [from, i,j: Id] {
  let next" = Id<:next - (Id->from) | j in i.*next"
  }

sig Node {id: Id}
fact {all m,n: Node | m!=n => m.id != n.id}

sig NodeData {
  prev, next: Node,
  finger: Id -> lone Node,
  closest_preceding_finger: Id -> one Node,
  find_predecessor: Id -> one Node,
  find_successor: Id -> one Node
  }

sig State {
  active: set Node,
  data: active -> one NodeData
  }

/**
 * node n"s next node is defined to be the m where n"s finger table maps the id
 * that follows n.id to m
 * next holds the first entry of the finger table
 */
fact {all s: State | all n: s.active | n.(s.data).next = n.(s.data).finger[n.id.next]}

pred NextCorrect [s: State] {
  all n: s.active {
    -- no intervening node (ie, close enough)
    no n": s.active - n | less_than [n.id, n".id, n.(s.data).next.id]
    -- can reach all other active nodes (ie, far enough)
    -- need this because can"t rule out case of next being node itself (because of 1-node ring)
    -- s.active in n.*(s.data.next)
    n.(s.data).next != n || #s.active = 1
    }
  }

/*
-- abortive attempt at simplifying next condition
fun NextCorrect" (s: State) {
  all n: s.active | let nx = s.data.next {
    s.active in n.*nx
    less_than (n.id, n.id, n.nx.id)
    }
  }
*/

pred NextCorrect" [s: State] {
-- next seems to be correct for 1,2,3 nodes
  all n: s.active | let nd = (s.data)[n] {
    let next" = Id<:next - (Id -> nd.next.id) {
      no n" : s.active { n".id in n.id.^next" }
    }}
  }

assert Same1 {all s: State | NextCorrect[s] => NextCorrect"[s]}
//check Same1 for 3 but 1 State -- valid
assert Same2 {all s: State | s.active = Node => (NextCorrect"[s] => NextCorrect[s])}
//check Same2 for 3 but 1 State -- invalid if active condition removed

-- assert NextInFinger {all s: State | all n: s.active | some n.s.data.finger[n.id.next] }

/**
 * says that finger entry maps an id to a node so that there are no intervening nodes
 * between the id and the node
 */
pred FingersCorrect [s: State] {
  all nd: s.active.(s.data) | all start:nd.finger.univ |
    nd.finger[start] in s.active &&
    (no n" : s.active | less_than [start, n".id, nd.finger[start].id])
  }

pred FingersCorrect" [s: State] {
  all n: s.active | let nd = (s.data)[n] | all start: Node.~(nd.finger) {
    nd.finger[start] in s.active &&
    (let next" = Id<:next - (nd.finger[start].id -> Id) {
      no n" : s.active - nd.finger[start] {
        n".id in start.*next"
    }})}
  }

assert SameFC {all s: State | FingersCorrect [s] iff FingersCorrect"[s]}
//check SameFC for 3 but 1 State

pred ShowMeFC {
  all s : State | s.active = Node && FingersCorrect[s]
}

//run ShowMeFC for 2 but 1 State

/*
fun ClosestPrecedingFinger(s: State) {
  all n: s.active | let nd = n.s.data |
    all i: Id | let cpf = nd.closest_preceding_finger[i] {
      no n": nd.finger[Id] | less_than (cpf.id, n".id, i)
      cpf in nd.finger[Id] + n
      less_than (n.id, cpf.id, i)
    }
  }
*/

pred ClosestPrecedingFinger_SAVE [s: State] {
  all n: s.active | let nd = n.(s.data) |
    all i: Id | let cpf = nd.closest_preceding_finger[i] {
      no n": (nd.finger[Id] + n) - cpf | less_than [cpf.id, n".id, i]
      cpf in nd.finger[Id] + n
      cpf.id != i || # s.active = 1
      //less_than (n.id, cpf.id, i)
    }
  }

pred CPFBody [s: State, n: Node, nd: NodeData, i: Id, cpf: Node] {
  no n": (nd.finger[Id] + n) - cpf | less_than [cpf.id, n".id, i]
  cpf in nd.finger[Id] + n
  cpf.id != i || # s.active = 1
  }
pred ClosestPrecedingFinger[s: State] {
  all n: s.active | let nd = n.(s.data) |
    all i: Id |
    some cpf: Node | CPFBody [s,n,nd,i,cpf] => CPFBody [s,n,nd,i,nd.closest_preceding_finger[i]]
  }

pred ClosestPrecedingFinger"[s: State] {
  all n: s.active | let nd = (s.data)[n] | all i: Id {
    let next" = Id<:next - (Id -> i) {
      nd.next.id in n.id.^next" =>
        // nd.closest_preceding_finger[i] = nd.next,
        (some n1: nd.finger[Id] {
          nd.closest_preceding_finger[i] = n1
          //n1 in nd.finger[Id]
          n1.id in n.id.^next"
          no n2: nd.finger[Id] | n2.id in n1.id.^next"
        }) else
      nd.closest_preceding_finger[i] = n
    }}
  }

assert SameCPF {all s: State | FingersCorrect[s] => (ClosestPrecedingFinger [s] iff ClosestPrecedingFinger" [s])}
assert SameCPF1 {all s: State | FingersCorrect[s] => (ClosestPrecedingFinger [s] => ClosestPrecedingFinger" [s])}
assert SameCPF2 {
  all s: State | ((s.active = Node && FingersCorrect[s] && ClosestPrecedingFinger" [s])
   => ClosestPrecedingFinger [s]) }
//check SameCPF for 3 but 1 State
//check SameCPF1 for 2 but 1 State
//check SameCPF2 for 3 but 1 State

pred ShowMeCPF  {
  all s : State | s.active = Node && FingersCorrect[s] &&
        // not ClosestPrecedingFinger(s) && ClosestPrecedingFinger"(s)
        ClosestPrecedingFinger[s]
  //all s : State | all nd : s.active.s.data | nd.finger[Id] = Node
  # Node = 2
  # State = 1
}

//run ShowMeCPF for 2 but 1 State

pred FindPredecessor[s: State] {
  all n: s.active | let nd = n.(s.data) | all i: Id {
    nd.find_predecessor[i] =
      ((less_than_eq [n.id, i, nd.next.id] && (n.id != i || # s.active = 1))
      => n
      else (nd.closest_preceding_finger[i].(s.data).find_predecessor)[i])
    }
  }
-- problem : could return node that"s inactive ???

assert FPisActive {
  all s: State | FingersCorrect[s] && ClosestPrecedingFinger[s] && FindPredecessor[s]
  => (all n: s.active | all nd: n.(s.data) | nd.find_predecessor[Id] in s.active)
}

//check FPisActive for 3 but 1 State

pred FindPredecessor"[s: State] {
  all n: s.active | let nd = (s.data)[n] | all i: Id {
    let next" = Id<:next - (nd.next.id -> Id) {
      one s.active or i in n.id.^next" =>
      nd.find_predecessor[i] = n else
      nd.find_predecessor[i] =
      ((s.data)[nd.closest_preceding_finger[i]]).find_predecessor[i]
    }}
  }

assert SameFP {all s: State | FingersCorrect[s] && s.active = Node
  => (FindPredecessor [s] iff FindPredecessor" [s])}
assert SameFP1 {
  all s: State | FingersCorrect[s] && s.active = Node
    => (FindPredecessor [s] => FindPredecessor" [s])}
assert SameFP2 {
  all s: State | FingersCorrect[s] && s.active = Node
    => (FindPredecessor" [s] => FindPredecessor [s])}
//check SameFP for 3 but 1 State
//check SameFP1 for 3 but 1 State
//check SameFP2 for 3 but 1 State

pred FindSuccessor[s: State] {
  all n: s.active | let nd = (s.data)[n] | all i: Id {
    nd.find_successor[i] = ((s.data)[nd.find_predecessor[i]]).next
  }}

fact { all s : State {
    ClosestPrecedingFinger[s]
    FindPredecessor[s]
    FindSuccessor[s]
  }}

// should be able to //check that closest_p_f, etc returns
// only active nodes if FingersCorrect.

pred ShowMe1Node  {
  #Node = 1
  all s : State | NextCorrect[s]
  State.active = Node
}

//run ShowMe1Node for 2 but 1 State, 1 Node
-- does the expected correct thing for 1 node.

pred ShowMe1  {
  #Node = 2
  #State = 1
  all s : State | NextCorrect[s]
        State.active = Node
}

pred ShowMe2  {
  #Node = 3
  #State = 1
  all s : State | NextCorrect[s] && FingersCorrect[s]
        State.active = Node
  //all n: NodeData | one n.finger[Id]
}

assert OK1 {
  #Node = 3 &&
  #State = 1 &&
  (all s : State | NextCorrect[s] && FingersCorrect[s]) &&
  State.active = Node
}

assert FindSuccessorWorks {
  all s: State, i: Id |
    let nd = s.active.(s.data) |
    let succ = nd.find_successor [i] |
      FingersCorrect [s]
      => {
        no n": s.active | less_than [i, n".id, succ.id]
        succ in s.active
        }
  }

check FindSuccessorWorks for 4 but 1 State, 3 Node, 3 NodeData expect 0

// Model: algorithms/distributed-hashtable/chordbugmodel.als

/*
 * Models the chord distributed hash table lookup protocol.
 *
 * For a detailed description, see:
 *
 * Chord: A Scalable Peer-to-peer Lookup Service for Internet Applications
 * Ion Stoica, Robert Morris, David Karger, M. Frans Kaashoek, and Hari Balakrishnan.
 *
 */

sig Id {next: Id}
fact {all i: Id | Id in i.*next}

pred less_than [from, i,j: Id] {
   let next" = Id<:next - (Id->from) | j in i.^next"
}

pred less_than_eq [from, i,j: Id] {
   let next" = Id<:next - (Id->from) | j in i.*next"
}

sig Node {id: Id}
fact {all m,n: Node | m!=n => m.id != n.id}

sig NodeData {
   next: Node,
   finger: Id -> lone Node,
   closest_preceding_finger: Id -> one Node,
   find_successor: Id -> one Node
}

sig State {
   active: set Node,
   data: active -> one NodeData
}

fact {
   all s: State | all n: s.active |
      n.(s.data).next = n.(s.data).finger[n.id.next]
}

pred NextCorrect [s: State] {
   all n: s.active | let succ = n.(s.data).next {
      no n": s.active - n | less_than [n.id, n".id, succ.id]
      succ != n || #s.active = 1
      succ in s.active
   }
}

pred FingersCorrect [s: State] {
   all nd: s.active.(s.data) | all start: (nd.finger).Node |
      nd.finger[start] in s.active &&
      (no n" : s.active | less_than [start, n".id, nd.finger[start].id])
}

pred save_ClosestPrecedingFinger [s: State] {
   all n: s.active | let nd = n.(s.data) |
      all i: Id | let cpf = nd.closest_preceding_finger[i] {
   no n": (nd.finger[Id] + n) - cpf | less_than [cpf.id, n".id, i]
   cpf in nd.finger[Id] + n
   cpf.id != i || # s.active = 1
      }
}

pred save_FindSuccessor[s: State] {
   all n: s.active | let nd = n.(s.data) | all i: Id {
      nd.find_successor[i] =
      (((less_than_eq [n.id, i, nd.next.id] && n.id != i) || # s.active = 1)
      => nd.next
      else
      (nd.closest_preceding_finger[i].(s.data).find_successor)[i])
   }
}

pred IrrelevantFact1   {
   all s : State {
      ClosestPrecedingFinger[s]
      FindSuccessor[s]
   }
}

pred ShowMe1Node  {
   #Node = 1
   all s : State | NextCorrect[s] && FingersCorrect[s]
   State.active = Node
}

run ShowMe1Node for 2 but 1 State, 1 Node expect 1

pred ShowMeGood  {
   #Id = 4
   all s : State | NextCorrect[s] && FingersCorrect[s]
   State.active = Node
}

run ShowMeGood for 4 but 1 State, 2 Node expect 1

pred FindSuccessorIsCorrect[s: State] {
   all i: Id | all n: s.active |
      let succ = (n.(s.data)).find_successor [i] {
         succ in s.active
         no n": s.active | less_than [i, n".id, succ.id]
      }
}

pred ShowMeCorrectSuccessorEg {
   #Node = 3
   State.active = Node
   all s: State | FingersCorrect[s] && FindSuccessorIsCorrect[s]
}

run ShowMeCorrectSuccessorEg for 3 but 1 State expect 1

pred ShowMe3  {
   #Id = 5
   #Node = 3
   #State = 1
   all s : State | NextCorrect[s] && !FingersCorrect[s]
   State.active = Node
}

run ShowMe3 for 5 but 1 State expect 1

pred FindSuccessorWorks  {
   IrrelevantFact1
   ! (
      all s: State | FingersCorrect[s]
      => FindSuccessorIsCorrect[s]
   )
}

assert StrongerFindSuccessorWorks {
   all s: State | NextCorrect[s] => FindSuccessorIsCorrect[s]
}

run FindSuccessorWorks for 4 but 1 State expect 0
check StrongerFindSuccessorWorks for 4 but 1 State expect 1

/*
\section Variations

In the pseudocode presented in [\cite{chord1},
\cite{chord2}], there is some ambiguity as to what the
expression \tt<(n, n.successor]> means in boundary cases
where there is exactly one node and \tt<n.successor = n>.
The intention of the authors is that the set includes
\tt<n>. We consider variations of the alloy model with the
bug where the set \tt<(n, n]> does not include \tt<n>, and
observe how it affects the \tt<closest_preceding_finger> and
the \tt<find_sucessor> routines.

\subsection faulty \tt<closest_preceding_finger>

Suppose we change \tt<ClosestPrecedingFinger> as follows:

\code
*/

pred ClosestPrecedingFinger [s: State] {
   all n: s.active | let nd = n.(s.data) |
      all i: Id | let cpf = nd.closest_preceding_finger[i] {
   no n": (nd.finger[Id] + n) - cpf | less_than [cpf.id, n".id, i]
   cpf in nd.finger[Id] + n
   cpf.id != i
      }
}

/*
The only change here is in the last line
\cite{cpf-variation}, where we removed the clause \tt< || #
s.active=1>. The assertion \tt<FindSuccessorWorks> will
still hold for scope up to 4, but \tt<ShowMe1Node> will fail
to generate an example! This is an example of a
over-constraint, where the inconsistency only shows up when
there is exactly one node. What happens here is that the
model requires that a closest preceding finger node has a
distinct identifier from the input identifier, but this
cannot happen if there is exactly one node and if the input
identifier equals that of the node.

\subsection faulty \tt<find_successor>

Consider the following pseudocode segment from [\cite{chord2}]:

n.find_successor(id)
  if (id in (n, n.successor])
    return n.successor;
  else
    n" = closest_preceding_finger(id);
    return n".find_successor(id);

In the buggy scenario with a single node, the \tt<if> loop
always terminates at \cite{if-condition1}, leading to an
infinite loop.

Consider the corresponding change to \tt<FindSuccessor> as follows:

*/

pred FindSuccessor[s: State] {
   all n: s.active | let nd = n.(s.data) | all i: Id {
      nd.find_successor[i] =
      ((less_than_eq [n.id, i, nd.next.id] && n.id != i)
      => nd.next
      else
      (nd.closest_preceding_finger[i].(s.data).find_successor)[i])
   }
}

/*
The only change here is in the fourth line
\cite{sf-variation}, where we removed the clause \tt< || #
s.active = 1>. For the same reason, the \tt<if> loop
in this case always proceeds to the \tt<else> clause,
and since \tt<closest_preceding_finger> always returns
\tt<n> (the only node in the network), we end up
with a tautological statement:

\code
  nd.find_successor[i] = n.s.data.find_successor)[i]

This means that there is no additional constraint placed on
\tt<find_successor>, other than that its return type is
\tt<Node>. Now, if there is no distinction between active
and inactive nodes, that is, we have exactly one active node
in the network and no inactive ones, \tt<find_successor>
will return the right answer due to the type constraint,
therefore obscuring the bug. On the other hand, since we
have introduced inactive nodes, the assertion
\tt<FindSuccessorWorks> now fails with exactly one active
node and some inactive node(s), with \tt<find_successor>
returning an inactive node.
*/

// Model: algorithms/multicasting/iolus.als
/*
 * This is a model of Iolus, a scheme for secure multicasting.
 * In this scheme, nodes multicast messages to other nodes
 * within a group whose membership changes dynamically. The
 * group is partitioned into subgroups, arranged in a tree,
 * each with its own Key Distribution Server (KDS).
 *
 * For a detailed description, see:
 *   Mana Taghdiri, "Lightweight Modelling and Automatic Analysis
 *   of Multicast Key Management Schemes", Masters Thesis, Dept.
 *   of EECS, MIT, Dec. 2002.
 *
 * author: Mana Taghdiri
 */

open util/ordering[Tick] as ord

sig Tick {}

/**
 * It can be abstract, since the fact below says Key=GroupKey
 */
abstract sig Key {}

/**
 * It can be abstract, since the fact below says Message=DataMessage
 */
abstract sig Message {
  sender : Member,
  sentTime : Tick,
  key : Key
}

/**
 * It can be abstract, since the fact below says KDS=GSA
 */
abstract sig KDS {
  keys : Tick -> Key,
  members : Tick -> Member
}{
  Monotonic[keys]
  all t : Tick | let t" = ord/prev[t] {
    all m : members[t]-members[t"] | Join[m, t, this]
    all m : members[t"]-members[t] | Leave[m, t]
  }
}

/**
 * It can be abstract, since the fact below says "Member=Client"
 */
abstract sig Member {
  ownedKeys : Tick -> Key,
  receivedMessages : Tick -> Message
}{
  Monotonic[ownedKeys]
  Monotonic[receivedMessages]
}

fact MemberBehavior {
  Init[ord/first]
  all m : Member, t : Tick - ord/first |
    (some msg : Message |
      SendMessage[m, t, msg] || ReceiveMessage[m, t, msg]) ||
    (some kds : KDS | Join[m, t, kds]) ||
    Leave[m, t] || MemberInactive[m, t]
}

pred Monotonic[r : Tick -> univ] {
  all t : Tick | ord/prev[t].r in t.r
}

----------------------------------------------
sig GroupKey extends Key {
  generator : GSA,
  generatedTime : Tick
}{
  some c : Client |
   (Join[c, generatedTime, c.server] || Leave[c, generatedTime]) &&
   c.server = generator
}

sig DataMessage extends Message {
  gsaID : GSA,
  retransmitTime : Tick }
{ SendMessage[sender, sentTime, this] ||
  (some msg" : DataMessage |
     Remulticast[gsaID, msg", retransmitTime, this]) }

sig GSA extends KDS {
  parent : lone GSA }
{ keys[Tick].generator = this
  all t : Tick, k : keys[t] - keys[ord/prev[t]] |
    k.generatedTime = t }

sig Client extends Member {
  server : GSA }
{ all t : Tick, k : ownedKeys[t] - ownedKeys[ord/prev[t]] |
    k.generator = server && k.generatedTime = t }

fact IolusProperties {
  no k, k" : GroupKey | k!=k" && k.generator = k".generator && k.generatedTime = k".generatedTime
  all g : GSA, msg : DataMessage, t : Tick | RemulticastConditions[g, msg, t] =>
    (some msg": DataMessage | Remulticast[g, msg, t, msg"])
}

fact GSATree {
  let root = {g : GSA | no g.parent} {
    one root
    GSA in root.*~parent }}

fact {
  Member = Client
  KDS = GSA
  Message = DataMessage
  Key = GroupKey
  no m, m" : DataMessage {
    m!=m"
    m.sender = m".sender
    m.sentTime = m".sentTime
    m.key = m".key
    m.gsaID = m".gsaID
    m.retransmitTime = m".retransmitTime }
}

----------------------------------------------
pred Init[t : Tick] {
  no Member.receivedMessages[t]
  no Member.ownedKeys[t]
  no KDS.keys[t]
  no KDS.members[t] }

pred Join[m : Member, t : Tick, kds : KDS] {
  kds = m.server
  JoinRequest[m, kds, t]
  NoChange[m.receivedMessages, t]
}
pred JoinRequest[c : Client, gsa : GSA, t : Tick] {
  c !in gsa.members[ord/prev[t]]
  KeyUpdate[gsa, t]
  c in gsa.members[t] }

pred Leave[m : Member, t : Tick] {
  LeaveRequest[m, m.server, t]
  NoChange[m.receivedMessages, t] }

pred LeaveRequest[c : Client, gsa : GSA, t : Tick] {
    c in gsa.members[ord/prev[t]]
    KeyUpdate[gsa, t]
    c !in gsa.members[t] }

pred SendMessage[m : Member, t : Tick, msg : Message] {
  SendRequest[m, m.server, t, msg]
  m.receivedMessages[t] = m.receivedMessages[ord/prev[t]] + msg
  ConstantMembership[m, t] }

pred SendRequest[c : Client, gsa : GSA, t : Tick, msg : DataMessage] {
  c in gsa.members[t]
  msg.sender = c
  msg.sentTime = t
  NewestKey[gsa.keys[t], msg.key]
  msg.gsaID = gsa
  msg.retransmitTime = t
  (some gsa.parent.members[t]) =>
    (some msg" : DataMessage | Remulticast[gsa, msg, t, msg"]) }

pred ReceiveMessage[m : Member, t : Tick, msg : Message] {
  ReceiveConditions[m, t, msg]
  m.receivedMessages[t] = m.receivedMessages[ord/prev[t]] + msg }

pred MemberInactive[m : Member, t : Tick] {
  NoChange[m.receivedMessages, t] --does not constrain owned keys
  ConstantMembership[m, t] }

pred ReceiveConditions[m : Member, t : Tick, msg : Message] {
  ConstantMembership[m, t]
  msg !in m.receivedMessages[ord/prev[t]]
  msg.retransmitTime in ord/prevs[t]
  msg.key in m.ownedKeys[t] }

pred CanReceive[m : Member, t : Tick, msg : Message] {
  some msg" : DataMessage {
    msg".sentTime = msg.sentTime
    msg".sender = msg.sender
    msg" in m.receivedMessages[ord/prev[t]] || ReceiveConditions[m, t, msg"] }}

pred IsMember[m : Member, t : Tick] {
  some kds : KDS | m in kds.members[t]
}

-------------------------------------------
pred RemulticastConditions[g : GSA, msg : DataMessage, t : Tick] {
  msg.retransmitTime in ord/prevs[t]
  msg.key in g.keys[t] + g.parent.keys[t]
  some g.parent + g - msg.gsaID }

pred Remulticast[g : GSA, msg : DataMessage, t : Tick, msg": lone DataMessage] {
  RemulticastConditions[g, msg, t]
  let g" = g.parent + g - msg.gsaID | NewestKey[g".keys[msg.sentTime], msg".key]
  msg".sender = msg.sender
  msg".sentTime = msg.sentTime
  msg".retransmitTime = t
  msg".gsaID = g
}

pred KeyUpdate[g : GSA, t : Tick] {
  some k : Key {
    GeneratedKey[g, t, k]
    all c : Client | c in g.members[t] <=> k in c.ownedKeys[t]
    k in g.keys[t] }}

pred NewestKey[keys : set GroupKey, newest: lone GroupKey] {
  some keys <=> some newest
  newest in keys
  no ord/nexts[newest.generatedTime] & keys.generatedTime }

pred GeneratedKey[g : GSA, t : Tick, key : GroupKey] {
  key.generator = g
  key.generatedTime = t
}

pred ConstantMembership[c : Client, t : Tick] {
  IsMember[c, t] <=> IsMember[c, ord/prev[t]] }


pred NoChange[r : Tick -> univ, t : Tick] {
  r[ord/prev[t]] = r[t]
}

--------------------------------------------
assert Acyclic {
  all g : GSA | g !in g.^parent }

//check Acyclic for 6 -- one min

assert Connected {
  all g, g" : GSA | g in g".*(parent + ~parent) }

//check Connected for 6

assert TimeProceeds {
  no msg : DataMessage | msg.retransmitTime in ord/prevs[msg.sentTime] }

//check TimeProceeds for 6

pred LoopFree {
  no t, t" : Tick {
    t!=t"
    all k : KDS | k.members[t] = k.members[t"] -- no constraint on keys
    all m : Member | m.receivedMessages[t] = m.receivedMessages[t"]
    all m : DataMessage | m.retransmitTime = t =>
      (some m" : DataMessage {
        m".retransmitTime = t"
        m.sender = m".sender
        m.sentTime = m".sentTime
        m.gsaID = m".gsaID
        m.key = m".key })
    }}

//fact NoLoop { LoopFree() } -- Property-specific diameter

------------------------------------------------
assert loop {
  !LoopFree }
//check loop for 13 but 2 Member, 1 KDS, 1 Message

assert NonLinearTopology {
  (no g : GSA | #g.~parent > 1) ||
  !(some m, m" : DataMessage | Remulticast[m.gsaID, m", m.retransmitTime, m]
    && !SendMessage[m.sender, m.sentTime, m]
    && (some c : Client | m in c.receivedMessages[ord/nexts[m.retransmitTime]]))}

//check NonLinearTopology for 5 but 3 KDS, 3 Member, 2 Message -- > good scenario

assert NotOutside {
  no msg : DataMessage | !IsMember[msg.sender, msg.sentTime] }

//check NotOutside for 5

assert Trivial {
  0 = 1 }

//check Trivial for 2 but 1 KDS

assert x {
  !(LoopFree && some DataMessage &&
     (some t : Tick | some m, m" : Member |
        m!=m" && IsMember[m, t] && IsMember[m", t] && t != ord/next[ord/first]))
}

//check x for 3 but 2 Member, 2 KDS, 2 Message
 -------------------------------------------
assert OutsiderCantRead {
  no msg : Message, m : Member, t : Tick {
    IsMember[msg.sender, msg.sentTime]
    !IsMember[m, msg.sentTime]
    CanReceive[m, t, msg]
  }
}
assert OutsiderCantSend {
  no msg : Message, m : Member, t : Tick {
    !IsMember[msg.sender, msg.sentTime]
    IsMember[m, t]
    msg !in m.receivedMessages[ord/prev[t]]
    CanReceive[m, t, msg]
  }
}
assert InsiderCanRead {
  all msg : Message, m : Member |
    some t : Tick - ord/last | all t" : ord/nexts[t] |
      (IsMember[msg.sender, msg.sentTime] &&
       IsMember[m, msg.sentTime]) => CanReceive[m, t", msg]
}

check OutsiderCantRead for 5 but 3 Member expect 0
//check OutsiderCantSend for 5 but 3 Member -- 5 min
//check InsiderCanRead for 9 but 2 Member, 1 KDS, 1 Message
//check InsiderCanRead for 10 but 2 Member, 2 KDS, 2 Message -- not able to check

// Model: algorithms/discovery/INSLabel.als
/*
 * Models an Intentional Naming System (INS), a scheme for
 * dynamic resource discovery in a dynamic environment.
 *
 * S. Khurshid. Exploring the Design of an Intentional Naming Scheme with an
 * Automatic Constraint Analyzer. S.M. Thesis. Laboratory for Computer Science,
 * M.I.T. Cambridge, MA. May 2000.
 *
 * author: Sarfraz Khurshid
 */

sig Record {}

sig Label {}

sig Node {
  label: Label
}

sig LabelTree {
  root: Node,
  nodes: set Node,
  children: nodes one -> (nodes - root)
}
{ // connected
  nodes = root.*children
  some root.children
}

pred Get[db: DB, r: Record, a:Advertisement] {
  root[a] = root[db]
  nodes[a] =
    nodes[db]  & r.~(db.recs).*(~(db.children))
  anodes[a] =
    anodes[db] & r.~(db.recs).*(~(db.children))
  vnodes[a] =
    vnodes[db] & r.~(db.recs).*(~(db.children))
  all n: a.nodes |
      n.~(a.children) = n.~(db.children)
}

sig Attribute extends Label {}

sig Value extends Label {}

one sig Wildcard, Null extends Value {}

sig AVTree extends LabelTree {
  vnodes, anodes: set nodes
}
{
  root in vnodes
  root.label = Null
  Null !in (vnodes - root).label + anodes.label
  anodes.label in Attribute
  vnodes.label in Value
  all n: nodes | all /* disj */ c,c": n.children |
    c.label != c".label
  all a: anodes | a.children in vnodes && some a.children
  all v: vnodes | v.children in anodes
  no Wildcard.~label.children
}

one sig Query extends AVTree {}
{
  all a: anodes | one a.children
}

one sig Advertisement extends AVTree {}
{
  Wildcard !in vnodes.label
}

one sig DB extends AVTree {
  records: set Record,
  recs: (vnodes - root) some -> records
}
{
  Wildcard !in vnodes.label
  all a: anodes | no a.recs
  all v: vnodes {
    no v.children => some v.recs
    no v.recs & v.^(~children).recs }
  all a: anodes | all disj v,v": a.children |
    (no v.*children.recs & v".*children.recs)
}

one sig State {
  conforms: Query -> Advertisement -> Node -> Node,
  lookup: DB -> Query -> Node -> Node -> Record
}

fact ConformsFixPoint {
  all q: Query | all a: Advertisement |
    all nq: Node | all na: Node |
      q.ConformsAux[a,nq,na] <=>
      {
       nq.label in Wildcard + na.label
       all nq": q.children[nq] | some na": a.children[na] |
         q.ConformsAux[a,nq",na"]
      }
}

pred Query.ConformsAux[a: Advertisement, nq: Node, na: Node] {
  na in State.conforms[this][a][nq]
}

pred Conforms[q: Query, a:Advertisement] {
  q.ConformsAux[a, q.root, a.root]
}

fact LookupFixPoint {
  all db: DB, q: Query, T: Node, n: Node, r: Record |
    r in db.LookupAux[q,T,n] <=>                                  // record r is in the result if and only if
    {
     all na: n.(q.children) | all nv: na.(q.children) |            // for all child av-pairs (na,nv) of av-pair n in q
      some Ta: T.(db.children) {
         Ta.label = na.label                                       //  Ta is a child node with attribute na
         nv.label = Wildcard =>                                    //  wildcard matching
           r in Ta.^(db.children).(db.recs) else                     //   r is a record of any child of Ta
           (some Tv: Ta.(db.children) {                             //  normal matching
             Tv.label = nv.label                                   //   Tv is a child of Ta with value nv
             no nv.(q.children) =>                                 //   if Tv is a leaf-node
               r in Tv.*(db.children).(db.recs) else                   //        r is a record of Tv or of v
               r in db.LookupAux[q,Tv,nv] }) }                     //   else r is a record of the recursive call at Tv
    }
}

fun DB.LookupAux[q: Query, vd: Node, vq: Node]: set Record {      // helper function for Lookup
  State.lookup[this][q][vd][vq]
}

fun Lookup[db: DB, q: Query]: set Record {                             // models Lookup-Name algorithm invocation
  db.LookupAux[q, db.root, q.root]
}

assert LookupConforms2 { //soundness and completeness
  all q: Query | all db: DB | all r: Record | all a: Advertisement |
    Get[db,r,a] => // all n: a.nodes | n.~(db.children)
    {r in db.Lookup[q] <=> q.Conforms[a]}
}

// < 10 sec
check LookupConforms2 for 4 but 1 State, 3 LabelTree, 2 Record expect 0
// ~ 25 min
//check LookupConforms2 for 6 but 1 State, 3 LabelTree, 2 Record
//check LookupConforms2 for 6 but 1 State, 3 LabelTree, 3 Record
run Lookup for 3 expect 0

// Model: algorithms/discovery/ins.als
/*
 * Models an Intentional Naming System (INS), a scheme for
 * dynamic resource discovery in a dynamic environment.
 *
 * S. Khurshid. Exploring the Design of an Intentional Naming Scheme with an
 * Automatic Constraint Analyzer. S.M. Thesis. Laboratory for Computer Science,
 * M.I.T. Cambridge, MA. May 2000.
 *
 * author: Sarfraz Khurshid
 */

open util/relation as rel

sig Attribute {}
sig Value {}
sig Record {}

one sig Wildcard extends Value {}

sig AVTree {
  values: set Value,
  attributes: set Attribute,
  root: values - Wildcard,
  av: attributes one -> some (values - root),
  va: (values - Wildcard) one -> attributes
}{
  // values (and attributes) of tree are those reachable from root
  values = root.*(va.av)
}

sig Query extends AVTree {} {all a:attributes | one a.av}

sig DB extends AVTree {
  records : set Record,
  recs: (values - root) some -> records,
  lookup : Query -> (values -> records)
}{
  Wildcard !in values
}

fact AddInvariants {
  all db: DB {
    all v: db.values | no v.(db.recs) & v.^(~(db.av).~(db.va)).(db.recs)
    all a: db.attributes | all disj v1, v2: a.(db.av) |
      (some rr: *((db.va).(db.av)).(db.recs) | no v1.rr & v2.rr)
  }
}

pred Get [db: DB, r: Record, q: Query] {
  q.values = r.~(db.recs).*(~(db.av).~(db.va))
  q.attributes = q.values.~(db.av)
  q.root = db.root
  all a : attributes| a.~(q.va) = a.~(db.va)
  all v : values | v.~(q.av) = v.~(db.av)
}

pred Conforms [db: DB, q: Query, r: Record] {
  some p: Query {
    db.Get[r, p]
    q.va in p.va
    (q.av - Attribute -> Wildcard) in p.av
  }
}

pred indSubset[db : DB, q: Query, r: set Record, v: Value] {
  all a : v.(q.va) |
    (a.(q.av) in a.(db.av) => r in (a.(q.av)).(q.(db.lookup))) &&
    (a.(q.av) = Wildcard => r in a.(db.av).*((db.va).(db.av)).(db.recs))
}

pred Lookup[db: DB, q: Query, found: set Record] {
  all v: Value | not v.(q.va) in v.(db.va) => no v.(q.(db.lookup))
  all v: Value | all a : v.(q.va) |
    a.(q.av) != Wildcard && not a.(q.av) in a.(db.av) => no v.(q.(db.lookup))
  all v: Value - Wildcard |
    no v.(q.va) => v.(q.(db.lookup)) = v.*((db.va).(db.av)).(db.recs)
  all v: Value |
    some v.(q.va) => indSubset[db, q, v.(q.(db.lookup)), v] &&
    (no r: Record - v.(q.(db.lookup)) | indSubset[db, q, v.(q.(db.lookup)) + r, v])
  found = db.root.(q.(db.lookup))
}

assert CorrectLookup {
  all db: DB | all q : Query | all r : Record |
    Conforms [db,q,r] <=> db.Lookup[q, r]
}

pred Add [me: DB, adv: Query, r: Record, db: DB] {
  // restricted version - only advertisements with fresh attributes and values added
  no me.attributes & adv.attributes
  me.values & adv.values = me.root
  me.root = adv.root
  Wildcard !in adv.values
  r !in me.records
  db.values = me.values + adv.values
  db.attributes = me.attributes + adv.attributes
  db.root = me.root
  db.av = me.av + adv.av
  db.va = me.va + adv.va
  db.recs = me.recs + ((db.values - dom[db.va]) -> r)
}

pred RemoveWildCard[me: Query, q: Query] {
  q.values = me.values - Wildcard
  q.attributes = me.attributes - Wildcard.~(me.av)
  q.root = me.root
  q.av = me.av - Attribute -> Wildcard
  q.va = me.va - Value -> Wildcard.~(me.av)
}

assert MissingAttributeAsWildcard {
  all db : DB, q, q" : Query, found: set Record |
    db.Lookup[q, found] && q.RemoveWildCard[q"] => db.Lookup[q", found]
}

// Model: algorithms/spanning-tree/opt_spantree.als

/*
 * Direct specification of a distributed spanning tree algorithm
 * over arbitrary network topologies
 *
 * Each process has a parent and a level, both of which are
 * initially null. A distinct root node exists at which the
 * algorithm starts. In the first step, the root assigns itself
 * the level of zero and sends its level to its neighbors.
 * Subsequently, if a node reads a message with level k, it sets
 * its level to k+1, records the sender of the message as its
 * parent, and sends the level k+1 to its neighbors. Once a node
 * has set its level and parent, it ignores subsequent messages.
 * Eventually, the parent pointers will form a spanning tree,
 * rooted at Root.
 *
 * We model communication through a state-reading model, in which
 * nodes can directly read the state of their neighbors. Messages
 * are not explicitly modelled. This makes no difference for this
 * algorithm since once a node sends a message, the state of the
 * node stays the same as the contents of the message.
 */

open util/ordering[Lvl] as lo
open util/ordering[State] as so
open util/graph[Process] as graph

sig Process {
  adj : set Process
}

one sig Root extends Process {}

/**
 * intuitively, the depth level at which
 * a process resides in the spanning tree,
 * with the root at level zero
 */
sig Lvl {}

fact processGraph {
  graph/noSelfLoops[adj]     // for viz
  graph/undirected[adj]      // adjacency is symmetric
  Process in Root.*adj // everything reachable from root
}

sig State {
  /**
   * the set of processes which execute in this state.
   * used to allow flexibility in how many processes
   * run simultaneously
   */
  runs : set Process,

  /**
   * the level of a process in this state
   */
  lvl: Process -> lone Lvl,

  /**
   * who the process thinks is its parent in this state.
   * the parent pointers should eventually become
   * the spanning tree
   */
  parent: Process -> lone Process
}

/**
 * initially, the lvl and parent fields are blank
 */
pred Init {
  let fs = so/first | {
    no fs.lvl
    no fs.parent
  }
}

/**
 * simple NOP transition
 */
pred TRNop[p : Process, pre, post: State] {
  pre.lvl[p] = post.lvl[p]
  pre.parent[p] = post.parent[p]
}

/**
 * preconditions for a process to actually act
 * in a certain pre-state
 * used to preclude stalling of entire system
 * for no reason (see TransIfPossible)
 */
pred TRActPreConds[p : Process, pre : State] {
  // can't already have a level
  no pre.lvl[p]
  // must have a neighbor with a set level so
  // p can read it
  // Root doesn't need to read value from a
  // neighbor
  (p = Root || some pre.lvl[p.adj])
}

/**
 * transition which changes state of a process
 */
pred TRAct[p : Process, pre, post : State] {
  // can't already have a level
  no pre.lvl[p]
  (p = Root) => {
    // the root sets its level to
    // 0, and has no parent pointer
    post.lvl[p] = lo/first
    no post.parent[p]
  } else {
    // choose some adjacent process
    // whose level is already set
    some adjProc: p.adj |
      let nLvl = pre.lvl[adjProc] | {
        some nLvl
        // p's parent is the adjacent
        // process, and p's level is one greater than
        // the level of the adjacent process (since
        // its one level deeper)
        post.lvl[p] = lo/next[nLvl]
        post.parent[p] = adjProc
      }
  }
}

pred Trans[p : Process, pre, post : State] {
  TRAct[p, pre, post] ||
  TRNop[p, pre, post]
}

/**
 * all processes do a nop transition in some
 * state only when no process can act because
 * preconditions are not met
 */
fact TransIfPossible {
  all s : State - so/last |
    (all p : Process | TRNop[p, s, so/next[s]]) =>
      (all p : Process | !TRActPreConds[p,s])
}

fact LegalTrans {
  Init
  all s : State - so/last |
    let s" = so/next[s] | {
      all p : Process |
        p in s.runs => Trans[p, s, s"] else TRNop[p,s,s"]
    }
}

pred PossTrans[s, s" : State] {
  all p : Process | Trans[p,s,s"]
}

pred SpanTreeAtState[s : State] {
  // all processes reachable through inverted parent pointers
  // from root (spanning)
  Process in Root.*~(s.parent)
  // parent relation is a tree (DAG)
  // we only need to check the DAG condition since there can
  // be at most one parent for a process (constrained by
  // multiplicity)
  graph/dag[~(s.parent)]
}

/**
 * show a run that produces a spanning tree
 */
pred SuccessfulRun {
  SpanTreeAtState[so/last]
  all s : State - so/last | !SpanTreeAtState[s]
}

/**
 * show a trace without a loop
 */
pred TraceWithoutLoop {
  all s, s" : State | s!=s" => {
    !EquivStates[s, s"]
    (s" in so/nexts[s] && (s" != so/next[s])) => !PossTrans[s,s"]
  }
  all s: State | !SpanTreeAtState[s]
}

/**
 * defines equivalent states
 */
pred EquivStates[s, s" : State] {
  s.lvl = s".lvl
  s.parent = s".parent
}

/**
 * show a trace that violates liveness
 */
pred BadLivenessTrace {
  // two different states equivalent (loop)
  some s, s" : State | s!=s" && EquivStates[s, s"]
  all s : State | !SpanTreeAtState[s]
}

/**
 * check that once spanning tree is constructed,
 * it remains
 */
assert Closure {
  all s : State - so/last |
    SpanTreeAtState[s] => (s.parent = so/next[s].parent)
}

// note that for the worst case topology and choice of root,
// the scope of Lvl must equal the scope of Process
run SuccessfulRun for 4 State, exactly 5 Process, 3 Lvl expect 1
// run TraceWithoutLoop for 8 but 9 State expect 1
run BadLivenessTrace for 5 but 7 State expect 0
check Closure for 5 but 7 State expect 0

// Model: algorithms/synchronisation/sync.als
/*
 * Model of a generic file synchronizer.
 *
 * Adapted from:
 *   Reference: S. Balasubramaniam and Benjamin C. Pierce,
 *   "What is a File Synchronizer", Indiana University CSCI
 *   Technical Report #507, April 22, 1998
 *
 * author: Tina Nolte
 */

private open util/graph[Name] as graph

/**
 * The Name atom represents the hierarchy of all name sequences
 * used in the model. A Name atom represents the name, and the path
 * in the sequence of names to the root excluding the RootName.
 */
sig Name {
  children: set Name
}

fact { graph/tree[children] }

one sig RootName extends Name { }

fact { Name in RootName.*children }

// We assume that the empty path always

sig FileContents { }
one sig Dir extends FileContents { }

pred IsValidFS[fs: Name -> lone FileContents] {
   all n: Name - RootName | {
      // files don't have children
      n.fs != Dir => no (n.^children).fs
      // if a path maps to something non-nil, all prefixes do also
      some n.fs => some (n.~children).fs
   }
   // the root of a file system must be a directory
   RootName.fs = Dir
}

pred IsValidDirty[dirty: set Name] {
  all n: dirty | n.~children in dirty
  RootName in dirty => some dirty - RootName
}

pred DirtiesValid[A, B: Name -> lone FileContents, Adirty, Bdirty: set Name] {
  some O: Name -> lone FileContents | {
    IsValidFS[O]
    { n: Name | n.O != n.A } in Adirty
    { n: Name | n.O != n.B } in Bdirty
  }
}

fun RestrictFS[fs: Name -> lone FileContents, p: Name]: Name -> lone FileContents {
   fs & (p.*children -> FileContents)
}

fun RestrictFSComplement[fs: Name -> lone FileContents, p: Name]: Name -> lone FileContents {
   fs & ((Name - p.*children) -> FileContents)
}

/**
 * The following function test whether a particular synchronizer
 * operation satisfies the "reasonableness" conditions.
 * The arguments are:
 * O - the original filesystem.
 * A,B - separately modified copies
 * Adirty, Bdirty - sets of paths modified in A and B, respectively, from O.
 *
 * A",B" - results of synchronizer operation
 */
pred SyncSpec[A, B, A", B": Name -> lone FileContents, Adirty, Bdirty: set Name] {
  {
     IsValidFS[A]
     IsValidFS[B]
     IsValidDirty[Adirty]
     IsValidDirty[Bdirty]
   } => {
    {
     all p: Name | IsRelevantPath[p, A, B] => {
        SyncSpecForPath[p, A, B, A", B", Adirty, Bdirty]
     }
    }
    IsValidFS[A"]
    IsValidFS[B"]
   }
}

pred SyncSpecForPath[p: Name, A, B, A", B": Name -> lone FileContents, Adirty, Bdirty: set Name] {
      (p.A = p.B  =>  (p.A" = p.A && p.B" = p.B))
      (p !in Adirty => (RestrictFS[A", p] = RestrictFS[B, p] && RestrictFS[B", p] = RestrictFS[B, p]))
      (p !in Bdirty => (RestrictFS[B", p] = RestrictFS[A, p] && RestrictFS[A", p] = RestrictFS[A, p]))
      ((p in Adirty && p in Bdirty && p.A != p.B) => (RestrictFS[A",p] = RestrictFS[A,p] && RestrictFS[B",p] = RestrictFS[B,p]))
}

pred IsRelevantPath[p: Name, A, B: Name -> lone FileContents] {
   p = RootName || {
     (p.~children).A = Dir
     (p.~children).B = Dir
   }
}

pred SyncSpecExample[A, B, A", B": Name -> lone FileContents, Adirty, Bdirty: set Name] {
   IsValidFS[A]
   IsValidFS[B]
   IsValidDirty[Adirty]
   IsValidDirty[Bdirty]
   SyncSpec[A, B, A", B", Adirty, Bdirty]
   A != A"
}

//run SyncSpecExample for 3

pred SyncSpecNotUnique  {
  some A, B, A1", B1", A2", B2": Name -> lone FileContents, Adirty, Bdirty: set Name | {
    IsValidFS[A] && IsValidFS[B]
    IsValidDirty[Adirty] && IsValidDirty[Bdirty]
    //DirtiesValid(A, B, Adirty, Bdirty)
    (A1" != A2"  || B1" != B2")
    SyncSpec[A, B, A1", B1", Adirty, Bdirty]
    SyncSpec[A, B, A2", B2", Adirty, Bdirty]
  }
}

run SyncSpecNotUnique for 5 expect 0

// Model: algorithms/synchronisation/syncimpl.als
/*
 * Model of a file synchronizer reconciliation algorithm.
 *
 * Adapted from:
 *   Reference: S. Balasubramaniam and Benjamin C. Pierce,
 *   "What is a File Synchronizer", Indiana University CSCI
 *   Technical Report #507, April 22, 1998
 *
 * author: Tina Nolte
 */

open sync as sync
open util/ordering[sync/Name] as ord
open util/relation as rel

// Model the reconciliation algorithm

sig ReconName extends Name {
   Ain, Bin, Aout, Bout: Name->FileContents,
   p_children: set Name,
   first_p_child, last_p_child: lone Name,
   prev_p_child: (p_children - first_p_child) -> p_children
}

fact {
  all x: ReconName {
     x.p_children = ChildrenAB[x.Ain, x.Bin, x]
     x.first_p_child = { pc: x.p_children | x.p_children in (pc + nexts[pc]) }
     x.last_p_child = { pc: x.p_children | x.p_children in (pc + prevs[pc]) }
     all p_child: x.p_children - x.first_p_child | {
       let earlierChildren = prevs[p_child] & x.p_children |
          p_child . (x.prev_p_child) = { earlierChild: earlierChildren | earlierChildren in (earlierChild + @prevs[earlierChild]) }
     }
  }
}

fact { ReconName = Name }

fun ChildrenAB[A, B: Name -> lone FileContents, p: Name]: set Name {
   p.children & (dom[A] + dom[B])
}

pred reconHelper[Adirty, Bdirty: set Name] {
   all p: Name {
      let A = p.Ain, B = p.Bin, A" = p.Aout, B" = p.Bout | {
         some p.(A+B) => {
             (p !in Adirty && p !in Bdirty) => (A" = A  && B" = B)  else {
             (p.A = Dir && p.B = Dir) => {
                no p_children => {
                  p.Aout = p.Ain
                  p.Bout = p.Bin
                } else {
                    p.first_p_child.Ain = p.Ain
                    p.first_p_child.Bin = p.Bin
                    p.Aout = p.last_p_child.Aout
                    p.Bout = p.last_p_child.Bout
                    all pchild: p.p_children - p.first_p_child | {
                        pchild.Ain = (pchild.(p.prev_p_child)).Aout
                        pchild.Bin = (pchild.(p.prev_p_child)).Bout
                     }
                }  // some p_children
             } else {  // !(p.A = Dir && p.B = Dir)
               p !in Adirty => {
                 A" = RestrictFS[B, p] + RestrictFSComplement[A, p]
                 B" = B
               } else {
                  p !in Bdirty => {
                     A" = A
                     B" = RestrictFS[A, p] + RestrictFSComplement[B, p]
                  } else {
                     A" = A
                     B" = B
                  }
               }  // not "p !in Adirty"
             }  // not case 2 i.e. not both are dirs
          }  // not both clean
       }  // some p.(A+B)
      }  // let A =, B=, A"=, B"=
    } // all p: Name
}  // reconHelper()

pred recon[A, B, A", B": Name -> lone FileContents, Adirty, Bdirty: set Name] {
   A = ReconName.Ain
   B = ReconName.Bin
   A" = ReconName.Aout
   B" = ReconName.Bout
   reconHelper[Adirty, Bdirty]
}

assert Correctness {
  all A, B, A", B": Name -> lone FileContents, Adirty, Bdirty: set Name | {
    {
     DirtiesValid[A, B, Adirty, Bdirty]
     recon[A, B, A", B", Adirty, Bdirty]
     //no Adirty + Bdirty
    }
    =>
     SyncSpec[A, B, A", B", Adirty, Bdirty]
  }
}

check Correctness for 4 but 2 FileContents expect 0

// Model: algorithms/election/ringlead.als
/*
 * Model of leader election on a ring
 *
 * Each process has a unique ID, IDs are ordered.
 * The algorithm elects the process with the highest
 * ID the leader, as follows.  First, each process
 * sends its own ID to its right neighbor.
 * Then, whenever a process receives an ID, if the
 * ID is greater than the process' own ID it forwards
 * the ID to its right neighbor, otherwise does nothing.
 * When a process receives its own ID that process
 * is the leader.
 */

open util/boolean as bool
open examples/algorithms/messaging as msg
open util/ordering[msg/Node] as nodeOrd
open util/ordering[msg/Tick] as tickOrd

sig RingLeadNode extends msg/Node {
   rightNeighbor: msg/Node
}

fact DefineRing {
  (one msg/Node || (no n: msg/Node | n = n.rightNeighbor))
  all n: msg/Node | msg/Node in n.^rightNeighbor
}

sig RingLeadMsgState extends msg/MsgState {
  id: msg/Node
}

sig MsgViz extends msg/Msg {
  vFrom: msg/Node,
  vTo: set msg/Node,
  vId: msg/Node
}

fact {
  MsgViz = msg/Msg
  vFrom = state.from
  vTo = state.to
  vId = state.id
}


sig RingLeadNodeState extends msg/NodeState {
  leader: Bool
}


pred RingLeadFirstTrans [self: msg/Node, pre, post: msg/NodeState,
                        sees, reads, sends, needsToSend: set msg/Msg] {
   one sends
   # needsToSend = 1
   sends.state.to = self.rightNeighbor
   sends.state.id = self
   post.leader = False
}

fact InitRingLeadState {
  all n: msg/Node |
    tickOrd/first.state[n].leader = False
}

pred RingLeadRestTrans [self: msg/Node, pre, post: msg/NodeState,
                       sees, reads, sends, needsToSend: set msg/Msg] {
   RingLeadTransHelper[self, sees, reads, sends, needsToSend]
   post.leader = True iff (pre.leader = True ||
                           self in reads.state.id)
}

/**
 * we take any messages whose node ids are higher than ours,
 * and we forward them to the right neighbor.  we drop
 * all other messages.  if we get a message with our own
 * id, we're the leader.
 */
pred RingLeadTransHelper[self: msg/Node, sees, reads, sends, needsToSend: set msg/Msg] {
   reads = sees

   all received: reads |
     (received.state.id in nodeOrd/nexts[self]) =>
       (one weSend: sends | (weSend.state.id = received.state.id && weSend.state.to = self.rightNeighbor))

   all weSend: sends | {
     let mID = weSend.state.id | {
       mID in nodeOrd/nexts[self]
       mID in reads.state.id
       weSend.state.to = self.rightNeighbor
     }
     //weSend.sentBecauseOf = { received : reads | received.id = weSend.id }
     //all otherWeSend: sends - weSend | otherWeSend.id != weSend.id
   }

   # needsToSend = # { m: reads | m.state.id in nodeOrd/nexts[self] }
}
fact RingLeadTransitions {
   all n: msg/Node {
      all t: msg/Tick - tickOrd/last | {
         t = tickOrd/first =>
           RingLeadFirstTrans[n, t.state[n], tickOrd/next[t].state[n], t.visible[n], t.read[n], t.sent[n], t.needsToSend[n]]
         else
           RingLeadRestTrans[n, t.state[n], tickOrd/next[t].state[n], t.visible[n], t.read[n], t.sent[n], t.needsToSend[n]]
      }
      // also constrain last tick
      RingLeadTransHelper[n, tickOrd/last.visible[n], tickOrd/last.read[n], tickOrd/last.sent[n], tickOrd/last.needsToSend[n]]
   }
}

assert OneLeader {
   all t: msg/Tick |
      lone n: msg/Node |
         t.state[n].leader = True
}

fact CleanupViz {
  RingLeadNode = msg/Node
  RingLeadMsgState = msg/MsgState
  RingLeadNodeState = msg/NodeState
}

pred SomeLeaderAtTick[t: msg/Tick] {
  some n: msg/Node | t.state[n].leader = True
}

pred NeverFindLeader {
  msg/Loop
  all t: msg/Tick | ! SomeLeaderAtTick[t]
}

assert Liveness {
  (msg/NoLostMessages && msg/NoMessageShortage) => ! NeverFindLeader
}

pred SomeLeader { some t: msg/Tick | SomeLeaderAtTick[t] }

assert LeaderHighest {
  all t: msg/Tick, n: msg/Node |
    t.state[n].leader = True => n = nodeOrd/last
}

run NeverFindLeader for 1 but 3 msg/Tick, 2 Bool, 2 msg/NodeState expect 1
check Liveness for 3 but 6 msg/Msg, 2 Bool, 2 msg/NodeState expect 0
check OneLeader for 5 but 2 Bool, 2 msg/NodeState expect 0
run SomeLeader for 2 but 3 msg/Node, 5 msg/Msg, 5 msg/Tick, 5 msg/MsgState expect 1
check LeaderHighest for 3 but 2 msg/NodeState, 5 msg/Msg, 5 msg/MsgState, 5 msg/Tick expect 0


// Model: algorithms/election/s_ringlead.als

/*
 * Model of leader election on a ring.
 *
 * Each process has a unique ID, IDs are ordered. The algorithm
 * elects the process with the highest ID the leader, as follows.
 * First, each process sends its own ID to its right neighbor.
 * Then, whenever a process receives an ID, if the ID is greater
 * than the process' own ID it forwards the ID to its right
 * neighbor, otherwise does nothing. When a process receives its
 * own ID that process is the leader.
 *
 * Note: This file needs higher order quantifiers turned on.
 */

open util/ordering[State] as so
open util/ordering[Process] as po
open util/graph[Process] as graph

sig Process {
  rightNeighbor: Process
}

sig State {
  // buffer which the right neighbor can read from
  buffer: Process -> Process,
  //sends, reads: Process -> Process,
  runs: set Process,
  leader: set Process
}

fact DefineRing {
  graph/ring[rightNeighbor]
}

fact InitialState {
  no so/first.buffer
  no so/first.leader
  Process in so/first.runs
}


fact CleanupLast {
  let ls = so/last |
    no ls.runs
}

pred ValidTrans2[s, s": State] {
  all p : s.runs | VT2Helper[p,s,s"]
  all p : Process - s.runs | NOP2[p,s,s"]
  NoMagicMsg[s,s"]

}

pred NoMagicMsg[s, s" : State] {
    // no magically appearing messages
    all p : Process, m : s".buffer[p] |
      m in s.buffer[p] || (!NOP2[p,s,s"] &&
                            ((s = so/first && m = p) ||
                             (s != so/first && m in s.buffer[p.~rightNeighbor]
                              && m !in s".buffer[p.~rightNeighbor] && po/gt[m,p])))
}

pred PossTrans[s, s" : State] {
  all p : Process | VT2Helper[p,s,s"] || NOP2[p,s,s"]
  NoMagicMsg[s,s"]
}

pred VT2Helper[p : Process, s, s" : State] {
    (
      let readable=s.buffer[p.~rightNeighbor] |
        (s = so/first) => {
          p = s".buffer[p]
          readable in s".buffer[p.~rightNeighbor]
          p !in s".leader
        } else {
          (some readable) => {
           some m : set readable | {
             m !in s".buffer[p.~rightNeighbor]
             // nothing else gets deleted
             readable - m in s".buffer[p.~rightNeighbor]
             { m": m | po/gt[m",p] } /*m & nexts(p)*/ in s".buffer[p]
             p in s".leader iff (p in s.leader || p in m)
           }
          } else NOP2[p,s,s"]
        }
    )
}

pred NOP2[p : Process, s,s": State] {
  p in s".leader iff p in s.leader
  // no reads
  s.buffer[p.~rightNeighbor] in s".buffer[p.~rightNeighbor]
  // no sends
  s".buffer[p] in s.buffer[p]
}

pred Preconds[p : Process, s : State] {
  s = so/first || some s.buffer[p.~rightNeighbor]
}

fact TransIfPossible {
  all s : State - so/last |
    (all p : Process | NOP2[p, s, so/next[s]]) =>
      (all p : Process | !Preconds[p,s])
}

fact LegalTrans {
  all s : State - so/last |
    let s" = so/next[s] |
      ValidTrans2[s,s"]
}

pred EquivStates[s, s": State] {
  s.buffer = s".buffer
  s.leader = s".leader
}

assert Safety {
  all s : State | lone s.leader
}

pred Legit[s : State] {
  one s.leader
}

pred BadLivenessTrace {
  all s : State | !Legit[s]
  let ls = so/last |
    some s : State - ls | {
      EquivStates[s, ls]
      Process in (so/nexts[s] + s).runs
    }
}

pred TraceWithoutLoop  {
  all t1, t2 : State | t1!=t2 => !EquivStates[t1,t2]
  all s, s" : State | (s" in (so/nexts[s] - so/next[s])) => !PossTrans[s,s"]
  all s : State | !Legit[s]
}

pred AltTrans  {
  SomeLeader
}

pred SomeLeader { some State.leader }

run BadLivenessTrace for 3 but 8 State expect 0
run SomeLeader for 4 but 6 State expect 1
check Safety for 7 expect 0
// run TraceWithoutLoop for 5 but 13 State expect 1
run AltTrans for 5 but 8 State expect 1

// Model: algorithms/election/stable_ringlead.als

/*
 * Huang's self-stabilizing leader-election algorithm
 * for rings.
 */

open util/ordering[Process] as po
open util/ordering[Val] as vo
open util/ordering[State] as so
open util/graph[Process] as graph

sig Process {
  rightNeighbor: Process
}

sig Val {
  nextVal : Val
}

fact {
  graph/ring[rightNeighbor]
  vo/next + (vo/last -> vo/first) = nextVal
  # Val = # Process
}

sig State {
  val : Process -> one Val,
  running : set Process
  // for visualization
  //leader : set Process
} {
  //leader = { p : Process | LeaderAtState(p, this) }
}

fact {
  no so/last.running
}

fun LeadersAtState[t : State] : set Process {
  { p : Process | LeaderAtState[p,t] }
}

pred LeaderAtState[p : Process, t : State] { ValAtState[p,t] = vo/first }

fun ValAtState[p : Process, t : State] : Val { t.val[p] }

fun LeftValAtState[p : Process, t : State] : Val { t.val[p.~rightNeighbor] }

fun RightValAtState[p : Process, t : State] : Val { t.val[p.rightNeighbor] }

fun XAtState[p : Process, t : State] : Int {
  g[LeftValAtState[p,t],ValAtState[p,t]]
}

fun YAtState[p : Process, t : State] : Int {
  g[ValAtState[p,t],RightValAtState[p,t]]
}

fun g[a, b : Val] : Int {
  (a = b) => Int[# Val] else minus[b,a]
}

fun minus[v1, v2 : Val] : Int {
  Int[ (v1 = v2) => 0
        else vo/gt[v1, v2] => (# (vo/nexts[v2] & vo/prevs[v1] + v1))
        else (# (Val - (vo/nexts[v1] & vo/prevs[v2] + v1)))
  ]
}

fun Trans[oldVal : Val, x, y : Int] : Val {
  ((int x = int y && int y = # Val) || (int x < int y)) => oldVal.nextVal else oldVal
}

pred OneAtATimeTrans {
  all tp: State - so/last |
    let tn = so/next[tp] |
      some p : Process | {
        tp.running = p
        TransHelper[p,tp,tn]
        all other : Process - p |
          ValAtState[other,tn] = ValAtState[other,tp]
      }
}

pred DDaemonTrans {
  all tp: State - so/last |
    let tn = so/next[tp] | {
      some tp.running
      all p : tp.running | TransHelper[p,tp,tn]
      all other : Process - tp.running |
        ValAtState[other,tn] = ValAtState[other,tp]
    }
}

pred TransHelper[p : Process, tp, tn : State] {
        let oldVal = ValAtState[p, tp],
            newVal = ValAtState[p, tn],
            x = XAtState[p, tp],
            y = YAtState[p,tp] |
          newVal = Trans[oldVal, x, y]

}

pred StateTrans[s, s" : State] {
  all p : Process |
    TransHelper[p, s, s"] || ValAtState[p,s] = ValAtState[p,s"]
}



pred CBadLivenessTrace  {
  OneAtATimeTrans
  BadLivenessHelper
}

pred DBadLivenessTrace {
  DDaemonTrans
  BadLivenessHelper
}

pred BadLivenessHelper {
  let ls = so/last |
    some s : State - ls | {
      s.val = ls.val
      // fair
      Process in (so/nexts[s] + s - ls).running
    }
    all s : State | ! Legit[s]
  }

pred CTraceWithoutLoop {
  OneAtATimeTrans
  all t, t" : State | t!=t" => t.val != t".val
}

pred DTraceWithoutLoop {
  DDaemonTrans
  all t, t" : State | t!=t" => {
    t.val != t".val
    (t" in so/nexts[t] && t" != so/next[t]) => !StateTrans[t,t"]
  }
  all t : State | !Legit[t]
}

pred ConvergingRun  {
  OneAtATimeTrans
  !Legit[so/first]
  some t : State | Legit[t]
}

pred OnlyFairLoops {
  OneAtATimeTrans
  all s, s" : State |
   (s" in so/nexts[s] && s".val = s.val) =>
     (let loopStates = (so/nexts[s] & so/prevs[s"]) + s + s" | Process in loopStates.running)
}

assert CMustConverge {
  OnlyFairLoops => (some s : State | Legit[s])
}

pred Legit [s : State] {
  one LeadersAtState[s]
  all p : Process | {
    int XAtState[p,s] < # Val
    int YAtState[p,s] < # Val
  }
  all p, p" : Process | {
    int XAtState[p,s] = int XAtState[p",s]
    int YAtState[p,s] = int YAtState[p",s]
  }
}

run ConvergingRun for 3 but 4 State expect 1
run DTraceWithoutLoop for 3 but 4 State expect 1
run DBadLivenessTrace for 3 but 4 State expect 1
run CTraceWithoutLoop for 3 but 5 State expect 0
run CBadLivenessTrace for 4 but 5 State expect 1
check CMustConverge for 3 but 4 State expect 0

// Model: algorithms/gc/marksweepgc.als
/*
 * Model of mark and sweep garbage collection.
 */

// a node in the heap
sig Node {}

sig HeapState {
  left, right : Node -> lone Node,
  marked : set Node,
  freeList : lone Node
}

pred clearMarks[hs, hs" : HeapState] {
  // clear marked set
  no hs".marked
  // left and right fields are unchanged
  hs".left = hs.left
  hs".right = hs.right
}

/**
 * simulate the recursion of the mark() function using transitive closure
 */
fun reachable[hs: HeapState, n: Node] : set Node {
  n + n.^(hs.left + hs.right)
}

pred mark[hs: HeapState, from : Node, hs": HeapState] {
  hs".marked = hs.reachable[from]
  hs".left = hs.left
  hs".right = hs.right
}

/**
 * complete hack to simulate behavior of code to set freeList
 */
pred setFreeList[hs, hs": HeapState] {
  // especially hackish
  hs".freeList.*(hs".left) in (Node - hs.marked)
  all n: Node |
    (n !in hs.marked) => {
      no hs".right[n]
      hs".left[n] in (hs".freeList.*(hs".left))
      n in hs".freeList.*(hs".left)
    } else {
      hs".left[n] = hs.left[n]
      hs".right[n] = hs.right[n]
    }
  hs".marked = hs.marked
}

pred GC[hs: HeapState, root : Node, hs": HeapState] {
  some hs1, hs2: HeapState |
    hs.clearMarks[hs1] && hs1.mark[root, hs2] && hs2.setFreeList[hs"]
}

assert Soundness1 {
  all h, h" : HeapState, root : Node |
    h.GC[root, h"] =>
      (all live : h.reachable[root] | {
        h".left[live] = h.left[live]
        h".right[live] = h.right[live]
      })
}

assert Soundness2 {
  all h, h" : HeapState, root : Node |
    h.GC[root, h"] =>
      no h".reachable[root] & h".reachable[h".freeList]
}

assert Completeness {
  all h, h" : HeapState, root : Node |
    h.GC[root, h"] =>
      (Node - h".reachable[root]) in h".reachable[h".freeList]
}

check Soundness1 for 3 expect 0
check Soundness2 for 3 expect 0
check Completeness for 3 expect 0

// Model: algorithms/mutex/dijkstra-2-process.als

/*
 * Models how mutexes are grabbed and released by processes, and
 * how Dijkstra's mutex ordering criterion can prevent deadlocks.
 *
 * For a detailed description, see:
 *   E. W. Dijkstra, Cooperating sequential processes. Technological
 *   University, Eindhoven, The Netherlands, September 1965.
 *   Reprinted in Programming Languages, F. Genuys, Ed., Academic
 *   Press, New York, 1968, 43-112.
 *
 * Acknowledgements to Ulrich Geilmann for finding and fixing a bug
 * in the GrabMutex predicate.
 *   
 */

open util/ordering [State] as so
open util/ordering [Mutex] as mo

sig Process {}
sig Mutex {}

sig State { holds, waits: Process -> Mutex }


pred Initial [s: State]  { no s.holds + s.waits }

pred IsFree [s: State, m: Mutex] {
   // no process holds this mutex
   no m.~(s.holds)
   // all p: Process | m !in p.(this.holds)
}

pred IsStalled [s: State, p: Process] { some p.(s.waits) }

pred GrabMutex [s: State, p: Process, m: Mutex, s": State] {
   // a process can only act if it is not
   // waiting for a mutex
   !s.IsStalled[p]
   // can only grab a mutex we do not yet hold
   m !in p.(s.holds)
   // mutexes are grabbed in order
   all m": p.(s.holds) | mo/lt[m",m]
   s.IsFree[m] => {
      // if the mutex is free, we now hold it,
      // and do not become stalled
      p.(s".holds) = p.(s.holds) + m
      no p.(s".waits)
   } else {
    // if the mutex was not free,
    // we still hold the same mutexes we held,
    // and are now waiting on the mutex
    // that we tried to grab.
    p.(s".holds) = p.(s.holds)
    p.(s".waits) = m
  }
  all otherProc: Process - p | {
     otherProc.(s".holds) = otherProc.(s.holds)
     otherProc.(s".waits) = otherProc.(s.waits)
  }
}

pred ReleaseMutex [s: State, p: Process, m: Mutex, s": State] {
   !s.IsStalled[p]
   m in p.(s.holds)
   p.(s".holds) = p.(s.holds) - m
   no p.(s".waits)
   no m.~(s.waits) => {
      no m.~(s".holds)
      no m.~(s".waits)
   } else {
      some lucky: m.~(s.waits) | {
        m.~(s".waits) = m.~(s.waits) - lucky
        m.~(s".holds) = lucky
      }
   }
  all mu: Mutex - m {
    mu.~(s".waits) = mu.~(s.waits)
    mu.~(s".holds)= mu.~(s.holds)
  }
}

/**
 * for every adjacent (pre,post) pair of States,
 * one action happens: either some process grabs a mutex,
 * or some process releases a mutex,
 * or nothing happens (have to allow this to show deadlocks)
 */
pred GrabOrRelease  {
    Initial[so/first] &&
    (
    all pre: State - so/last  | let post = so/next [pre] |
       (post.holds = pre.holds && post.waits = pre.waits)
        ||
       (some p: Process, m: Mutex | pre.GrabMutex [p, m, post])
        ||
       (some p: Process, m: Mutex | pre.ReleaseMutex [p, m, post])

    )
}

pred Deadlock  {
         some Process
         some s: State | all p: Process | some p.(s.waits)
}

assert DijkstraPreventsDeadlocks {
   GrabOrRelease => ! Deadlock
}


pred ShowDijkstra  {
    GrabOrRelease && Deadlock
    some waits
}

run Deadlock for 3 expect 1
run ShowDijkstra for 5 State, 2 Process, 2 Mutex expect 1
check DijkstraPreventsDeadlocks for 5 State, 5 Process, 4 Mutex expect 0

// Model: algorithms/mutex/dijkstra-K-state.als

/*
 * Dijkstra's K-state mutual exclusion algorithm for a ring
 *
 * Original paper describing the algorithm:
 *   [1] E.W.Dijkstra, "Self-Stabilizing Systems in Spite of
 *   Distributed Control", Comm. ACM, vol. 17, no. 11, pp.
 *   643-644, Nov. 1974
 *
 * Proof of algorithm's correctness:
 *   [2] E.W.Dijkstra, "A Belated Proof of Self-Stabilization",
 *   in Distributed Computing, vol. 1, no. 1, pp. 5-6, 1986
 *
 * SMV analysis of this algorithm is described in:
 *   [3] "Symbolic Model Checking for Self-Stabilizing Algorithms",
 *   by Tatsuhiro Tsuchiya, Shini'ichi Nagano, Rohayu Bt Paidi, and
 *   Tohru Kikuno, in IEEE Transactions on Parallel and Distributed
 *   Systems, vol. 12, no. 1, January 2001
 *
 * Description of algorithm (adapted from [3]):
 *
 * Consider a distributed system that consists of n processes
 * connected in the form of a ring.  We assume the state-reading
 * model in which processes can directly read the state of their
 * neighbors.  We define _privilege_ of a process as its ability to
 * change its current state.  This ability is based on a Boolean
 * predicate that consists of its current state and the state of
 * one of its neighboring processes.
 *
 * We then define the legitimate states as those in which the
 * following two properties hold: 1) exactly one process has a
 * privilege, and 2) every process will eventually have a privilege.
 * These properties correspond to a form of mutual exclusion, because
 * the privileged process can be regarded as the only process that is
 * allowed in its critical section.
 *
 * In the K-state algorithm, the state of each process is in
 * {0,1,2,...,K-1}, where K is an integer larger than or equal to n.
 * For any process p_i, we use the symbols S and L to denote its
 * state and the state of its neighbor p_{i-1}, respectively, and
 * process p_0 is treated differently from all other processes. The
 * K-state algorithm is described below.
 *
 *   process p_0: if (L=S) { S := (S+1) mod K; }
 *   process P_i(i=1,...,n-1): if (L!=S) { S:=L; }
 */

open util/ordering[Tick] as to
open util/graph[Process] as pg
open util/graph[Val] as vg

sig Process {
  rightNeighbor: Process
}

sig Val {
  nextVal : Val
}

fact MoreValThanProcess {
  # Val > # Process
}

fact DefineRings {
  pg/ring[rightNeighbor]
  vg/ring[nextVal]
  //Val$nextVal = Ord[Val].next + (Ord[Val].last -> Ord[Val].first)
}

sig Tick {
  val: Process -> one Val,
  runs: set Process,    // processes scheduled to run on this tick
  // for visualization
  priv: set Process  // the set of privileged processes on this tick
}
{
  priv = { p : Process | Privileged[p, this] }
}

one sig FirstProc extends Process {
}


fun FirstProcTrans[curVal, neighborVal : Val]: Val {
  (curVal = neighborVal) => curVal.nextVal else curVal
}

fun RestProcTrans[curVal, neighborVal : Val]: Val {
  (curVal != neighborVal) => neighborVal else curVal
}

fact LegalTrans {
  all tp : Tick - to/last |
    let tn = to/next[tp] | {
        all p: Process |
           let curVal = tp.val[p], neighborVal = tp.val[p.rightNeighbor], newVal = tn.val[p] | {
                p !in tp.runs => newVal = curVal else {
                   p = FirstProc =>
                       newVal = FirstProcTrans[curVal, neighborVal]
                   else
                       newVal = RestProcTrans[curVal, neighborVal]
                }
          }
      }
}

pred TickTrans[tp, tn : Tick] {
  all p : Process |
    let curVal = tp.val[p], neighborVal = tp.val[p.rightNeighbor], newVal = tn.val[p] | {
                   p = FirstProc =>
                       newVal = FirstProcTrans[curVal, neighborVal]
                   else
                       newVal = RestProcTrans[curVal, neighborVal]
    }
}

/**
 * whether this process can enter its critical section
 * on this tick
 */  
pred Privileged[p : Process, t : Tick] {
  p = FirstProc =>
    t.val[p] = t.val[p.rightNeighbor]
  else
    t.val[p] != t.val[p.rightNeighbor]
}

pred IsomorphicStates[val1, val2: Process -> one Val] {
   some processMap: Process one -> one Process,
        valMap: Val one -> one Val | {
       FirstProc.processMap = FirstProc
       all p: Process, v: Val |  {
          p->v in val1 iff (p.processMap) -> (v.valMap) in val2
       }
       all v1,v2: Val | v1->v2 in nextVal iff (v1.valMap) ->  (v2.valMap) in nextVal
       all p1,p2: Process | p1->p2 in rightNeighbor
               iff (p1.processMap) ->  (p2.processMap) in rightNeighbor
   }
}

/**
 * Find a trace that goes into a loop
 * containing a bad tick, i.e. a tick
 * at which two distinct processes
 * try to run their critical sections
 * simultaneously.  In such a trace the
 * algorithm never "stabilizes".
 */
pred BadSafetyTrace {
  let lst = to/last |
    some t : Tick - lst | {
      //IsomorphicStates(ft.val, lst.val)
      t.val = lst.val
      Process in (to/nexts[t] + t - lst).runs
      some badTick : to/nexts[t] + t |
        BadTick[badTick]
    }
}

/**
 * Two different processes simultaneously
 * try to run their critical sections at this tick
 */
pred BadTick[badTick : Tick] {
      some p1 , p2 : Process | {
        p1!=p2
        Privileged[p1, badTick]
        Privileged[p2, badTick]
      }
}

assert Closure {
  not BadTick[to/first] => (all t : Tick | not BadTick[t])
}

pred TwoPrivileged {
  BadTick[to/first]
  some p1, p2 : Process, t1, t2 : Tick - to/first | {
    p1!=p2
    Privileged[p1,t1]
    Privileged[p2,t2]
  }
}

pred TraceWithoutLoop  {
  all t1, t2 : Tick | t1!=t2 => t1.val != t2.val
}

pred TraceShorterThanMaxSimpleLoop {
  to/first.val = to/last.val
  all t : Tick - to/first - to/last |
    !(t.val = to/first.val)
}

run TraceShorterThanMaxSimpleLoop for 7 but 2 Process, 3 Val expect 1
run TwoPrivileged for 5 but 3 Process, 4 Val expect 1
check Closure for 5 but 5 Process, 6 Val expect 0
//run BadSafetyTrace for 16 but 3 Process, 4 Val
//run TraceWithoutLoop for 21 but 4 Process, 5 Val



// Model: algorithms/mutex/peterson.als

/*
 * Model of Peterson's algorithm for mutual exclusion of n
 * processes. The names kept similar to Murphi specification
 * to make correspondence clear.
 */

open util/ordering[priority] as po
open util/ordering[State] as so

sig pid {
}

sig priority {
}

fact {
  # priority = # pid + 1
}

abstract sig label_t {}

// here subtyping would help
one sig L0, L1, L2, L3, L4 extends label_t {}

sig State {
  P: pid -> label_t,
  Q: pid -> priority,
  turn: priority -> pid,
  localj: pid -> priority
}

pred NOPTrans[i: pid, pre, post : State] {
  post.P[i] = pre.P[i]
  post.Q[i] = pre.Q[i]
  post.localj[i] = pre.localj[i]
}

pred L0TransPre[i : pid, pre : State] {
  // precondition
  pre.P[i] = L0
}

pred L0Trans[i: pid, pre, post : State] {
  L0TransPre[i, pre]
  // localj[i] := 1
  post.localj[i] = po/next[po/first]
  post.P[i] = L1
  post.Q[i] = pre.Q[i]
  // something for turn?
  post.turn = pre.turn
}

pred L1TransPre[i : pid, pre : State] {
  // precondition
  pre.P[i] = L1
}

pred L1Trans[i : pid, pre, post : State] {
  L1TransPre[i, pre]
  post.localj[i] = pre.localj[i]
  post.Q[i] = pre.localj[i]
  post.P[i] = L2
  // something for turn?
  post.turn = pre.turn
}

pred L2TransPre[i : pid, pre : State] {
  // precondition
  pre.P[i] = L2
}

pred L2Trans[i : pid, pre, post : State] {
  L2TransPre[i, pre]
  post.localj[i] = pre.localj[i]
  post.Q[i] = pre.Q[i]
  post.P[i] = L3
  post.turn[post.localj[i]] = i
  all j : priority - post.localj[i] |
    post.turn[j] = pre.turn[j]
}

pred L3TransPre[i : pid, pre : State] {
  // precondition
  pre.P[i] = L3

  all k : pid - i |
    po/lt[pre.Q[k], pre.localj[i]] ||
    pre.turn[pre.localj[i]] != i
}

pred L3Trans[i : pid, pre, post : State] {
  L3TransPre[i, pre]
    post.localj[i] = po/next[pre.localj[i]]
    po/lt[post.localj[i], po/last] =>
      post.P[i] = L1
    else
      post.P[i] = L4
    post.Q[i] = pre.Q[i]
    post.turn = pre.turn
}

pred L4TransPre[i : pid, pre : State] {
  // precondition
  pre.P[i] = L4
}

pred L4Trans[i : pid, pre, post : State] {
  L4TransPre[i, pre]

  post.P[i] = L0
  post.Q[i] = po/first
  post.localj[i] = pre.localj[i]
  post.turn = pre.turn
}

pred RealTrans[i : pid, pre, post : State] {
  L0Trans[i,pre,post] ||
  L1Trans[i,pre,post] ||
  L2Trans[i,pre,post] ||
  L3Trans[i,pre,post] ||
  L4Trans[i,pre,post]
}

pred SomePre[i : pid, pre : State] {
  L0TransPre[i, pre] ||
  L1TransPre[i, pre] ||
  L2TransPre[i, pre] ||
  L3TransPre[i, pre] ||
  L4TransPre[i, pre]
}

fact Init {
  let firstState = so/first | {
    all i : pid | {
      firstState.P[i] = L0
      firstState.Q[i] = po/first
    }
    no firstState.turn
    no firstState.localj
  }
}

fact LegalTrans {
  all pre : State - so/last |
    let post = so/next[pre] | {
      /*some i : pid | {
        // HACK:
        // need to specify that if some node
        // can make a non-NOP transition, it
        // does, but i can't figure out how
        // right now
        Trans(i,pre,post) && !NOPTrans(i,pre,post)
        all j : pid - i |
          NOPTrans(j,pre,post)
      }*/
      all i : pid |
        RealTrans[i,pre,post] || NOPTrans[i,pre,post]
      (all i : pid | NOPTrans[i,pre,post]) => {
         all i : pid | !SomePre[i,pre]
         post.turn = pre.turn
      }
    }
}

assert Safety {
  all i1, i2 : pid, s : State | i1!=i2 =>  not (s.P[i1] = L4 && s.P[i2] = L4)
}

assert NotStuck {
  all pre : State - so/last |
    let post = so/next[pre] |
      some i : pid |
        RealTrans[i, pre, post] && !NOPTrans[i,pre,post]
}

pred TwoRun {
  some s1, s2: State, i1, i2: pid | {
    s1!=s2
    i1!=i2
    s1.P[i1] = L4
    s2.P[i2] = L4
  }
}

pred ThreeRun  {
  some disj s1, s2, s3: State, disj i1, i2, i3: pid | {
    s1.P[i1] = L4
    s2.P[i2] = L4
    s3.P[i3] = L4
  }
}

// 2 pids requires 8 states
// 3 pids requires 16 states
run TwoRun for 13 but 3 pid, 4 priority, 5 label_t expect 1

// haven't run this one successfully yet
run ThreeRun for 19 but 3 pid,4 priority,5 label_t expect 1

// how many states do we need for this to match murphi?
check Safety for 10 but 2 pid, 3 priority, 5 label_t expect 0

// this assertion is trivial because of the hack described above
check NotStuck for 10 but 2 pid, 3 priority, 5 label_t expect 0

// Model: algorithms/ring-orientation/stable-orient-ring.als

/*
 * A self-stabilizing algorithm for orienting uniform rings.
 * Communication model is the state-reading model.
 */

open util/boolean as bool
open util/ordering[Tick] as ord
open util/graph[Process] as graph

sig Process {
  rightNeighbor: Process,
  AP1, AP2: Process
}

fun leftNeighbor[p: Process]: Process {
  p.~(rightNeighbor)
}

fact {
  all p: Process {
     (p.AP1=p.rightNeighbor && p.AP2=leftNeighbor[p]) ||
     (p.AP2=p.rightNeighbor && p.AP1=leftNeighbor[p])
  }
}

fact DefineRing {
  graph/ring[rightNeighbor]
}

sig Tick {
  runs: set Process,
  dir, S, T: Process -> one Bool,
  ring_: Process -> Process
}
{
  all p: Process | p.ring_ = (p.dir=True => p.AP1 else p.AP2)
}

pred Eq3[b1,b2,b3: Bool] { b1 = b2 && b2 = b3 }
pred Eq4[b1,b2,b3,b4: Bool] { Eq3[b1,b2,b3] && b3=b4 }

fact  Transitions {
   all tp: Tick - ord/last | let tn = ord/next[tp] |
       all p: Process |
        let p1 = p.AP1, p2 = p.AP2, pS = tp.S, pT=tp.T, nS=tn.S, nT=tn.T |
           let S1p=p1.pS, S2p=p2.pS,
               T1p=p1.pT, T2p=p2.pT,
               Sp = p.pS, Sn=p.nS,
               Tp = p.pT, Tn=p.nT,
               dirp = p.(tp.dir), dirn = p.(tn.dir) | {
           p !in tp.runs => ( Sn = Sp && Tn = Tp && dirn = dirp ) else (
           S1p = S2p => ( Sn = Not[S1p] && Tn = True && dirn=dirp) else (
             (Eq3[S1p, Sp, Not[S2p]] &&
              Eq4[Not[T1p],Tp,T2p,True]) =>
                (Sn = Not[Sp] && Tn = False && dirn = True)
              else (
                 (Eq3[Not[S1p],Sp,S2p] && Eq4[T1p,Tp,Not[T2p],True]) =>
                 (Sn = Not[Sp] && Tn = False && dirn = False) else (
                    ((Eq3[S1p,Sp,Not[S2p]] && T1p=Tp) ||
                    (Eq3[Not[S1p],Sp,S2p] && Tp=T2p)) =>
                    (Tn = Not[Tp] && Sn=Sp && dirn=dirp) else (
                       Sn=Sp && Tn=Tp && dirn=dirp
                    )
                 )
              )
           )
         )
       }
}

pred RingAtTick[t: Tick] {
   let rng = t.ring_ |
      graph/ring[rng] || graph/ring[~rng]
}

assert Closure {
   // if the ring is properly oriented
   all t: Tick - ord/last |
      RingAtTick[t] => RingAtTick[ord/next[t]]
}

pred SomeState  {
   !graph/ring[ord/first.ring_]
   some t: Tick | graph/ring[t.ring_]
}

run SomeState for 1 but 2 Tick, 2 Bool, 3 Process expect 1
check Closure for 1 but 2 Tick, 2 Bool, 3 Process expect 1

// Model: logic/syllogism/syllogism.als
/**
 * Syllogism (Greek: συλλογισμός syllogismos, 
 * "conclusion, inference") is a kind of logical argument 
 * that applies deductive reasoning to arrive at a 
 * conclusion based on two or more propositions that 
 * are asserted or assumed to be true.
 *
 * In its earliest form, defined by Aristotle, from the 
 * combination of a general statement (the major premise) 
 * and a specific statement (the minor premise), a conclusion 
 * is deduced. 
 * 
 * For example, knowing that all men are mortal (major premise) 
 * and that Socrates is a man (minor premise), we may validly 
 * conclude that Socrates is mortal. Syllogistic arguments 
 * are usually represented in a three-line form:
 *
 *   All men are mortal.
 *   Socrates is a man.
 *   Therefore Socrates is mortal.
 */

	sig Men{}
	one sig Socrates {}

	check {

		all mortal, men : some Men + Socrates {

			men in mortal
			and  
			Socrates in men 
			=> Socrates in mortal

		}
	} for 5 Men

/**
 * This is very error prone since the following is not correct:
 *
 *   All men are mortal.
 *   Socrates is a mortal.
 *   Therefore Socrates is a man.
 *
 * Running the following example will therefore fail
 */

	check {

		all mortal, men : some Men + Socrates {

			men in mortal
			and  
			Socrates in mortal 
			=> Socrates in men

		}
	} for 5 Men

// Model: models/microsoft-com/com.als
/*
 * Model of Microsoft Component Object Model (COM) query
 * interface and aggregation mechanism.
 *
 * For a detailed description, see:
 * "COM revisited: tool-assisted modelling of an architectural framework"
 * -- Daniel Jackson, Kevin Sullivan
 *
 * author: Daniel Jackson
 */

open util/relation as rel

sig IID {}

sig Interface {
  qi : IID -> lone Interface,
  iids : set IID,
  // next two lines should use domain() or range() functions
  iidsKnown : IID,
  reaches : Interface
}{
  iidsKnown = dom[qi]
  reaches = ran[qi]
}

sig Component {
  interfaces : set Interface,
  iids : set IID,   // can't do iids = interfaces.Interface$iids
  first, identity : interfaces,
  eqs: set Component,
  aggregates : set Component
}

fact defineEqs {
  all c1, c2: Component |
    c1->c2 in eqs <=> c1.identity = c2.identity
}

fact IdentityAxiom {
  some unknown : IID | all c : Component |
    all i : c.interfaces | unknown.(i.qi) = c.identity
}

fact ComponentProps {
  all c : Component {
    c.iids = c.interfaces.iids
    all i : c.interfaces | all x : IID | x.(i.qi) in c.interfaces
  }
}

sig LegalInterface extends Interface { }
fact { all i : LegalInterface | all x : i.iidsKnown | x in x.(i.qi).iids}

sig LegalComponent extends Component { }
fact { LegalComponent.interfaces in LegalInterface }

fact Reflexivity { all i : LegalInterface | i.iids in i.iidsKnown }
fact Symmetry { all i, j : LegalInterface | j in i.reaches => i.iids in j.iidsKnown }
fact Transitivity { all i, j : LegalInterface | j in i.reaches => j.iidsKnown in i.iidsKnown }

fact Aggregation {
    no c : Component | c in c.^aggregates
    all outer : Component | all inner : outer.aggregates |
      (some inner.interfaces & outer.interfaces)
      && (some o: outer.interfaces | all i: inner.interfaces - inner.first | all x: Component  | (x.iids).(i.qi) = (x.iids).(o.qi))
    }

assert Theorem1 {
     all c: LegalComponent | all i: c.interfaces | i.iidsKnown = c.iids
     }

assert Theorem2 {
    all outer: Component | all inner : outer.aggregates |
        inner in LegalComponent => inner.iids in outer.iids
    }

assert Theorem3 {
    all outer: Component | all inner : outer.aggregates | inner in outer.eqs
    }

assert Theorem4a {
      all c1: Component, c2: LegalComponent |
         some (c1.interfaces & c2.interfaces) => c2.iids in c1.iids
    }

assert Theorem4b {
      all c1, c2: Component | some (c1.interfaces & c2.interfaces) => c1 in c2.eqs
      }

check Theorem1 for 3 expect 0
check Theorem2 for 3 expect 0
check Theorem3 for 3 expect 0
check Theorem4a for 3 expect 0
check Theorem4b for 3 expect 0

// Model: models/transport/railway.als

/*
 * A simple model of a railway system. Trains sit on segments of tracks
 * and segments overlap one another. It shows a that simple gate policy
 * does not ensure train safety.
 *
 * author: Daniel Jackson
 */

sig Seg {next, overlaps: set Seg}
fact {all s: Seg | s in s.overlaps}
fact {all s1, s2: Seg | s1 in s2.overlaps => s2 in s1.overlaps}

sig Train {}
sig GateState {closed: set Seg}
sig TrainState {on: Train -> lone Seg, occupied: set Seg}
fact {all x: TrainState |
  x.occupied = {s: Seg | some t: Train | t.(x.on) = s}
  }

pred Safe [x: TrainState] {all s: Seg | lone s.overlaps.~(x.on)}

pred MayMove [g: GateState, x: TrainState, ts: set Train] {
  no ts.(x.on) & g.closed
  }

pred TrainsMove [x, x": TrainState, ts: set Train] {
  all t: ts | t.(x".on) in t.(x.on).next
  all t: Train - ts | t.(x".on) = t.(x.on)
  }

pred GatePolicy [g: GateState, x: TrainState] {
  x.occupied.overlaps.~next in g.closed
  all s1, s2: Seg | some s1.next.overlaps & s2.next => lone (s1+s2) - g.closed
}

assert PolicyWorks {
  all x, x": TrainState, g: GateState, ts: set Train |
    {MayMove [g, x, ts]
    TrainsMove [x, x", ts]
    Safe [x]
    GatePolicy [g, x]
    } => Safe [x"]
  }

-- has counterexample in scope of 4
check PolicyWorks for 2 Train, 1 GateState, 2 TrainState, 4 Seg expect 1

pred TrainsMoveLegal [x, x": TrainState, g: GateState, ts: set Train] {
  TrainsMove [x, x", ts]
  MayMove [g, x, ts]
  GatePolicy [g, x]
  }
run TrainsMoveLegal for 3 expect 1



// DEFINED VARIABLES
// Defined variables are uncalled, no-argument functions.
// They are helpful for getting good visualization.
fun contains [] : TrainState -> Seg -> Train {
	{state: TrainState, seg: Seg, train: Train | seg = train.(state.on)}
}

// Model: models/firewire/firewire.als

/*
 * A model of leader election in the Firewire protocol.
 *
 * Adapted from:
 *   [DG+01] M.C.A. Devillers, W.O.D. GriAEoen, J.M.T Romijn, and F.W. Vaandrager.
 *   Verification of a leader election protocol -- formal methods applied to IEEE
 *   1394. Technical Report CSI-R9728, Computing Science Institute, University of
 *   Nijmegen, December 1997. Also, Formal Methods in System Design, 2001.
 *
 * This model describes a leader election protocol used in Firewire, an IEEE
 * standard for connecting consumer electronic devices. The model is a
 * straightforward translation into Alloy of a model [DG+01] developed in Lynch's
 * IO Automata which has been analyzed using PVS, a theorem prover, but which, as
 * far as we know, has not been subjected to fully automatic analysis. We are able
 * to express the key correctness property -- that exactly one leader is elected
 * -- more directly, as a trace property rather than a refinement property, and
 * can check it without the need for the 15 invariants used in the more
 * traditional proof. And the analysis does not hardwire
 * a particular topology, so would be tricky to do with a standard model checker.
 *
 * The network is assumed to consist of a collection of nodes connected by
 * links. Each link between a pair of nodes is matched by a link in the other
 * direction. Viewing a link and its dual as a single, undirected edge, the
 * network as a whole is assumed to form a tree. The purpose of the algorithm is
 * to construct such a tree; in the model, this is achieved by labelling some
 * subset of the links as parent links (each pointing from a node to its parent),
 * and by marking a single node as the root.
 *
 * The algorithm, described in detail elsewhere [DG+01], works briefly as
 * follows. When a node detects that all of its incoming links (or all but one)
 * has been marked as a parent link, it sends a message on each outgoing link,
 * either an acknowledgment (indicating its willingness to act as parent), or a
 * request (indicating its desire to be a child), according to whether the dual of
 * the outgoing link has been marked or not. Leaf nodes (with only one incoming
 * link) may thus initiate the algorithm by sending requests to their adjacent
 * nodes. Performing this action changes a node's status from {\em waiting} to
 * {\em active}. A node that is still waiting, and which receives a message on a
 * link, may label that link a parent link. Once active, a node that receives an
 * acknowledgment on a link may also label the link, but if it receives a request,
 * instead changes its node status to {\em contending}. The resolving of
 * contentions is modelled simplistically by a single action that arbitrarily
 * labels one of the two links a pair of contending nodes. Finally, a node all of
 * whose incoming links are parent links designates itself a root.
 *
 * The specification is given below. Each signature introduces a basic type
 * and some relations whose first column has that type:
 *
 * \begin{itemize}
 *
 * \item {\em Msg} represents the type of messages. {\em Req} is the request
 * message and {\em Ack} is the acknowledgment message; these are actually
 * declared as singleton (keyword {\em static}) subsets of {\em Msg}, the set of
 * all messages, that form a partition (keyword {\em part}).
 *
 * \item {\em Node} represents the nodes of the network. The relations {\em to}
 * and {\em from} associate each node with a set of incoming and outgoing links
 * respectively.
 *
 * \item {\em Link} represents the links. The relations {\em target} and {\em
 * source} map a link to its end nodes; {\em reverse} maps a link to its dual. The
 * facts in the signatures {\em Node} and {\em Link} ensure that all these
 * relations are consistent with one another: that the incoming links of a node
 * are those whose target is that node, etc.
 *
 * \item {\em Op} introduces a set of names for the operations of the
 * protocol. This is merely for convenience; it allows us to ask for an execution
 * in which named operations occur, or example.
 *
 * \item {\em State} represents the global states. Each state has a partition of
 * the nodes into one of four statuses: {\em waiting} to participate, {\em active}
 * (having sent messages on outgoing links), {\em contending} (having sent a
 * request on a link and received a request on its dual), and {\em elected}
 * (having designated itself as a root). A set of links are labelled as parent
 * links. There is a message queue associated with each link. Finally, the state
 * is associated with the operation that produced it.
 *
 * \item {\em Queue} represents the message queues. Each queue has a slot that
 * optionally contains a message; the relation {\em slot} is a partial function
 * from queues to messages. In our first attempt at a model, we represented a
 * queue as a sequence (a partial function from a prefix of the integers to
 * messages), but having checked that no queue ever contained more than one
 * message, we simplified the model. The {\em overflow} field is included just in
 * case this was a mistake; a write to a queue that already contains a message
 * puts an arbitrary value there, which is easily detected.
 *
 * \end{itemize}
 *
 * The {\em facts} record the assumptions about the topology. The one named {\em
 * Topology} says that there is some partial function on nodes and some root such
 * that (1) every node is reachable from the root ({\tt *r} being the reflexive
 * transitive closure of the relation {\tt r}); (2) there are no cycles (expressed
 * by saying that the transitive closure has no intersection with the identity
 * relation on nodes); and (3) the relation obtained by following the {\em source}
 * relation backwards (from a node to the link for which it is a source), and then
 * the {\em target} relation forwards (from the link to its target) is this
 * relation, plus its transpose (so that each tree edge becomes two
 * links). Although the quantifier appears to be higher-order, it will be
 * skolemized away by the analyzer.
 *
 * The {\em functions} of the model are parameterized formulas. The function {\em
 * Trans} relates a pre-state {\tt s} to a post-state {\tt s"}. It has a case for
 * each operation. Look at the clause for the operation {\em WriteReqOrAck}, for
 * example. If this operation is deemed to have occurred, each of the constraints
 * in the curly braces must hold. The first says that the labelling of links as
 * parent links is unchanged. The second constraint (the quantified formula)
 * constrains with respect to the node at which the operation occurs. The
 * subformulas, from first to last, say that the node belongs to the waiting set
 * before and the active set afterwards; that there is at most one ({\em sole})
 * link that is incoming but not a parent link in the pre-state; that there are no
 * changes to node status except at this node; that a message is queued onto each
 * outgoing link; and that queues on all other links are unchanged.
 *
 * An 'invoked' function is simply short for the formula in its body with the
 * formal arguments replaced by the actual expressions. {\em WriteQueue}, for
 * example, says that if the queue's slot is not filled in the pre-state, then the
 * new queue in the post-state (given the local name {\tt q}) contains the message
 * {\tt m} in its slot, and has no message in its overflow. Otherwise, some
 * message is placed arbitrarily in the overflow, and the slot is
 * unconstrained. In {\em WriteReqOrAck}, the arguments {\tt s} and {\tt s"} are
 * bound to the {\tt s} and {\tt s"} of {\em Trans}; {\tt x} is bound to one of
 * the outgoing links from the set {\tt n.from}; and {\tt msg} is bound either to
 * the acknowledgment or request message.
 *
 * The function {\em Execution} constrains the set of states. It makes use of a
 * library module that defines a polymorphic ordering relation. The expression
 * {\tt Ord[State]} gives an ordering on all states. The two formulas of the
 * function say that {\tt Initialization} holds in the first state, and that any
 * pair of adjacent states is related by {\tt Trans}. The function {\em NoRepeats}
 * adds the constraints that there are no equivalent states in the trace, and that
 * no stuttering occurs.
 *
 * The three assertions are theorems for which the analyzer will search for
 * counterexamples. They assert respectively that: in every state of the trace,
 * there is at most one node that has been elected; that there is some state in
 * which a node has been elected; and that no queue overflows.
 *
 * The rest of the model is a collection of commands executed to find instances of
 * the functions or counterexamples to the theorems. We started by presenting a
 * variety of functions as a sanity check; here, only one is given, that asks for
 * an execution involving 2 nodes, 4 links, 4 queues and a trace of 6 states. The
 * standard semantics of these {\em scope} declarations in Alloy is that the
 * numbers represent an upper bound, so an instance may involve fewer than 4
 * queues, for example. The ordering module (not shown here), however, for
 * technical reasons, constrains the ordered set to match its scope, so a trace
 * with fewer than 6 states will not be acceptable.
 *
 * We then established some bounds on the diameter of the state machine for
 * various topology bounds. For 2 nodes and 2 links, for example, there are no
 * non-repeating traces of length 4; checking traces of length 3 is thus
 * sufficient in this case. The number of queues was limited to 5, to accommodate
 * the empty queue, a queue containing an {\tt Ack} or {\tt Req}, and each of
 * these with overflow. For 3 nodes and 6 links, a trace length of 8 suffices.
 *
 * We then checked that for these various topology bounds, the queues never
 * overflow. Finally, we checked the correctness properties, taken advantage of
 * the earlier results that justify the short traces and queues. We are thus able
 * to verify the properties for all topologies involving the given number of nodes
 * and links, without any assumptions about trace length, queue size or the
 * particular topological structure.
 *
 * author: Daniel Jackson
 * visualization: Robert Seater
 */

open util/ordering[State] as ord

abstract sig Msg {}
one sig Req, Ack extends Msg {}

sig Node {to, from: set Link} {
  to = {x: Link | x.target = this}
  from = {x: Link | x.source = this}
  }

sig Link {target, source: Node, reverse: Link} {
  reverse.@source = target
  reverse.@target = source
  }

/**
 * at most one link between a pair of nodes in a given direction
 */
fact {no x,y: Link | x!=y && x.source = y.source && x.target = y.target}

/**
 * topology is tree-like: acyclic when viewed as an undirected graph
 */
fact Topology {
some tree: Node lone -> Node, root: Node {
  Node in root.*tree
  no ^tree & iden & Node->Node
  tree + ~tree = ~source.target
  }
}

sig Op {}
one sig Init, AssignParent, ReadReqOrAck, Elect, WriteReqOrAck,
ResolveContention, Stutter extends Op {}

sig State {
  disj waiting, active, contending, elected: set Node,
  parentLinks: set Link,
  queue: Link -> one Queue,
  op: Op -- the operation that produced the state
  } {
  waiting + active + contending + elected = Node
}

pred SameState [s, s": State] {
  s.waiting = s".waiting
  s.active = s".active
  s.contending = s".contending
  s.elected = s".elected
  s.parentLinks = s".parentLinks
  all x: Link | SameQueue [s.queue[x], s".queue[x]]
  }

pred Trans [s, s": State] {
  s".op != Init
  s".op = Stutter => SameState [s, s"]
  s".op = AssignParent => {
    some x: Link {
      x.target in s.waiting & s".waiting
      NoChangeExceptAt [s, s", x.target]
      ! IsEmptyQueue [s, x]
      s".parentLinks = s.parentLinks + x
      ReadQueue [s, s", x]
      }}
  s".op = ReadReqOrAck => {
    s".parentLinks = s.parentLinks
    some x: Link {
      x.target in s.(active + contending) & (PeekQueue [s, x, Ack] => s".contending else s".active)
      NoChangeExceptAt [s, s", x.target]
      ! IsEmptyQueue [s, x]
      ReadQueue [s", s, x]
      }}
  s".op = Elect => {
    s".parentLinks = s.parentLinks
    some n: Node {
      n in s.active & s".elected
      NoChangeExceptAt [s, s", n]
      n.to in s.parentLinks
      QueuesUnchanged [s, s", Link]
      }}
  s".op = WriteReqOrAck => {
    -- note how this requires access to child ptr
    s".parentLinks = s.parentLinks
    some n: Node {
      n in s.waiting & s".active
      lone n.to - s.parentLinks
      NoChangeExceptAt [s, s", n]
      all x: n.from |
        let msg = (x.reverse in s.parentLinks => Ack else Req) |
          WriteQueue [s, s", x, msg]
      QueuesUnchanged [s, s", Link - n.from]
      }}
  s".op = ResolveContention => {
    some x: Link {
      let contenders = x.(source + target) {
        contenders in s.contending & s".active
        NoChangeExceptAt [s, s", contenders]
        }
      s".parentLinks = s.parentLinks + x
      }
    QueuesUnchanged [s, s", Link]
    }
}

pred NoChangeExceptAt [s, s": State, nodes: set Node] {
  let ns = Node - nodes {
  ns & s.waiting = ns & s".waiting
  ns & s.active = ns & s".active
  ns & s.contending = ns & s".contending
  ns & s.elected = ns & s".elected
  }}

sig Queue {slot: lone Msg, overflow: lone Msg}

pred SameQueue [q, q": Queue] {
    q.slot = q".slot && q.overflow = q".overflow
  }

pred ReadQueue [s, s": State, x: Link] {
--  let q = s".queue[x] | no q.(slot + overflow)
  no s".queue[x].(slot + overflow)
  all x": Link - x | s".queue[x"] = s.queue[x"]
  }

pred PeekQueue [s: State, x: Link, m: Msg] {
  m = s.queue[x].slot
  }

pred WriteQueue [s, s": State, x: Link, m: Msg] {
        let q = s".queue[x] |
  no s.queue[x].slot =>
    ( q.slot = m && no q.overflow) else
    some q.overflow
  }

pred QueuesUnchanged [s, s": State, xs: set Link] {
  all x: xs | s".queue[x] = s.queue[x]
  }

pred IsEmptyQueue [s: State, x: Link] {
  no s.queue[x].(slot + overflow)
--  let q = s.queue[x] | no q.(slot + overflow)
  }

pred Initialization [s: State] {
  s.op = Init
  Node in s.waiting
  no s.parentLinks
  all x: Link | IsEmptyQueue [s, x]
  }

pred Execution  {
  Initialization [ord/first]
  all s: State - ord/last | let s" = ord/next[s] | Trans [s, s"]
  }

pred ElectionHappens {
    Execution
        some s: State | some s.elected
    some s: State | no s.elected
}

pred NoRepeats {
  Execution
  no s, s": State | s!=s" && SameState [s, s"]
  no s: State | s.op = Stutter
  }

pred NoShortCuts  {
  all s: State | -- remove this to speed up analysis - Ord[State].last - OrdPrev (Ord[State].last) |
    ! Trans [s, ord/next[ord/next[s]]]
  }

assert AtMostOneElected {
  Execution  => (all s: State | lone s.elected)
  }

assert OneEventuallyElected {
  Execution  => (some s: State | some s.elected)
  }

assert NoOverflow {
  Execution  => (all s: State, x: Link | no s.queue[x].overflow)
  }

run Execution for 7 Op, 2 Msg,
  2 Node, 4 Link, 4 Queue, 6 State expect 1

run ElectionHappens for 7 Op, 2 Msg,
  exactly 3 Node,  6 Link, 3 Queue, 7 State expect 1

-- solution for 3 State but not for 4 State
run NoRepeats for 7 Op, 2 Msg,
  2 Node, 2 Link, 2 Queue, 4 State expect 0

-- solution for 8 but not 9 State
run NoRepeats for 7 Op, 2 Msg,
    3 Node, 6 Link, 6 Queue, 8 State expect 0

-- only 5 queues needed: just count
-- no solution: establishes at most 3 queues needed
check NoOverflow for 7 Op, 2 Msg,
  3 Node, 6 Link, 5 Queue, 9 State expect 0

check AtMostOneElected for 7 Op, 2 Msg,
  3 Node, 6 Link, 3 Queue, 9 State expect 0

check OneEventuallyElected for 7 Op, 2 Msg,
  3 Node, 6 Link, 3 Queue, 9 State expect 1



// DEFINED VARIABLES
// Defined variables are uncalled, no-argument functions.
// They are helpful for getting good visualization.
fun queued: State -> Link -> Msg {
  {s: State, L: Link, m: Msg | m in L.(s.queue).slot}
}

// Model: models/logic/philosophers.als

open util/ordering[Table]

sig Table {
	setting 	: P -> Fork
}


sig Fork {}

sig P {
	next			: P,
	left, right 	: Fork
} {
	right = next.@left
}

let update[table",settings"] = no table" or table".setting=settings"

let take[ philosopher, fork, table, table"] {
	no table.setting.fork
	table".update[ table.setting + philosopher -> fork ]
}

let eat[ philosopher, table,  table" ] {
	let forks = table.setting[philosopher] {
		# forks = 2
		table".update[ table.setting - philosopher->forks ]
	}
}

let wait[p,table,tableOrNone"] = {
	one tableOrNone"
	tableOrNone".setting = table.setting
}

pred step[ philosopher : P, table : Table, table" : lone Table ] {
		philosopher.take[ philosopher.left, 	table, table" ]
	or 	philosopher.take[ philosopher.right, 	table, table" ]
	or	philosopher.eat[ 						table, table" ]
	or  philosopher.wait[						table, table" ]

}

fact trace {
	ring[P]
	bijective[left] and bijective[right]

	no first.setting

	all table : Table - last | 
		some p : P | p.step[ table, table.next ]
}

assert Liveliness {
	no table : Table | no philosopher : P | philosopher.step[table,none]
}


run { #P = 4 } for 4

check Liveliness for 15 but exactly 4 P, 4 Fork, 4 int

// macros

let ring[group] 		= all member : group | member.^next = group
let bijective[relation] = ( all d,r : univ | d.relation = r <=> relation.r = d )
let domain[ relation ] 	= relation.univ
let range[  relation ] 	= univ.relation


// Model: models/java/java-map.als

/**
  A partial formal definition of a Map in Java

	See http://aqute.biz/2017/07/15/Alloy.html
*/


sig Object {}
one sig null extends Object 	{}
enum boolean { true, false }

sig Map {
	entries : Object -> lone Object
}

fun Map.size : Int {
		# this.entries
}

pred Map.isEmpty {
		no entries
}

pred Map.containsKey( k : Object ) {
	one this.entries[k]
}


pred Map.containsValue( v : Object ) {
	one this.entries.v
}

fun Map.get( k : Object ) : Object {
	let v = this.entries[k] | one v implies v else null
}

pred Map.put( m" : Map,  k, v, r : Object ) {
	this.get[k] = r
	m".entries = this.entries ++ k -> v
}

pred Map.remove( m" : Map,  k, r: Object ) {
	this.containsKey[k] 
		implies { 
					m".entries = this.entries - k->Object
			and	this.get[k] = r
		} else {
			r = null
			m".entries = this.entries
		}
}

pred Map.putAll( m", other : Map ) {
	m".entries = this.entries ++ other.entries
}

fun Map.keySet : set Object {
	this.entries.Object
}

fun Map.values : set Object {
	this.entries[Object]
}

pred Map.clear( m" : Map ) {
	m".isEmpty
}

fun Map.entrySet : Object -> Object {
	this.entries
}

pred equals( a,b : Map ) {
	a.keySet = b.keySet
	all k : a.keySet | a.get[k] = b.get[k]
}

pred Map.putIfAbsent( m" : Map, k, initial, r : Object ) {
	this.containsKey[k] 
		implies r = this.get[k] 
		else ( r=null and this.put[m",k,initial,null])
}

pred Map.remove( m" : Map, k, v : Object, r : boolean ) {
	k -> v in this.entries 
		implies ( m".entries = this.entries - k -> v
			and r = true ) 
		else r=false
}

pred Map.replace( m" : Map, k, oldValue, newValue : Object, r : boolean ) {
		this.put[m",k,newValue,oldValue] implies r = true else r = false
}

/*
 * Replaces the entry for the specified key only if it is
 * currently mapped to some value.
 */

pred Map.replace( m" : Map, k, v, r : Object ) {
		this.containsKey[k] implies this.put[m",k,v,r] else r = null
}



// Verifications

pred Map.put"(m" : Map, k, v, r : Object ) {

	m".containsKey[k]
	m".get[k] = v
	this.get[k]  = r 

	this.containsKey[k]
		implies {
			this.size = m".size

			r = null or r != null
		} else {
			this.size.plus[1] = m".size
			r = null
		}
}

pred Map.clear"[ m" : Map ] {
	m".size = 0
	all k : Object | {
		m".get[k] = null
		not m".containsKey[k]
	}
}

pred Map.remove"( m" : Map, k, r : Object) {
	not m".containsKey[k]

	this.containsKey[k] implies {
		this.get[k] = r
		this.size.minus[1] = m".size
	} else {
		r = null
		this.size = m".size
	}
}

pred Map.putAll"( m", other : Map ) {

	this.keySet + other.keySet = m".keySet

	all k : this.keySet + other.keySet | {
		let v = k in other.keySet 
			implies other.get[k] 
			else 		this.get[k] | {
				m".get[k] = v
			}
	}
}

assert verify {

	all m, m", other : Map, k, v, r : Object | {
		m.put[m", k, v, r ] 		implies m.put"[m",k,v,r]
		m.clear[m"]          		implies m.clear"[m"]
		m.remove[m",k, r]				implies m.remove"[m",k,r]
		m.putAll[m",other]			implies m.putAll"[m",other]
	}

}

check verify for 4 but 2 Map



fact {
	# Map > 0
}

// Model: models/java/javatypes.als


/*
 * A simple model of typing in Java.
 *
 * This model describes the basic notions of typing in Java.
 * It ignores primitive types and null references. Each type has
 * some set of subtypes. Types are partitioned into class and
 * interface types. Object is a particular class.
 *
 * The fact TypeHierarchy says that every type is a direct or
 * indirect subtype of Object; that no type is a direct or indirect
 * of itself; and every type is a subtype of at most one class.
 *
 * An object instance has a type (its creation type) that is a class.
 * A variable may hold an instance, and has a declared type. The
 * fact TypeSoundness says that all instances held by a variable
 * have types that are direct or indirect subtypes of the variable's
 * declared type.
 *
 * The function Show specifies a case in which there is a class
 * distinct from Object; there is some interface; and some variable
 * has a declared type that is an interface.
 *
 * author: Daniel Jackson, 11/13/01
 */

abstract sig Type {subtypes: set Type}
sig Class, Interface extends Type {}
one sig Object extends Class {}
fact TypeHierarchy {
  Type in Object.*subtypes
  no t: Type | t in t.^subtypes
  all t: Type | lone t.~subtypes & Class
  }
sig Instance {type: Class}
sig Variable {holds: lone Instance, type: Type}
fact TypeSoundness {
  all v: Variable | v.holds.type in v.type.*subtypes
  }
pred Show  {
  some Class - Object
  some Interface
  some Variable.type & Interface
  }
run Show for 3 expect 1

// Model: models/java/javatypes_soundness.als

/*
 * Model of the Java type system. The TypeSoundness assertion
 * claims that if a Java program type checks successfully,
 * then a field will cannot be assigned an incorrect type.
 *
 * author: Daniel Jackson
 */

open util/graph[Type] as graph

abstract sig Type {
  xtends: set Type
  }
sig Interface extends Type {}
  { xtends in Interface }
sig Class extends Type {
  implements: set Interface,
  fields: set Field
  } { lone xtends && xtends in Class }
-- optional: best omitted to allow private etc
-- {xtends.@fields in fields}
sig Field {
  declType: Type
  }

fact {
  graph/dag[xtends]
  }

abstract sig Value {}
one sig Null extends Value {}
sig Object extends Value {
  type: Class,
  slot: Field lone -> lone Slot
  } {slot.Slot = type.fields}
sig Slot {}

abstract sig Statement {}
sig Assignment extends Statement {
  v: Variable,
  expr: Expr
  }
sig Setter extends Statement {
  field: Field,
  lexpr, rexpr: Expr
  }

abstract sig Expr {
  type: Type,
  subexprs: set Expr
  } {subexprs = this + this.^@expr}
sig Variable extends Expr {
  declType: Type
  } {type = declType}
sig Constructor extends Expr {
  class: Class
  }
sig Getter extends Expr {
  field: Field,
  expr: Expr
  } {type = field.declType}

sig State {
  objects: set Object,
  reaches: Object -> Object,
  vars: set Variable,
  holds: (Slot + Variable) -> lone Value,
  val: Expr -> lone Value
  } {
  all o: Object | o.reaches = holds[o.slot[Field]] & Object
  holds.Value & Variable = vars
  objects = holds[vars].^reaches
  all e: Expr | let v = val[e] {
    e in Variable => v = holds[e]
    e in Getter => v = holds[(val[e.expr]).slot[e.field]]
    e in Constructor => v in Object and v.type = e.type }
  }

pred RuntimeTypesOK [s: State] {
  all o: s.objects, f: o.type.fields |
    let v = s.holds [o.slot [f]] | HasType [v, f.declType]
  all v: s.vars |
    let v = s.holds [v] | HasType [v, v.declType]
  }

pred HasType [v: Value, t: Type] {
  v in Null or Subtype [v.type, t]
  }

pred Subtype [t, t": Type] {
  t in Class =>
     (let supers = (t & Class).*(Class<:xtends) |
        t" in (supers + supers.implements.*(Interface<:xtends)))
  t in Interface => t" in (t & Interface).*(Interface<:xtends)
  }

pred TypeChecksSetter [stmt: Setter] {
  all g: Getter & stmt.(lexpr+rexpr).subexprs | g.field in g.expr.type.fields
  stmt.field in stmt.lexpr.type.fields
  Subtype [stmt.rexpr.type, stmt.field.declType]
  }

pred ExecuteSetter [s, s": State, stmt: Setter] {
  stmt.(rexpr+lexpr).subexprs & Variable in s.vars
  s".objects = s.objects and s".vars = s.vars
  let rval = s.val [stmt.rexpr], lval = s.val [stmt.lexpr] {
    no lval & Null
    s".holds = s.holds ++ (lval.slot[stmt.field] -> rval)
   }
  }

assert TypeSoundness {
  all s, s": State, stmt: Setter |
    {RuntimeTypesOK[s]
    ExecuteSetter [s, s", stmt]
    TypeChecksSetter[stmt]
    } => RuntimeTypesOK[s"]
  }

fact {all o, o": Object | some o.slot[Field] & o".slot[Field] => o = o"}
fact {all g: Getter | no g & g.^subexprs}

fact ScopeFact {
  #Assignment =< 1
  #Class =< 5
  #Interface =< 5
}

check TypeSoundness for 3 expect 0

check TypeSoundness for 2 State, 1 Assignment,
1 Statement, 5 Interface, 5 Class, 1 Null,
7 Object, 12 Expr, 3 Field, 3 Slot expect 0

// very slow
// check TypeSoundness for 2 State, 1 Statement,
// 10 Type, 8 Value, 12 Expr,
// 3 Field, 3 Slot expect 0

// Model: models/typography/paragraph-numbering.als
/*
 * Alloy model of paragraph numbering
 *
 * This model addresses some issues that arose in the design of a text tagging tool. The
 * tool receives as input a text stream in which paragraphs are tagged with style names,
 * along with a style sheet that indicates how paragraphs of a given style are to be numbered.
 * In practice, the style sheet includes such details as what symbols to use for numbering (eg,
 * roman numericals, letters of the alphabet, etc), but these details are uninteresting.
 *
 * In the simplest case, the styles are organized into chains. For example, there may be a
 * single chain, chapter-section-subsection, so that chapters are numbered 1, 2, 3, etc,
 * sections are numbered 1.1, 1.2, 1.3, etc, and subsections are numbered 1.1.1, 1.1.2,
 * etc, each paragraph being numbered according to a number associated with its own
 * style, and a number for each ancestor.
 *
 * Some styles, however, should be numbered independently of one another, but still
 * according to the same ancestors. For example, we might also have a figure style
 * that is numbered, like section, according to its chapter, with figures and sections in
 * some arbitrary interleaving, the numbering of one not affecting the other.
 *
 * So in our style hierarchy, a style can have more than one "child". A more tricky complication
 * allows multiple parents. We might want to have an appendix style, for example, with a
 * different numbering from the chapter style, but would want section and subsection to work
 * within appendix exactly as they would work within chapter. So the first section in an
 * appendix numbered A might be numbered A.1, but if placed in a chapter numbered 1,
 * it would be numbered 1.1 instead.
 *
 * To account for this, styles are organized into replacement classes. Chapter and appendix,
 * for example, are replacements of one another. When a chapter style is encountered, it
 * is as if the style hierarchy contains only chapter, with children section, figure and so on;
 * when appendix is encountered subsequently, chapter is replaced, and figure and section
 * become children of appendix. We'll call the set of styles active in the tree at a given time
 * the "context".
 *
 * The first part focuses on the replacement mechanism. It characterizes a well-formed
 * style sheet (with the fact StyleSheet), and a well-formed state (with the fact Forest). An
 * operation addStyleToContext describes how the context is altered, and includes a
 * precondition requiring that, for example, a child is not encountered before its parents
 * (a document can't start with subsection, eg). The assertion PreservesForest checks that the
 * operation preserves the well-formedness of the state; it was analyzing this that helped
 * determine an appropriate precondition and the appropriate constraints in the invariant.
 *
 * The second part adds the numbering of styles. Note the idiom of declaring a subsignature
 * and then equating it to the supersignature, thus essentially retrofitting the new fields to the
 * old signature. A second operation describes how numbers are assigned; the conjunction of the
 * two operations is what happens when a style is encountered. The assertion AddNeverReduces
 * checks that when a style is encountered the number associated with each style in the context is
 * not decreased. The first assertion is valid; the second isn't.
 *
 * author: Daniel Jackson, 11/15/01
 */

open util/relation as rel

sig Style {
    replaces, parents: set Style
    }

fact StyleSheet {
    equivalence [replaces, Style]
    acyclic [parents, Style]
    all x: Style {
        x.replaces.parents.replaces = x.parents
        all y,z: x.parents | y in z.replaces
        }
    }

sig State {
    context: set Style,
    ancestors: Style -> Style
    }

fact DefineAncestors {
    all s: State, x: Style | s.ancestors [x] = x.*parents & s.context
    }

pred Forest [s: State] {
    all x: s.context |
        some root: s.ancestors[x] {
            no root.parents
            all y: s.ancestors[x] - root | one y.parents & s.context
            }
    all x: Style | lone x.replaces & s.context
    }

pred AddStyleToContext [s, s": State, style: Style] {
    all x: style.^parents | some x.replaces & s.context
    s".context = s.context - style.replaces + style
    }

assert PreserveForest {
    all s,s": State, z: Style |
        Forest[s] && AddStyleToContext [s,s",z] => Forest[s"]
    }

check PreserveForest for 4 expect 0

sig Value {next: Value}
sig NumberedStyle extends Style {
    initial: Value
    }
sig NumberedState extends State {
    value: Style -> one Value
    }
fact {Style = NumberedStyle}
fact {State = NumberedState}

pred AddStyleToNumbering [s, s": State, style: Style] {
    s".value[style] = (style in s.context => s.value[style].next else style.initial)
    s".context = s.context - style.replaces + style
    all x: Style - style |
        s".value[x] = (style in x.^parents => x.initial else s.value[x])
    }

pred AddStyle [s, s": State, style: Style] {
    AddStyleToContext [s,s",style]
    AddStyleToNumbering [s,s",style]
    }

assert AddNeverReduces {
    all s,s": State, z: Style |
        Forest[s] && AddStyle [s,s",z] =>
            (all y: s".context | s".value[y] in s.value[y].*next)
    }

check AddNeverReduces for 5 expect 1


// Model: models/file-system/file_system.als

/*
 * Model of a generic file system.
 */

abstract sig Object {}

sig Name {}

sig File extends Object {} { some d: Dir | this in d.entries.contents }

sig Dir extends Object {
  entries: set DirEntry,
  parent: lone Dir
} {
  parent = this.~@contents.~@entries
  all e1, e2 : entries | e1.name = e2.name => e1 = e2
  this !in this.^@parent
  this != Root => Root in this.^@parent
}

one sig Root extends Dir {} { no parent }

lone sig Cur extends Dir {}

sig DirEntry {
  name: Name,
  contents: Object
} {
  one this.~entries
}


/**
 * all directories besides root have one parent
 */
pred OneParent_buggyVersion {
    all d: Dir - Root | one d.parent
}

/**
 * all directories besides root have one parent
 */
pred OneParent_correctVersion {
    all d: Dir - Root | (one d.parent && one contents.d)
}

/**
 * Only files may be linked (that is, have more than one entry)
 * That is, all directories are the contents of at most one directory entry
 */
pred NoDirAliases {
    all o: Dir | lone o.~contents
}

check { OneParent_buggyVersion => NoDirAliases } for 5 expect 1

check { OneParent_correctVersion => NoDirAliases } for 5 expect 0

// Model: utilities/types/boolean.als
module util/boolean

/*
 * Creates a Bool type with two singleton subtypes: True
 * and False. Provides common boolean operations.
 *
 * author: Greg Dennis
 */

abstract sig Bool {}
one sig True, False extends Bool {}

pred isTrue[b: Bool] { b in True }

pred isFalse[b: Bool] { b in False }

fun Not[b: Bool] : Bool {
  Bool - b
}

fun And[b1, b2: Bool] : Bool {
  subset_[b1 + b2, True]
}

fun Or[b1, b2: Bool] : Bool {
  subset_[True, b1 + b2]
}

fun Xor[b1, b2: Bool] : Bool {
  subset_[Bool, b1 + b2]
}

fun Nand[b1, b2: Bool] : Bool {
  subset_[False, b1 + b2]
}

fun Nor[b1, b2: Bool] : Bool {
  subset_[b1 + b2, False]
}

fun subset_[s1, s2: set Bool] : Bool {
  (s1 in s2) => True else False
}

// Model: utilities/types/graph.als
module util/graph[node]

/*
 * Utilities for some common operations and constraints
 * on graphs.
 *
 * author: Greg Dennis
 */

open util/relation as rel

/** graph in undirected */
pred undirected [r: node->node] {
  symmetric[r]
}

/** graph has no self-loops */
pred noSelfLoops[r: node->node] {
  irreflexive[r]
}

/** graph is weakly connected */
pred weaklyConnected[r: node->node] {
  all n1, n2: node | n1 in n2.*(r + ~r)  // Changed from ^ to * to permit singleton
}

/** graph is strongly connected */
pred stronglyConnected[r: node->node] {
  all n1, n2: node | n1 in n2.*r         // Changed from ^ to * to permit singleton
}

/** graph is rooted at root */
pred rootedAt[r: node->node, root: node] {
  node in root.*r
}

/** graph is a ring */
pred ring [r: node->node] {
  all n: node | one n.r && rootedAt[r, n]
}

/** graph is a dag */
pred dag [r: node->node] {
  acyclic[r, node]
}

/** graph is a forest */
pred forest [r: node->node] {
  dag[r]
  all n: node | lone r.n
}

/** graph is a tree */
pred tree [r: node->node] {
  forest[r]
  lone root: node | no r.root
}

/** graph is a tree rooted at root */
pred treeRootedAt[r: node->node, root: node] {
  forest[r]
  rootedAt[r, root]
}

/** returns the roots of the graph */
fun roots [r: node->node] : set node {
  node - node.^r
}

/** returns the leaves of the graph */
fun leaves [r: node->node] : set node {
  node - node.^~r
}

/** returns the inner nodes (non-leaves) of the graph */
fun  innerNodes [r: node->node] : set node {
  node - leaves[r]
}

// Model: utilities/types/integer.als
module util/integer

/*
 * A collection of utility functions for using Integers in Alloy.
 * Note that integer overflows are silently truncated to the current bitwidth
 * using the 2's complement arithmetic, unless the "forbid overfows" option is
 * turned on, in which case only models that don't have any overflows are 
 * analyzed. 
 */

fun add  [n1, n2: Int] : Int { this/plus[n1, n2] }
fun plus [n1, n2: Int] : Int { n1 fun/add n2 }

fun sub   [n1, n2: Int] : Int { this/minus[n1, n2] }
fun minus [n1, n2: Int] : Int { n1 fun/sub n2 }

fun mul [n1, n2: Int] : Int { n1 fun/mul n2 }

/**
 * Performs the division with "round to zero" semantics, except the following 3 cases
 * 1) if a is 0, then it returns 0
 * 2) else if b is 0, then it returns 1 if a is negative and -1 if a is positive
 * 3) else if a is the smallest negative integer, and b is -1, then it returns a
 */
fun div [n1, n2: Int] : Int { n1 fun/div n2 }

/** answer is defined to be the unique integer that satisfies "a = ((a/b)*b) + remainder" */
fun rem [n1, n2: Int] : Int { n1 fun/rem n2 }

/** negate */
fun negate [n: Int] : Int { 0 fun/sub n }

/** equal to */
pred eq [n1, n2: Int] { int[n1] = int[n2] }

/** greater than */
pred gt [n1, n2: Int] { n1 > n2 }

/** less then */
pred lt [n1, n2: Int] { n1 < n2 }

/** greater than or equal */
pred gte [n1, n2: Int] { n1 >= n2 }

/** less than or equal */
pred lte [n1, n2: Int] { n1 <= n2 }

/** integer is zero */
pred zero [n: Int] { n = 0 }

/** positive */
pred pos  [n: Int] { n > 0 }

/** negative */
pred neg  [n: Int] { n < 0 }

/** non-positive */
pred nonpos [n: Int] { n <= 0 }

/** non-negative */
pred nonneg [n: Int] { n >= 0 }

/** signum (aka sign or sgn) */
fun signum [n: Int] : Int { n<0 => (0 fun/sub 1) else (n>0 => 1 else 0) }

/**
 * returns the ith element (zero-based) from the set s
 * in the ordering of 'next', which is a linear ordering
 * relation like that provided by util/ordering
 */
fun int2elem[i: Int, next: univ->univ, s: set univ] : lone s {
  {e: s | #^next.e = int i }
}

/**
 * returns the index of the element (zero-based) in the
 * ordering of next, which is a linear ordering relation
 * like that provided by util/ordering
 */
fun elem2int[e: univ, next: univ->univ] : lone Int {
  Int[#^next.e]
}

/** returns the largest integer in the current bitwidth */
fun max:one Int { fun/max }

/** returns the smallest integer in the current bitwidth */
fun min:one Int { fun/min }

/** maps each integer (except max) to the integer after it */
fun next:Int->Int { fun/next }

/** maps each integer (except min) to the integer before it */
fun prev:Int->Int { ~next }

/** given a set of integers, return the largest element */
fun max [es: set Int]: lone Int { es - es.^prev }

/** given a set of integers, return the smallest element */
fun min [es: set Int]: lone Int { es - es.^next }

/** given an integer, return all integers prior to it */
fun prevs [e: Int]: set Int { e.^prev }

/** given an integer, return all integers following it */
fun nexts [e: Int]: set Int { e.^next }

/** returns the larger of the two integers */
fun larger [e1, e2: Int]: Int { let a=int[e1], b=int[e2] | (a<b => b else a) }

/** returns the smaller of the two integers */
fun smaller [e1, e2: Int]: Int { let a=int[e1], b=int[e2] | (a<b => a else b) }

// Model: utilities/types/natural.als
module util/natural

/*
 * Utility function and predicates for using the set of
 * nonnegative integers (0, 1, 2, . . .). The number of
 * naturals present in an analysis will be equal to the
 * scope on Natural. Specifically, if the scope on Natural
 * is N, then the naturals 0 through N-1 will be present.
 *
 * Note that the functions that return Naturals, such as
 * 'add' and 'div', may return an empty set if no such
 * Natural exists for that integer value.
 *
 * To write an Alloy model that makes use of negative
 * integers, use the util/integer module instead.
 *
 * @author Greg Dennis
 */

private open util/ordering[Natural] as ord
private open util/integer as integer

sig Natural {}

/** the integer zero */
one sig Zero in Natural {}

/** the integer one will be the empty set if the scope on Natural is less than two */
lone sig One in Natural {}

fact {
  first in Zero
  next[first] in One
}

/** returns n + 1 */
fun inc [n: Natural] : lone Natural { ord/next[n] }

/** returns n - 1 */
fun dec [n: Natural] : lone Natural { ord/prev[n] }

/** returns n1 + n2 */
fun add [n1, n2: Natural] : lone Natural {
  {n: Natural | #ord/prevs[n] = plus[#ord/prevs[n1], #ord/prevs[n2]]}
}

/** returns n1 - n2 */
fun sub [n1, n2: Natural] : lone Natural {
  {n: Natural | #ord/prevs[n1] = plus[#ord/prevs[n2], #ord/prevs[n]]}
}

/** returns n1 * n2 */
fun mul [n1, n2: Natural] : lone Natural {
  {n: Natural | #ord/prevs[n] = #(ord/prevs[n1]->ord/prevs[n2])}
}

/** returns n1 / n2 */
fun div [n1, n2: Natural] : lone Natural {
  {n: Natural | #ord/prevs[n1] = #(ord/prevs[n2]->ord/prevs[n])}
}

/**  returns true iff n1 is greater than n2 */
pred gt  [n1, n2: Natural] { ord/gt [n1, n2] }

/**  returns true iff n1 is less than n2 */
pred lt  [n1, n2: Natural] { ord/lt [n1, n2] }

/**  returns true iff n1 is greater than or equal to n2 */
pred gte [n1, n2: Natural] { ord/gte[n1, n2] }

/**  returns true iff n1 is less than or equal to n2 */
pred lte [n1, n2: Natural] { ord/lte[n1, n2] }

/** returns the maximum integer in ns */
fun max [ns: set Natural] : lone Natural { ord/max[ns] }

/** returns the minimum integer in ns */
fun min [ns: set Natural] : lone Natural { ord/min[ns] }

// Model: utilities/types/ordering.als
module util/ordering[exactly elem]

/*
 * Creates a single linear ordering over the atoms in elem. It also constrains all
 * the atoms to exist that are permitted by the scope on elem. That is, if the scope
 * on a signature S is 5, opening util/ordering[S] will force S to have 5 elements
 * and create a linear ordering over those five elements. The predicates and
 * functions below provide access to properties of the linear ordering, such as
 * which element is first in the ordering, or whether a given element precedes
 * another. You cannotcreate multiple linear orderings over the same signature with
 * this model. If you that functionality, try using the util/sequence module instead.
 *
 * Technical comment:
 * An important constraint: elem must contain all atoms permitted by the scope.
 * This is to let the analyzer optimize the analysis by setting all fields of each
 * instantiation of Ord to predefined values: e.g. by setting 'last' to the highest
 * atom of elem and by setting 'next' to {<T0,T1>,<T1,T2>,...<Tn-1,Tn>}, where n is
 * the scope of elem. Without this constraint, it might not be true that Ord.last is
 * a subset of elem, and that the domain and range of Ord.next lie inside elem.
 *
 * author: Ilya Shlyakhter
 * revisions: Daniel jackson
 */

private one sig Ord {
   First: set elem,
   Next: elem -> elem
} {
   pred/totalOrder[elem,First,Next]
}

/** first */
fun first: one elem { Ord.First }

/** last */
fun last: one elem { elem - (next.elem) }

/** return a mapping from each element to its predecessor */
fun prev : elem->elem { ~(Ord.Next) }

/** return a mapping from each element to its successor */
fun next : elem->elem { Ord.Next }

/** return elements prior to e in the ordering */
fun prevs [e: elem]: set elem { e.^(~(Ord.Next)) }

/** return elements following e in the ordering */
fun nexts [e: elem]: set elem { e.^(Ord.Next) }

/** e1 is less than e2 in the ordering */
pred lt [e1, e2: elem] { e1 in prevs[e2] }

/** e1 is greater than e2 in the ordering */
pred gt [e1, e2: elem] { e1 in nexts[e2] }

/** e1 is less than or equal to e2 in the ordering */
pred lte [e1, e2: elem] { e1=e2 || lt [e1,e2] }

/** e1 is greater than or equal to e2 in the ordering */
pred gte [e1, e2: elem] { e1=e2 || gt [e1,e2] }

/** returns the larger of the two elements in the ordering */
fun larger [e1, e2: elem]: elem { lt[e1,e2] => e2 else e1 }

/** returns the smaller of the two elements in the ordering */
fun smaller [e1, e2: elem]: elem { lt[e1,e2] => e1 else e2 }

/**
 * returns the largest element in es
 * or the empty set if es is empty
 */
fun max [es: set elem]: lone elem { es - es.^(~(Ord.Next)) }

/**
 * returns the smallest element in es
 * or the empty set if es is empty
 */
fun min [es: set elem]: lone elem { es - es.^(Ord.Next) }

assert correct {
  let mynext = Ord.Next |
  let myprev = ~mynext | {
     ( all b:elem | (lone b.next) && (lone b.prev) && (b !in b.^mynext) )
     ( (no first.prev) && (no last.next) )
     ( all b:elem | (b!=first && b!=last) => (one b.prev && one b.next) )
     ( !one elem => (one first && one last && first!=last && one first.next && one last.prev) )
     ( one elem => (first=elem && last=elem && no myprev && no mynext) )
     ( myprev=~mynext )
     ( elem = first.*mynext )
     (all disj a,b:elem | a in b.^mynext or a in b.^myprev)
     (no disj a,b:elem | a in b.^mynext and a in b.^myprev)
     (all disj a,b,c:elem | (b in a.^mynext and c in b.^mynext) =>(c in a.^mynext))
     (all disj a,b,c:elem | (b in a.^myprev and c in b.^myprev) =>(c in a.^myprev))
  }
}
run {} for exactly 0 elem expect 0
run {} for exactly 1 elem expect 1
run {} for exactly 2 elem expect 1
run {} for exactly 3 elem expect 1
run {} for exactly 4 elem expect 1
check correct for exactly 0 elem
check correct for exactly 1 elem
check correct for exactly 2 elem
check correct for exactly 3 elem
check correct for exactly 4 elem
check correct for exactly 5 elem

// Model: utilities/types/relation.als
module util/relation

/*
 * Utilities for some common operations and constraints
 * on binary relations. The keyword 'univ' represents the
 * top-level type, which all other types implicitly extend.
 * Therefore, all the functions and predicates in this model
 * may be applied to binary relations of any type.
 *
 * author: Greg Dennis
 */

/** returns the domain of a binary relation */
fun dom [r: univ->univ] : set (r.univ) { r.univ }

/** returns the range of a binary relation */
fun ran [r: univ->univ] : set (univ.r) { univ.r }

/** r is total over the domain s */
pred total [r: univ->univ, s: set univ] {
  all x: s | some x.r
}

/** r is a partial function over the domain s */
pred functional [r: univ->univ, s: set univ] {
  all x: s | lone x.r
}

/** r is a total function over the domain s */
pred function [r: univ->univ, s: set univ] {
  all x: s | one x.r
}

/** r is surjective over the codomain s */
pred surjective [r: univ->univ, s: set univ] {
  all x: s | some r.x
}

/** r is injective */
pred injective [r: univ->univ, s: set univ] {
  all x: s | lone r.x
}

/** r is bijective over the codomain s */
pred bijective[r: univ->univ, s: set univ] {
  all x: s | one r.x
}

/** r is a bijection over the domain d and the codomain c */
pred bijection[r: univ->univ, d, c: set univ] {
  function[r, d] && bijective[r, c]
}

/** r is reflexive over the set s */
pred reflexive [r: univ -> univ, s: set univ] {s<:iden in r}

/** r is irreflexive */
pred irreflexive [r: univ -> univ] {no iden & r}

/** r is symmetric */
pred symmetric [r: univ -> univ] {~r in r}

/** r is anti-symmetric */
pred antisymmetric [r: univ -> univ] {~r & r in iden}

/** r is transitive */
pred transitive [r: univ -> univ] {r.r in r}

/** r is acyclic over the set s */
pred acyclic[r: univ->univ, s: set univ] {
  all x: s | x !in x.^r
}

/** r is complete over the set s */
pred complete[r: univ->univ, s: univ] {
  all x,y:s | (x!=y => x->y in (r + ~r))
}

/** r is a preorder (or a quasi-order) over the set s */
pred preorder [r: univ -> univ, s: set univ] {
  reflexive[r, s]
  transitive[r]
}

/** r is an equivalence relation over the set s */
pred equivalence [r: univ->univ, s: set univ] {
  preorder[r, s]
  symmetric[r]
}

/** r is a partial order over the set s */
pred partialOrder [r: univ -> univ, s: set univ] {
  preorder[r, s]
  antisymmetric[r]
}

/** r is a total order over the set s */
pred totalOrder [r: univ -> univ, s: set univ] {
  partialOrder[r, s]
  complete[r, s]
}

// Model: utilities/types/seqrel.als
module util/seqrel[elem]

/*
 * A sequence utility for modeling sequences as just a
 * relation as opposed to reifying them into sequence
 * atoms like the util/sequence module does.
 *
 * @author Greg Dennis
 */

open util/integer
open util/ordering[SeqIdx] as ord

sig SeqIdx {}

/** sequence covers a prefix of SeqIdx */
pred isSeq[s: SeqIdx -> elem] {
  s in SeqIdx -> lone elem
  s.inds - ord/next[s.inds] in ord/first
}

/** returns all the elements in this sequence */
fun elems [s: SeqIdx -> elem]: set elem { SeqIdx.s }

/** returns the first element in the sequence */
fun first [s: SeqIdx -> elem]: lone elem { s[ord/first] }

/** returns the last element in the sequence */
fun last [s: SeqIdx -> elem]: lone elem { s[lastIdx[s]] }

/** returns the cdr of the sequence */
fun rest [s: SeqIdx -> elem] : SeqIdx -> elem {
  (ord/next).s
}

/** returns all but the last element of the sequence */
fun butlast [s: SeqIdx -> elem] : SeqIdx -> elem {
  (SeqIdx - lastIdx[s]) <: s
}

/** true if the sequence is empty */
pred isEmpty [s: SeqIdx -> elem] { no s }

/** true if this sequence has duplicates */
pred hasDups [s: SeqIdx -> elem] { # elems[s] < # inds[s] }

/** returns all the indices occupied by this sequence */
fun inds [s: SeqIdx -> elem]: set SeqIdx { s.elem }

/** returns last index occupied by this sequence */
fun lastIdx [s: SeqIdx -> elem]: lone SeqIdx { ord/max[inds[s]] }

/**
 * returns the index after the last index
 * if this sequence is empty, returns the first index,
 * if this sequence is full, returns empty set
 */
fun afterLastIdx [s: SeqIdx -> elem] : lone SeqIdx {
  ord/min[SeqIdx - inds[s]]
}

/** returns first index at which given element appears or the empty set if it doesn't */
fun idxOf [s: SeqIdx -> elem, e: elem] : lone SeqIdx { ord/min[indsOf[s, e]] }

/** returns last index at which given element appears or the empty set if it doesn't */
fun lastIdxOf [s: SeqIdx -> elem, e: elem] : lone SeqIdx { ord/max[indsOf[s, e]] }

/** returns set of indices at which given element appears or the empty set if it doesn't */
fun indsOf [s: SeqIdx -> elem, e: elem] : set SeqIdx { s.e }

/**
 * return the result of appending e to the end of s
 * just returns s if s exhausted SeqIdx
 */
fun add [s: SeqIdx -> elem, e: elem] : SeqIdx -> elem {
  setAt[s, afterLastIdx[s], e]
}

/** returns the result of setting the value at index i in sequence to e */
fun setAt [s: SeqIdx -> elem, i: SeqIdx, e: elem] : SeqIdx -> elem {
  s ++ i -> e
}

/** returns the result of inserting value e at index i */
fun insert [s: SeqIdx -> elem, i: SeqIdx, e: elem] : SeqIdx -> elem {
  (ord/prevs[i] <: s) + (i->e) + (~(ord/next)).((ord/nexts[i] + i) <: s)
}

/** returns the result of deleting the value at index i */
fun delete[s: SeqIdx -> elem, i: SeqIdx] : SeqIdx -> elem {
  (ord/prevs[i] <: s) + (ord/next).(ord/nexts[i] <: s)
}

/** appended is the result of appending s2 to s1 */
fun append [s1, s2: SeqIdx -> elem] : SeqIdx -> elem {
  let shift = {i", i: SeqIdx | #ord/prevs[i"] = add[#ord/prevs[i], add[#ord/prevs[lastIdx[s1]], 1]] } |
    s1 + shift.s2
}

/** returns the subsequence of s between from and to, inclusive */
fun subseq [s: SeqIdx -> elem, from, to: SeqIdx] : SeqIdx -> elem {
  let shift = {i", i: SeqIdx | #ord/prevs[i"] = sub[#ord/prevs[i], #ord/prevs[from]] } |
    shift.((SeqIdx - ord/nexts[to]) <: s)
}

fun firstIdx: SeqIdx { ord/first }

fun finalIdx: SeqIdx { ord/last }
// Model: utilities/types/sequence.als
module util/sequence[elem]

/*
 * Creates sequences (or lists) of elements. The ordered signature SeqIdx
 * represents the indexes at which elements can be located, and a sequence
 * is modeled as a mapping from indexes to elements. Empty sequences are
 * allowed, and a sequence may have a single element appear multiple times.
 * Maximum length of a sequence is determined by the scope of SeqIdx.
 *
 * Sequences always cover an initial segment of SeqIdx. That is, every
 * sequence (except the empty sequence) begins at the first SeqIdx and does
 * not have gaps in indexes that it covers. In other words, if a sequence has
 * its last element at index i, then the sequence has elements at all the
 * indexes that precede i.
 *
 * Oftentimes, a model will need to require that all sequences that could
 * exist, do exist. Calling the allExist predicate will ensure that that there is
 * a Seq atom for each possible sequences of elements with length less than
 * or equal to the scope of SeqIdx.
 *
 * The functions and predicates at the bottom of this module provide all
 * functionality of util/ordering on SeqIdx.
 *
 * revisions: Greg Dennis
 */

open util/ordering[SeqIdx] as ord

sig SeqIdx {}

sig Seq {
   seqElems: SeqIdx -> lone elem
}
{
  // Ensure that elems covers only an initial segment of SeqIdx,
  // equal to the length of the signature
  all i: SeqIdx - ord/first | some i.seqElems => some ord/prev[i].seqElems
}

/** no two sequences are identical */
fact canonicalizeSeqs {
  no s1, s2: Seq | s1!=s2 && s1.seqElems=s2.seqElems
}

/** invoke if you want none of the sequences to have duplicates */
pred noDuplicates {
  all s: Seq | !s.hasDups
}

/** invoke if you want all sequences within scope to exist */
pred allExist {
  (some s: Seq | s.isEmpty) &&
  (all s: Seq | SeqIdx !in s.inds => (all e: elem | some s": Seq | s.add[e, s"]))
}

/** invoke if you want all sequences within scope with no duplicates */
pred allExistNoDuplicates {
  some s: Seq | s.isEmpty
  all s: Seq {
    !s.hasDups
    SeqIdx !in s.inds => (all e: elem - s.elems | some s": Seq | s.add[e, s"])
  }
}

/** returns element at the given index */
fun at [s: Seq, i: SeqIdx]: lone elem { i.(s.seqElems) }

/** returns all the elements in this sequence */
fun elems [s: Seq]: set elem { SeqIdx.(s.seqElems) }

/** returns the first element in the sequence */
fun first [s:Seq]: lone elem { s.at[ord/first] }

/** returns the last element in the sequence */
fun last [s:Seq]: lone elem { s.at[s.lastIdx] }

/**
 * true if the argument is the "cdr" of this sequence
 * false if this sequence is empty
 */
pred rest [s, r: Seq] {
   !s.isEmpty
   all i: SeqIdx | r.at[i] = s.at[ord/next[i]]
}

/** true if the sequence is empty */
pred isEmpty [s:Seq] { no s.elems }

/** true if this sequence has duplicates */
pred hasDups [s:Seq] { # elems[s] < # inds[s] }

/** returns all the indices occupied by this sequence */
fun inds [s:Seq] : set SeqIdx { elem.~(s.seqElems) }

/** returns last index occupied by this sequence */
fun lastIdx [s:Seq] : lone SeqIdx { ord/max[s.inds] }

/**
 * returns the index after the last index
 * if this sequence is empty, returns the first index,
 * if this sequence is full, returns empty set
 */
fun afterLastIdx [s:Seq] : lone SeqIdx {
  ord/min[SeqIdx - s.inds]
}

/** returns first index at which given element appears or the empty set if it doesn't */
fun idxOf [s: Seq, e: elem] : lone SeqIdx { ord/min[s.indsOf[e]] }

/** returns last index at which given element appears or the empty set if it doesn't */
fun lastIdxOf [s: Seq, e: elem] : lone SeqIdx { ord/max[s.indsOf[e]] }

/** returns set of indices at which given element appears or the empty set if it doesn't */
fun indsOf [s: Seq, e: elem] : set SeqIdx { (s.seqElems).e }

/** true if this starts with prefix */
pred startsWith [s, prefix: Seq] {
  all i: prefix.inds | s.at[i] = prefix.at[i]
}

/** added is the result of appending e to the end of s */
pred add [s: Seq, e: elem, added: Seq] {
  added.startsWith[s]
  added.seqElems[s.afterLastIdx] = e
  #added.inds = #s.inds.add[1]
}

/** setted is the result of setting value at index i to e */
pred setAt [s: Seq, idx: SeqIdx, e: elem, setted: Seq] {
  setted.seqElems = s.seqElems ++ idx->e
}

/** inserts is the result of inserting value e at index i */
pred insert [s: Seq, idx: SeqIdx, e: elem, inserted: Seq] {
  inserted.at[idx] = e
  all i: ord/prevs[idx] | inserted.at[i] = s.at[i]
  all i: ord/nexts[idx] | inserted.at[i] = s.at[ord/prev[i]]
  #inserted.inds = #s.inds.add[1]
}

/** copies source into dest starting at destStart */
pred copy [source, dest: Seq, destStart: SeqIdx] {
  all sourceIdx : source.inds | some destIdx: SeqIdx {
    ord/gte[destIdx, destStart]
    dest.at[destIdx] = source.at[sourceIdx]
    #ord/prevs[sourceIdx] = #(ord/prevs[destIdx] - ord/prevs[destStart])
  }
}

/** appended is the result of appending s2 to s1 */
pred append [s1, s2, appended: Seq] {
  appended.startsWith[s1]
  copy[s2, appended, s1.afterLastIdx]
  #appended.inds = #s1.inds.add[#s2.inds]
}

/** sub is the subsequence of s between from and to, inclusive */
pred subseq [s, sub: Seq, from, to: SeqIdx] {
  ord/lte[from, to]
  copy[sub, s, from]
  #sub.inds = #(to + ord/prevs[to] - ord/prevs[from])
}

fun firstIdx: SeqIdx { ord/first }

fun finalIdx: SeqIdx { ord/last }

// Model: utilities/types/sequniv.als
module util/sequniv

open util/integer as ui

/*
 * NOTE: Do not include this module manually.
 * Instead, use the "seq" keyword which will automatically
 * import this module with the correct additional constraints as needed.
 */

/*
 * A sequence utility for modeling sequences as just a
 * relation as opposed to reifying them into sequence
 * atoms like the util/sequence module does.
 *
 * Precondition: each input sequence must range over a prefix
 * of seq/Int.
 *
 * Postcondition: we guarantee the returned sequence
 * also ranges over a prefix of seq/Int.
 *
 * @author Greg Dennis
 */

/** sequence covers a prefix of seq/Int */
pred isSeq[s: Int -> univ] {
  s in seq/Int -> lone univ
  s.inds - ui/next[s.inds] in 0
}

/** returns all the elements in this sequence */
fun elems [s: Int -> univ]: set (Int.s) { seq/Int . s }

/**
 * returns the first element in the sequence
 * (Returns the empty set if the sequence is empty)
 */
fun first [s: Int -> univ]: lone (Int.s) { s[0] }

/**
 * returns the last element in the sequence
 * (Returns the empty set if the sequence is empty)
 */
fun last [s: Int -> univ]: lone (Int.s) { s[lastIdx[s]] }

/**
 * returns the cdr of the sequence
 * (Returns the empty sequence if the sequence has 1 or fewer element)
 */
fun rest [s: Int -> univ] : s { seq/Int <: ((ui/next).s) }

/** returns all but the last element of the sequence */
fun butlast [s: Int -> univ] : s {
  (seq/Int - lastIdx[s]) <: s
}

/** true if the sequence is empty */
pred isEmpty [s: Int -> univ] { no s }

/** true if this sequence has duplicates */
pred hasDups [s: Int -> univ] { # elems[s] < # inds[s] }

/** returns all the indices occupied by this sequence */
fun inds [s: Int -> univ]: set Int { s.univ }

/**
 * returns last index occupied by this sequence
 * (Returns the empty set if the sequence is empty)
 */
fun lastIdx [s: Int -> univ]: lone Int { ui/max[inds[s]] }

/**
 * returns the index after the last index
 * if this sequence is empty, returns 0
 * if this sequence is full, returns empty set
 */
fun afterLastIdx [s: Int -> univ] : lone Int { ui/min[seq/Int - inds[s]] }

/** returns first index at which given element appears or the empty set if it doesn't */
fun idxOf [s: Int -> univ, e: univ] : lone Int { ui/min[indsOf[s, e]] }

/** returns last index at which given element appears or the empty set if it doesn't */
fun lastIdxOf [s: Int -> univ, e: univ] : lone Int { ui/max[indsOf[s, e]] }

/** returns set of indices at which given element appears or the empty set if it doesn't */
fun indsOf [s: Int -> univ, e: univ] : set Int { s.e }

/**
 * return the result of appending e to the end of s
 * (returns s if s exhausted seq/Int)
 */
fun add [s: Int -> univ, e: univ] : s + (seq/Int->e) {
  setAt[s, afterLastIdx[s], e]
}

/**
 * returns the result of setting the value at index i in sequence to e
 * Precondition: 0 <= i < #s
 */
fun setAt [s: Int -> univ, i: Int, e: univ] : s + (seq/Int->e) {
  s ++ i -> e
}

/**
 * returns the result of inserting value e at index i
 * (if sequence was full, the original last element will be removed first)
 * Precondition: 0 <= i <= #s
 */
fun insert [s: Int -> univ, i: Int, e: univ] : s + (seq/Int->e) {
  seq/Int <: ((ui/prevs[i] <: s) + (i->e) + ui/prev.((ui/nexts[i] + i) <: s))
}

/**
 * returns the result of deleting the value at index i
 * Precondition: 0 <= i < #s
 */
fun delete[s: Int -> univ, i: Int] : s {
  (ui/prevs[i] <: s) + (ui/next).(ui/nexts[i] <: s)
}

/**
 * appended is the result of appending s2 to s1
 * (If the resulting sequence is too long, it will be truncated)
 */
fun append [s1, s2: Int -> univ] : s1+s2 {
  let shift = {i", i: seq/Int | int[i"] = ui/add[int[i], ui/add[int[lastIdx[s1]], 1]] } |
    no s1 => s2 else (s1 + shift.s2)
}

/**
 * returns the subsequence of s between from and to, inclusive
 * Precondition: 0 <= from <= to < #s
 */
fun subseq [s: Int -> univ, from, to: Int] : s {
  let shift = {i", i: seq/Int | int[i"] = ui/sub[int[i], int[from]] } |
    shift.((seq/Int - ui/nexts[to]) <: s)
}

// Model: utilities/types/ternary.als
module util/ternary

/*
 * Utilities for some common operations and constraints
 * on ternary relations. The keyword 'univ' represents the
 * top-level type, which all other types implicitly extend.
 * Therefore, all the functions and predicates in this model
 * may be applied to ternary relations of any type.
 *
 * author: Greg Dennis
 */

/** returns the domain of a ternary relation */
fun dom [r: univ->univ->univ] : set ((r.univ).univ) { (r.univ).univ }

/** returns the range of a ternary relation */
fun ran [r: univ->univ->univ] : set (univ.(univ.r)) { univ.(univ.r) }

/** returns the "middle range" of a ternary relation */
fun mid [r: univ->univ->univ] : set (univ.(r.univ)) { univ.(r.univ) }

/** returns the first two columns of a ternary relation */
fun select12 [r: univ->univ->univ] : r.univ {
  r.univ
}

/** returns the first and last columns of a ternary relation */
fun select13 [r: univ->univ->univ] : ((r.univ).univ) -> (univ.(univ.r)) {
  {x: (r.univ).univ, z: univ.(univ.r) | some (x.r).z}
}

/** returns the last two columns of a ternary relation */
fun select23 [r: univ->univ->univ] : univ.r {
  univ.r
}

/** flips the first two columns of a ternary relation */
fun flip12 [r: univ->univ->univ] : (univ.(r.univ))->((r.univ).univ)->(univ.(univ.r)) {
  {x: univ.(r.univ), y: (r.univ).univ, z: univ.(univ.r) | y->x->z in r}
}

/** flips the first and last columns of a ternary relation */
fun flip13 [r: univ->univ->univ] : (univ.(univ.r))->(univ.(r.univ))->((r.univ).univ) {
  {x: univ.(univ.r), y: univ.(r.univ), z: (r.univ).univ | z->y->x in r}
}

/** flips the last two columns of a ternary relation */
fun flip23 [r: univ->univ->univ] : ((r.univ).univ)->(univ.(univ.r))->(univ.(r.univ)) {
  {x: (r.univ).univ, y: univ.(univ.r), z: univ.(r.univ) | x->z->y in r}
}

// Model: utilities/types/time.als
open util/ordering[Time]

sig Time { }

let dynamic[x] = x one-> Time

let dynamicSet[x] = x -> Time

let then [a, b, t, t"] {
    some x:Time | a[t,x] && b[x,t"]
}

let while = while3

let while9 [cond, body, t, t"] {
    some x:Time | (cond[t] => body[t,x] else t=x) && while8[cond,body,x,t"]
}

let while8 [cond, body, t, t"] {
    some x:Time | (cond[t] => body[t,x] else t=x) && while7[cond,body,x,t"]
}

let while7 [cond, body, t, t"] {
    some x:Time | (cond[t] => body[t,x] else t=x) && while6[cond,body,x,t"]
}

let while6 [cond, body, t, t"] {
    some x:Time | (cond[t] => body[t,x] else t=x) && while5[cond,body,x,t"]
}

let while5 [cond, body, t, t"] {
    some x:Time | (cond[t] => body[t,x] else t=x) && while4[cond,body,x,t"]
}

let while4 [cond, body, t, t"] {
    some x:Time | (cond[t] => body[t,x] else t=x) && while3[cond,body,x,t"]
}

let while3 [cond, body, t, t"] {
    some x:Time | (cond[t] => body[t,x] else t=x) && while2[cond,body,x,t"]
}

let while2 [cond, body, t, t"] {
    some x:Time | (cond[t] => body[t,x] else t=x) && while1[cond,body,x,t"]
}

let while1 [cond, body, t, t"] {
    some x:Time | (cond[t] => body[t,x] else t=x) && while0[cond,body,x,t"]
}

let while0 [cond, body, t, t"] {
    !cond[t] && t=t"
}

// Model: utilities/trace/trace.als
module trace[exactly elem]

private one sig Ord {
   First: set elem,
   Next: elem -> elem
} {
   pred/totalOrder[elem,First,Next]
}

lone sig back in elem {}

fun loop : elem -> elem {
	last -> back
}

fun first: one elem { Ord.First }

fun last: one elem { elem - ((Ord.Next).elem) }

fun next : elem->elem { Ord.Next + loop }

fun prev : elem->elem { ~this/next }

fun past : elem->elem { ^(~this/next) }

fun future : elem -> elem { elem <: *this/next }

fun upto[s,s" : elem] : set elem {
	(s" in s.*(Ord.Next) or finite) implies s.future & ^(Ord.Next).s" else s.*(Ord.Next) + (^(Ord.Next).s" & back.*(Ord.Next))
}


pred finite {
	no loop
}

pred infinite {
	some loop
}

check total {
	finite implies pred/totalOrder[elem,first,next]
}

// Model: utilities/time/overlapping-ranges.als
        open util/ordering[Time]

	sig Time {}


	let range[s,e] 			= (s + s.nexts) - e.nexts // inclusive bounds i.e. [s,e]
	let overlap[s1,e1,s2,e2] 	= some (range[s1,e1] & range[s2,e2])

	check {


		// [t0,t0] ∩ [t0,tn]
		overlap[ first, first, first, last ] 

		// [t0,t1] ∩ [t1,tn]
		overlap[ first, first.next, first.next, last ]

		// [t0,t1] ∩ [t0,tn]
		overlap[ first, first.next, first, last ]

		// [t0,t1] ∩ [t0,t1]
		overlap[ first, first.next, first, first.next ]	

		// not ( [t1,t0] ∩ [t0,t1] )
		not overlap[ first.next, first, first, last ]

		// not ( [t0,t1] ∩ [t2,tn] )
		not overlap[ first, first.next, first.next.next, last ]	

		// reflexive
		all t1, t2, t3,  t4 : Time | overlap[t1,t2,t3,t4] <=> overlap[t3,t4,t1,t2]
	} for 10

// Model: utilities/messaging/messaging.als
module examples/algorithms/messaging

/*
 * Generic messaging among several nodes
 *
 * By default, messages can be lost (i.e. never become visible to the
 * recipient node) or may be arbitrarily delayed.  Also, by default
 * out-of-order delivery is allowed.
 */

open util/ordering[Tick] as ord
open util/relation as rel

sig Node {}

sig MsgState {
   /** Node that sent the message */
   from: Node,

   /** Intended recipient(s) of a message; note that broadcasts are allowed */
   to: set Node
}

sig Msg {
   state: MsgState,

   /** Timestamp: the tick on which the message was sent */
   sentOn: Tick,

   /** tick at which node reads message, if read */
   readOn: Node -> lone Tick
}{
  readOn.Tick in state.to
}

sig Tick {
   /** The state of each node */
   state: Node -> one NodeState,

   /**
    * Definition of what each node does on this tick:
    *
    * Typically, a node would determine
    * the messages it sends and its next state, based on its current
    * state and the messages it reads.
    *
    * Messages that the node _can_ read in this tick, i.e. messages available
    * for reading at the beginning of this tick.  The messages that
    * the node actually reads are a subset of this set.  Determined by
    * constraints in this module.
    */
   visible: Node -> Msg,

   /**
    * Messages that the node _actually reads_ in this tick.  Must be a subset
    * of visible.  Determined by constraints of the particular system
    * that uses this module.
    */
   read: Node -> Msg,

   /**
    * Messages sent by the node in this tick.  They become visible to
    * (and can be read by) their recipients on the next tick.
    */
   sent: Node -> Msg,

   /**
    * Messages available for sending at this tick.  A given message
    * atom is only used once, and then it gets removed from the available
    * set and cannot be used to represent messages sent on subsequent ticks.
    * Also, two different nodes cannot send the same message atom.
    * So, a message atom represents a particular single physical message
    * sent by a given node on a given tick.
    */
   available: set Msg,

   /**
    * For each node, at each tick, the number of messages it _needs_ to send.
    * Used to rule out "proofs" of liveness violations that are caused
    * solely by not having enough messages available for sending.
    */
   needsToSend: Node -> Msg
}

fun MsgsSentOnTick[t: Tick]: set Msg { t.sent[Node] }
fun MsgsVisibleOnTick[t: Tick]: set Msg { t.visible[Node] }
fun MsgsReadOnTick[t: Tick]: set Msg { t.read[Node] }

fact MsgMovementConstraints {
   // At the beginning, no messages have been sent yet
   no ord/first.visible[Node]

   // Messages sent on a given tick become visible to recipient(s)
   // on the subsequent tick.
   all pre: Tick - ord/last |
     let post = ord/next[pre] | {
        // messages sent on this tick are no longer available on subsequent tick
        post.available = pre.available - MsgsSentOnTick[pre]
     }

   all t: Tick | {
      // Messages sent on a tick are taken from the pool of available
      // (not-yet-sent) message atoms
      MsgsSentOnTick[t] in t.available

      // Timestamps are correct
      MsgsSentOnTick[t].sentOn in t
      MsgsReadOnTick[t].readOn[Node] in t

      // The only new message atoms are those sent by nodes
      MsgsSentOnTick[t] = t.sent[Node]

      all n: Node, m: Msg |
           m.readOn[n] = t => m in t.read[n]
      // Return addresses are correct
      all n: Node | t.sent[n].state.from in n

      // messages sent to a node on a tick become visible to that node on some subsequent tick,
      // and permanently stop being visible to that node on the tick after that node reads the message
      all n: Node, m: Msg | {
          // message starts being visible to node n no earlier than it is sent;
          // only messages sent to this node are visible to this node.
          (m in t.visible[n] => (n in m.state.to && m.sentOn in ord/prevs[t]))
          // message permanently stops being visible immediately after being read
          (m in t.read[n] => m !in ord/nexts[t].visible[n])
      }
   }
}

sig NodeState {
}

fun MsgsLiveOnTick[t: Tick]: set Msg {
  Msg - { future: Msg | future.sentOn in ord/nexts[t] }
           - { past: Msg | all n: past.state.to | past.readOn[n] in ord/prevs[t] }
}

pred TicksEquivalent[t1, t2: Tick] {
   t1.state = t2.state
   some r: (MsgsLiveOnTick[t1] - MsgsVisibleOnTick[t1]) one -> one (MsgsLiveOnTick[t2] - MsgsVisibleOnTick[t2])  |
       all m1: dom[r] | let m2 = m1.r | {
         m1.(Msg<:state) = m2.state
       }
   some r: MsgsVisibleOnTick[t1]  one -> one MsgsVisibleOnTick[t2]  |
       all m1: dom[r] | let m2 = m1.r | {
         m1.(Msg<:state) = m2.state
       }
}

pred Loop {
  some t: Tick - ord/last | TicksEquivalent[t, ord/last]
}

fact CleanupViz {
    // cleans up visualization without precluding any interesting traces

    // all messages must be sent
    Msg in Tick.sent[Node]
}

pred ReadInOrder  {
    //
    // This function ensures that messages are read in order.
    //

    // for all pairs of nodes
    all n1, n2: Node |
        // for all pairs of messages sent from n1 to n2
        all m1, m2: Msg |
            {
              m1.state.from = n1
              m2.state.from = n1
              m1.state.to = n2
              m2.state.to = n2
           } => {
            // if both m1 and m2 are read by n2, *and*
            // n2 reads m1 before m2, then m1 must have
            // been sent before m2
            (some m1.readOn[n2] && some m2.readOn[n2] &&
             m1.readOn[n2] in ord/prevs[m2.readOn[n2]]) =>
                ord/lte[m1.sentOn, m2.sentOn]
           }
}

fact ReadOnlyVisible { read in visible }

/**
 * this function ensures that messages will not
 * be lost, i.e. a message send to a node will
 * eventually be visible to that node
 */
pred NoLostMessages {
  all m: Msg |
    (m.sentOn != ord/last) => (all n: m.state.to |
      some t: ord/nexts[m.sentOn] |
        m in t.visible[n])
}

/**
 * this function ensures that there will be
 * no shortage of messages in the available
 * message pool during the trace
 */
pred NoMessageShortage {
  all t: Tick - ord/last |
    (sum n: Node | # t.needsToSend[n]) =< # t.available
}

pred SomeState  {
   # Node > 1
   //# Tick$read > 1
}

pred OutOfOrder  {
   ! ReadInOrder
   # Msg = 2
}

run SomeState for 2 expect 1
run OutOfOrder for 4 expect 1



// DEFINED VARIABLES
// Defined variables are uncalled, no-argument functions.
// They are helpful for getting good visualization.
fun FROM: Msg -> Node {{m: Msg, n: Node | n in m.state.from}}
fun TO: Msg -> Node {{m: Msg, n: Node | n in m.state.to}}

// Model: puzzles/money.als
/*
 * Famous puzzle "SEND + MORE = MONEY"
 * Substitute each letter in the equation with a single integer 0-9
 * (no duplicates) such that the addition is correct.
 *
 */

// Non-negative numbers
abstract sig Num { val: Int } { val >= 0 && val <= 9 }

// Digits
one sig S, E, N, D, M, O, R, Y extends Num { }

// Digits must all be different and in 0..9
fact {
  all m, n : Num | m !=n => n.val != m.val
}

// Function for computing the sum and the carry at the same time
fun sumCarry(a: Num, b: Num): (Int -> Int) {
  let s = a.val + b.val |
    s -> (s > 9 => 1 else 0)
}

fun fst(t: (Int -> Int)): Int {
  t.univ
}

fun snd(t: (Int -> Int)): Int {
  univ.t
}

fun val(a: (Int -> Int), b: (Int -> Int)): Int {
  rem[plus[fst[a], snd[b]], 10]
}

// Constraints for SEND + MORE = MONEY
fact {
  M.val > 0
  S.val > 0
  let YSumCarry = sumCarry[D, E], 
    ESumCarry = sumCarry[N, R],
    NSumCarry = sumCarry[E, O],
    OSumCarry = sumCarry[S, M] |
    Y.val = rem[fst[YSumCarry], 10] &&
    E.val = val[ESumCarry, YSumCarry] &&
    N.val = val[NSumCarry, ESumCarry] &&
    O.val = val[OSumCarry, NSumCarry] &&
    M.val = snd[OSumCarry]
}

run { } for 5 Int

// Model: puzzles/prisoner-room-visit/prisoner.als

open util/ordering[State]
open util/integer

/*Define Players*/
abstract sig Prisoner {}
sig OtherPrisoner extends Prisoner{}
one sig CounterPrisoner extends Prisoner {}
one sig NULL{}

fact { Prisoner = OtherPrisoner 
  + CounterPrisoner }
fact { #Prisoner > 1 }

/*Define Boolean*/
abstract sig Bool{}
one sig True extends Bool {}
one sig False extends Bool {}

/*Define Switches*/
abstract sig Switches{}
one sig SwitcheA extends Switches{}
one sig SwitcheB extends Switches{}
fact { Switches = SwitcheA + SwitcheB }

/*Define Status*/
abstract sig Status{}
one sig Up extends Status {}
one sig Down extends Status {}

/*Define State*/
sig State {announced:Bool,
	       SwitchesStatus: Switches->one Status,
	       count:Int,
	       timesSwitched: OtherPrisoner ->one  Int,
	       currentPrisoner: one (Prisoner+NULL)
}

/*Define initial state*/
pred TineSwichedSetToZero{all p:OtherPrisoner{ p->0 in first.timesSwitched}}
pred CountSetToZero{first.count=0}
pred SwitchesInBoolean{all s:Switches{ (s->Down in first.SwitchesStatus) or (s->Up in first.SwitchesStatus)}}
pred AnnouncedSetToFalse{ first.announced = False}
pred CurrentPlayerSetToNull {first.currentPrisoner = NULL}

fact Init{TineSwichedSetToZero and CountSetToZero and SwitchesInBoolean and AnnouncedSetToFalse and CurrentPlayerSetToNull}

pred NonCounterStep[game, game": State,p:Prisoner]{
	p in OtherPrisoner
	game".currentPrisoner = p
	game".announced = game.announced
	game".count = game.count
	(game.announced= True =>
		game".SwitchesStatus = game.SwitchesStatus
		and game".timesSwitched = game.timesSwitched
	else
		((game.SwitchesStatus[SwitcheA] = Down and p.(game.timesSwitched) <2) =>
			SwitcheA.(game".SwitchesStatus) = Up
			and SwitcheB.(game".SwitchesStatus) = SwitcheB.(game.SwitchesStatus)
			and game".timesSwitched = game.timesSwitched - p->p.(game.timesSwitched) + p->(p.(game.timesSwitched)+1)
		else
			game".timesSwitched = game.timesSwitched
			and SwitcheA.(game".SwitchesStatus) = SwitcheA.(game.SwitchesStatus)
			and (SwitcheB.(game.SwitchesStatus) = Up=>
				SwitcheB.(game".SwitchesStatus) = Down
			else
				SwitcheB.(game".SwitchesStatus) = Up)))
}

pred CounterStep[game, game": State, p:Prisoner]{
	p = CounterPrisoner
	game".currentPrisoner = p
	game".timesSwitched = game.timesSwitched
	(game.announced= True =>
		game".SwitchesStatus = game.SwitchesStatus
		and game".announced = game.announced
		and game".count =game.count
	else
		(SwitcheA.(game.SwitchesStatus) = Up =>
			SwitcheA.(game".SwitchesStatus) = Down
			and SwitcheB.(game".SwitchesStatus) = SwitcheB.(game.SwitchesStatus)
			and game".count =game.count +1
			and (game".count = 2.mul[(#Prisoner-1)] =>
				game".announced = True
			else
				game".announced = game.announced)
		else
			game".count = game.count
			and game".announced = game.announced
			and SwitcheA.(game".SwitchesStatus) = SwitcheA.(game.SwitchesStatus)
			and (SwitcheB.(game.SwitchesStatus) = Up=>
				SwitcheB.(game".SwitchesStatus) = Down
			else
				SwitcheB.(game".SwitchesStatus) = Up)))
}

fact Steps{
		all s: State, s": s.next {
			(one p:OtherPrisoner | NonCounterStep[s, s",p])
			 or (one p:CounterPrisoner | CounterStep[s, s",p])
		}
}

/*Checking types*/
assert  TypeOK {all s:State{
			s.count >=0
			and s.count<= 2.mul[(#Prisoner-1)]
			and  (all p:OtherPrisoner| p.(s.timesSwitched) <=2)
	}
}
check TypeOK for 3 Prisoner, 12 State

/*Checking safety*/
pred StateDone[s:State]{s.count =  2.mul[(#Prisoner-1)]}
pred Announced[s:State]{s.announced = True}

  /*(*************************************************************************)
  (* This formula asserts that safety condition: that Done true implies    *)
  (* that every prisoner other than the counter has flipped switch A at    *)
  (* least once--and hence has been in the room at least once.  Since the  *)
  (* counter increments the count only when in the room, and Done implies  *)
  (* count > 0, it also implies that the counter has been in the room.*)
  (*This is also checks the counter's announcement that all the prisoners was in the room if and only if it is true (means Done)  *)
  (*************************************************************************)*/
assert Safety{all s:State{
			(StateDone[s] =>
				(all p:OtherPrisoner| p.(s.timesSwitched)>0))
			and  (Announced[s] iff StateDone[s])
	}
}
check Safety for 3 Prisoner, 10 State

/* Count always eaqual to the sum of timesSwitched of all OtherPrisoners(+-1)*/
assert CountInvariant{all s:State {
				(let totalSwitched = (sum p:OtherPrisoner | p.(s.timesSwitched)) |
				(SwitcheA.(s.SwitchesStatus) = Up => 
					((s.count = totalSwitched -1) or (s.count = totalSwitched))
				else
					((s.count = totalSwitched) or (s.count = totalSwitched +1))))
	}
}

check CountInvariant for 3 Prisoner, 10 State


/*Checking fairness*/
pred AfterNonCounterPlayerEventaullyCounterPlayertEnterTheRoom{
		all s: State|
			((s.currentPrisoner in OtherPrisoner) => 
				(some s": s.^next | s".currentPrisoner = CounterPrisoner))
}

pred PrisonerComesImmediatelyAfterCounter[s: State, p:OtherPrisoner]{ 
			s.currentPrisoner = CounterPrisoner and s.next.currentPrisoner = p
}

pred Fairness {(all p:OtherPrisoner{ 
			some s,s":State {s" in s.^next
					and PrisonerComesImmediatelyAfterCounter[s,p] 
					and PrisonerComesImmediatelyAfterCounter[s",p]
			}
		})
		AfterNonCounterPlayerEventaullyCounterPlayertEnterTheRoom
}

pred Done{some s:State | Announced[s]}

assert Theorem{Fairness => Done}
check Theorem for 3 Prisoner, 12 State

run {} for 4 int, exactly 3 Prisoner, 12 State

// Model: puzzles/halmos-handshake/handshake.als
/*
 * Alloy model of the Halmos handshake problem
 *
 * Hilary and Jocelyn are married. They invite four couples who are friends for dinner. When
 * they arrive, they shake hands with each other. Nobody shakes hands with him or herself
 * or with his or her spouse. After there has been some handshaking, Jocelyn jumps up on
 * a chair and says "Stop shaking hands!", and then asks how many hands each person has
 * shaken. All the answers are different. How many hands has Hilary shaken?
 *
 * The Alloy model represents the problem as a set of constraints. Properties of the spouse
 * relationship and of handshaking in general are given as facts. The particular situation
 * is cast as a function.
 *
 * There are 9 people answering, and all answers are different. Nobody can shake more than
 * 8 hands. So answers must be 0..8. The one (p8 say) who answered 8 has shaken everybody's
 * hand except for his or her own, and his or her spouse's. Now consider the person who shook
 * 0 hands (p0 say). The persons p0 and p8 are distinct. If they are not married, then p8 cannot
 * have shaken 8 hands, because he or she did not shake the hand of p0 or of his or her spouse.
 * So p8's spouse to p0. Now imagine Jocelyn asking the question again, with p0 and p8 out of
 * the room, and excluding hand shakes with them. Since p8 shook hands with everyone else
 * except p0 and p8, everyone gives an answer one smaller than they did before, giving 0..6.
 * The argument now applies recursively. So Hilary is left alone, having shaken 4 hands.
 *
 * author: Daniel Jackson, 11/15/01
 */

sig Person {spouse: Person, shaken: set Person}
one sig Jocelyn, Hilary extends Person {}

fact ShakingProtocol {
    // nobody shakes own or spouse's hand
    all p: Person | no (p + p.spouse) & p.shaken
    // if p shakes q, q shakes p
    all p, q: Person | p in q.shaken => q in p.shaken
    }

fact Spouses {
    all p, q: Person | p!=q => {
        // if q is p's spouse, p is q's spouse
        p.spouse = q => q.spouse = p
        // no spouse sharing
        p.spouse != q.spouse
        }
    all p: Person {
        // a person is his or her spouse's spouse
        p.spouse.spouse = p
        // nobody is his or her own spouse
        p != p.spouse
        }
    }

pred Puzzle {
    // everyone but Jocelyn has shaken a different number of hands
    all p,q: Person - Jocelyn | p!=q => #p.shaken != #q.shaken
    // Hilary's spouse is Jocelyn
    Hilary.spouse = Jocelyn
    }

P10: run Puzzle for exactly 10 Person, 5 int expect 1
P12: run Puzzle for exactly 12 Person, 5 int expect 1
P14: run Puzzle for exactly 14 Person, 5 int expect 1
P16: run Puzzle for exactly 16 Person, 6 int expect 1

// Model: puzzles/farmer-chicken-fox/farmer.als

/*
 * The classic river crossing puzzle. A farmer is carrying a fox, a
 * chicken, and a sack of grain. He must cross a river using a boat
 * that can only hold the farmer and at most one other thing. If the
 * farmer leaves the fox alone with the chicken, the fox will eat the
 * chicken; and if he leaves the chicken alone with the grain, the
 * chicken will eat the grain. How can the farmer bring everything
 * to the far side of the river intact?
 *
 * authors: Greg Dennis, Rob Seater
 *
 * Acknowledgements to Derek Rayside and his students for finding and
 * fixing a bug in the "crossRiver" predicate.
 */

open util/ordering[State] as ord

/**
 * The farmer and all his possessions will be represented as Objects.
 * Some objects eat other objects when the Farmer's not around.
 */
abstract sig Object { eats: set Object }
one sig Farmer, Fox, Chicken, Grain extends Object {}

/**
 * Define what eats what when the Farmer' not around.
 * Fox eats the chicken and the chicken eats the grain.
 */
fact eating { eats = Fox->Chicken + Chicken->Grain }

/**
 * The near and far relations contain the objects held on each
 * side of the river in a given state, respectively.
 */
sig State {
   near: set Object,
   far: set Object
}

/**
 * In the initial state, all objects are on the near side.
 */
fact initialState {
   let s0 = ord/first |
     s0.near = Object && no s0.far
}

/**
 * Constrains at most one item to move from 'from' to 'to'.
 * Also constrains which objects get eaten.
 */
pred crossRiver [from, from", to, to": set Object] {
   // either the Farmer takes no items
   (from" = from - Farmer - from".eats and
    to" = to + Farmer) or
    // or the Farmer takes one item
    (one x : from - Farmer | {
       from" = from - Farmer - x - from".eats
       to" = to + Farmer + x })
}

/**
 * crossRiver transitions between states
 */
fact stateTransition {
  all s: State, s": ord/next[s] {
    Farmer in s.near =>
      crossRiver[s.near, s".near, s.far, s".far] else
      crossRiver[s.far, s".far, s.near, s".near]
  }
}

/**
 * the farmer moves everything to the far side of the river.
 */
pred solvePuzzle {
     ord/last.far = Object
}

run solvePuzzle for 8 State expect 1

/**
 * no Object can be in two places at once
 * this is implied by both definitions of crossRiver
 */
assert NoQuantumObjects {
   no s : State | some x : Object | x in s.near and x in s.far
}

check NoQuantumObjects for 8 State expect 0

// Model: puzzles/einstein/einstein-wikipedia.als

/**
 * See https://en.wikipedia.org/wiki/Zebra_Puzzle
 */
 
open util/ordering[House]


enum Color { yellow, blue, red,   ivory, green}
enum Nationality {Norwegian, Ukrainian, Englishman, Spaniard, Japanese }
enum Drink {water, tea,milk,juice,coffee}
enum Smoke {Kools,Chesterfield,OldGold,LuckyStrike,Parliament}
enum Pet {fox,horse,snails,dog,zebra}

sig House {
    house    : one Color,
    home     : one Nationality,
    drunk    : one Drink,
    smoker   : one Smoke,
    owns     : one Pet
} 


fact disjunct {
	all disj h1, h2 : House | 
		h1.house != h2.house and
		h1.home != h2.home and
		h1.drunk != h2.drunk and
		h1.smoker != h2.smoker and
		h1.owns != h2.owns
}

pred House.nextTo[ other : House ] { 
	other in this.(prev+next) 
}

let centerHouse = first.next.next

fact {


	// There are five houses.

	# House = 5

	// The Englishman lives in the red house.
	Englishman.~home = red.~house

	// The Spaniard owns the dog.
	Spaniard.~home = owns.dog

	// Coffee is drunk in the green house.
	coffee.~drunk = green.~house

	// The Ukrainian drinks tea.
	Ukrainian.~home = drunk.tea

	// The green house is immediately to the right of the ivory house.
	green.~house = ivory.~house.next

	// The Old Gold smoker owns snails.
	OldGold.~smoker = owns.snails

	// Kools are smoked in the yellow house.
	Kools.~smoker = yellow.~house

	// Milk is drunk in the middle house.
	milk.~drunk = centerHouse

	// The Norwegian lives in the first house.
	Norwegian.~home = first

	// The man who smokes Chesterfields lives in the house next to the man with the fox.
	Chesterfield.~smoker.nextTo[ owns.fox ]

	// Kools are smoked in the house next to the house where the horse is kept.
	Kools.~smoker.nextTo[ owns.horse ]

	// The Lucky Strike smoker drinks orange juice.
	LuckyStrike.~smoker = drunk.juice

	// The Japanese smokes Parliaments.
	Japanese.~home = smoker.Parliament

	// The Norwegian lives next to the blue house.
	Norwegian.~home.nextTo[ blue.~house ]
}

run { one drunk.water and one owns.zebra } for 5

	

// Model: puzzles/8-queens/queens.als
// Queens are placed on boards.
some sig Queen { }
// The coordinates on the board.
let positions = { i: Int, j: Int | 0 <= i && i <= 7 && 0 <= j && j <= 7 }
// Each position can have at most one queen occupying it and each queen
// has exactly one position assigned.
one sig Board { queens: positions one -> lone Queen }
// one sig Board { queens: Queen lone -> one positions }
// Absolute value difference for comparing diagonal attack positions.
fun absDifference(m: Int, n: Int): Int {
  let difference = minus[m, n] {
    difference > 0 => difference else minus[0, difference]
  }
}
// Attack relationship in terms of coordinates.
pred attacks(q1: (Int -> Int), q2: (Int -> Int)) {
  let q1row = q1.univ, q1col = univ.q1,
    q2row = q2.univ, q2col = univ.q2,
    rowDifference = absDifference[q1row, q2row],
    colDifference = absDifference[q1col, q2col] {
    // Same row attacks
    rowDifference = 0 ||
    // Same column attacks
    colDifference = 0 ||
    // Diagonal attacks
    rowDifference = colDifference
  }
}
// Make sure no two queens attack each other.
fact notAttacking {
  all q1, q2: Queen | q1 != q2 => !attacks[Board.queens.q1, Board.queens.q2]
}
// Make sure every queen is assigned a position on the board. I think this is
// redundant and follows from Board signature
// assert assignedPosition { all q: Queen | one Board.queens.q }
// Run
run { } for 1 Board, exactly 8 Queen

// Model: puzzles/tower-hanoi/hanoi.als


/*
 * Towers of Hanoi model
 *
 * The Tower of Hanoi puzzle was invented by the French mathematician Edouard Lucas
 * in 1883. We are given a tower of eight disks, initially stacked in decreasing size on
 * one of three pegs. The objective is to transfer the entire tower to one of the other
 * pegs, moving only one disk at a time and never a larger one onto a smaller.
 *
 * The Alloy model below is written so that a solution to the model is a complete
 * sequence of valid moves solving an instance of the problem.  We define constraints
 * for the initial state (all discs on left stake), the final state (all discs on right stake),
 * and each pair of adjacent states (the top disc is moved from one stake to another,
 * not putting larger discs on smaller discs), and let Alloy Analyzer solve for the
 * sequence of states satisfying these constraints.  Since each adjacent pair of states is
 * constrained to be related by a single move, it is easy to see the sequence of moves
 * once you have the sequence of states.
 *
 * For n discs, 2^n states are needed for a solution
 *   (including the initial state and the final state).
 *
 * Performance: currently, the problem can be solved for up to 5 discs; this takes
 * several minutes with the Chaff solver.
 *
 * author: Ilya Shlyakhter
 */

open util/ordering[State] as states
open util/ordering[Stake] as stakes
open util/ordering[Disc] as discs

sig Stake { }

sig Disc { }

/**
 * sig State: the complete state of the system --
 * which disc is on which stake.  An solution is a
 * sequence of states.
 */
sig State {
  on: Disc -> one Stake  // _each_ disc is on _exactly one_ stake
  // note that we simply record the set of discs on each stake --
  // the implicit assumption is that on each stake the discs
  // on that stake are ordered by size with smallest disc on top
  // and largest on bottom, as the problem requires.
}

/**
 * compute the set of discs on the given stake in this state.
 * ~(this.on) map the stake to the set of discs on that stake.
 */
fun discsOnStake[st: State, stake: Stake]: set Disc {
  stake.~(st.on)
}

/**
 * compute the top disc on the given stake, or the empty set
 * if the stake is empty
 */
fun topDisc[st: State, stake: Stake]: lone Disc {
  { d: st.discsOnStake[stake] | st.discsOnStake[stake] in discs/nexts[d] + d }
}

/**
 * Describes the operation of moving the top disc from stake fromStake
 * to stake toStake.  This function is defined implicitly but is
 * nevertheless deterministic, i.e. the result state is completely
 * determined by the initial state and fromStake and toStake; hence
 * the "det" modifier above.  (It's important to use the "det" modifier
 * to tell the Alloy Analyzer that the function is in fact deterministic.)
 */
pred Move [st: State, fromStake, toStake: Stake, s": State] {
   let d = st.topDisc[fromStake] | {
      // all discs on toStake must be larger than d,
      // so that we can put d on top of them
      st.discsOnStake[toStake] in discs/nexts[d]
      // after, the fromStake has the discs it had before, minus d
      s".discsOnStake[fromStake] = st.discsOnStake[fromStake] - d
      // after, the toStake has the discs it had before, plus d
      s".discsOnStake[toStake] = st.discsOnStake[toStake] + d
      // the remaining stake afterwards has exactly the discs it had before
      let otherStake = Stake - fromStake - toStake |
        s".discsOnStake[otherStake] = st.discsOnStake[otherStake]
   }
}

/**
 * there is a leftStake that has all the discs at the beginning,
 * and a rightStake that has all the discs at the end
 */ 
pred Game1 {
   Disc in states/first.discsOnStake[stakes/first]
   some finalState: State | Disc in finalState.discsOnStake[stakes/last]

   // each adjacent pair of states are related by a valid move of one disc
   all preState: State - states/last |
       let postState = states/next[preState] |
          some fromStake: Stake | {
             // must have at least one disk on fromStake to be able to move
             // a disc from fromStake to toStake
             some preState.discsOnStake[fromStake]
             // post- results from pre- by making one disc move
             some toStake: Stake | preState.Move[fromStake, toStake, postState]
          }
}

/**
 * there is a leftStake that has all the discs at the beginning,
 * and a rightStake that has all the discs at the end
 */
pred Game2  {
   Disc in states/first.discsOnStake[stakes/first]
   some finalState: State | Disc in finalState.discsOnStake[stakes/last]

   // each adjacent pair of states are related by a valid move of one disc
   all preState: State - states/last |
       let postState = states/next[preState] |
          some fromStake: Stake |
             let d = preState.topDisc[fromStake] | {
               // must have at least one disk on fromStake to be able to move
               // a disc from fromStake to toStake
               some preState.discsOnStake[fromStake]
               postState.discsOnStake[fromStake] = preState.discsOnStake[fromStake] - d
               some toStake: Stake | {
                 // post- results from pre- by making one disc move
                 preState.discsOnStake[toStake] in discs/nexts[d]
                 postState.discsOnStake[toStake] = preState.discsOnStake[toStake] + d
                // the remaining stake afterwards has exactly the discs it had before
                let otherStake = Stake - fromStake - toStake |
                    postState.discsOnStake[otherStake] = preState.discsOnStake[otherStake]
                }
             }
      }

run Game1 for 1 but 3 Stake, 5 Disc, 32 State expect 1
run Game2 for 1 but 3 Stake, 3 Disc, 8 State expect 1

// Model: puzzles/coloring/color-australia.als
/**
 * Example constraint solving with Alloy
 * Solves the coloring problem for coloring Australia's states with
 * different colors. This problem was defined in miniZinc but I
 * think it looks better in Alloy
 */


sig Color {}
enum State { wa, nt, q, sa, nsw, v, t }

let adjacent = 
		wa -> nt 
	+ 	wa -> sa 
	+ 	nt->sa 
	+ 	nt->q 
	+ 	sa->q 
	+ 	sa->nsw 
	+ 	sa-> v 
	+ 	q->nsw 
	+ 	nsw->v

pred colors[ coloring :  State  -> one Color ] {
	all s : State, a : adjacent[s] | coloring[s] != coloring[a]
}

run colors for 1 but exactly 3 Color

// Model: ietf-rfcs/rfc7617-BasicAuth/basic-auth.als

// https://tools.ietf.org/html/rfc7617 Basic Authentication


sig BasicChallenge extends Challenge {
	realm	: Realm,
	charset	: lone Charset
} {
	name = "Basic"
	(RealmParameter & parameters).realm = Realm
	one charset implies (CharsetParameter & parameters).charset = charset
}


sig BasicCredentials extends Credentials {
	user_id		: String,
	password	:	String,
	charset		: lone Charset
} {
	name = "Basic"
	let     s = user_id.cat[":"].cat[password], 
	        c = one charset implies charset else OTHER_CHARSET, 
			p =  (Token68Parameter  & parameters ){

			p.value = c.binary[s]

	}
}

fun String.cat[ other : String ] : String {
	other // wrong! but cannot concatenate
}

// https://tools.ietf.org/html/rfc7235 Authentication

one sig SC_UNAUTHORIZED_401 									extends ResponseCode {}


sig AuthorizationServer extends Server {
	protectionSpaces		: set Realm
}

abstract sig Challenge extends AuthScheme {}
abstract sig Credentials extends AuthScheme {}


sig WWWAuthenticate extends Header {
	challenges		:	seq Challenge
} {
	name = "WWW-Authenticate"
	some challenges
}

sig Authorization extends Header {
	credentials	: Credentials
} {
	name = "Authorization"
}

abstract sig AuthScheme {
	name			: String,
	parameters		: set Parameter
} {
	some (Token68Parameter & parameters) implies one parameters
}

abstract sig Parameter {
}

sig Binary {
}

abstract sig Token68Parameter extends Parameter {
	value   : Binary
}

abstract sig AuthParam extends Parameter {
	name    : String
}

sig Realm  {}

sig RealmParameter extends AuthParam {
	realm : Realm
} {
	name = "realm"
}

abstract sig Charset {
	maps : String -> Binary
}

fun Charset.binary[ s : String ] : Binary {
	this.maps[s] 
}



one sig ASCII extends Charset {}
one sig ISO8859 extends Charset {}
one sig UTF16 extends Charset {}
one sig UTF8 extends Charset {}
one sig OTHER_CHARSET extends Charset {}

sig CharsetParameter extends AuthParam {
	charset : Charset
} {
	name = "charset"
}


fact WWWAuthenticateChallengeResponse {
	all r : HttpResponse | 
		r.response = SC_UNAUTHORIZED_401 implies some (r.headers.elems & WWWAuthenticate )
}


// https://tools.ietf.org/html/rfc7230 (HTTP 1.1) and further

sig Server {}


sig Path {}
one sig EmptyPath extends Path {
}

sig URI {
	host			:	Server,
	path			: Path
}

enum Method { GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD }

enum ResponseCode {
	SC_OK_200, SC_NOT_FOUND_404, SC_TEMP_REDIRECT_302
}

abstract sig Body {}


sig HttpRequest {
	method		: Method,
	url				: URI,
	headers 	: seq Header,
	body			: lone Body
}

sig HttpResponse {
	response	: ResponseCode,
	headers 	: seq Header,
	payload		: lone Body,
}


abstract sig Header {
	name			: String
}


fact fixup {
	all a : Authorization | a in HttpRequest.headers.elems
	all a : WWWAuthenticate | a in HttpResponse.headers.elems
	all b : Credentials | b in Authorization.credentials
	all b : Challenge | b in WWWAuthenticate.challenges.elems
	all b : Body | lone r : HttpRequest | r.body = b
}

run {} for 3

// Model: simple-models/genealogy/genealogy.als


/*
 * Toy model of genealogical relationships
 *
 * The purpose of this model is to introduce basic concepts in Alloy.
 * The signature Person introduces a set of persons; this is paritioned into
 * two subsets, Man and Woman. The subsignature Adam declares a set of men
 * with one element -- that is, a scalar. Similarly, Eve declares a single
 * woman.
 *
 * The Person signature declares two fields: a person has one or zero spouses
 * and a set of parents.
 *
 * The facts should be self-explanatory. Note that the constraint that
 * spouse is a symmetric relation (that is, p is a spouse of q if q is a spouse
 * of p) is written by equating the field, viewed as a relation, to its
 * transpose. Since signatures have their own namespaces, and the same field
 * name can refer to different fields in different relations, it is necessary
 * to indicate which signature the field belongs to. This is not necessary when
 * dereferencing a field, because the appropriate field is automatically
 * determined by the type of the referencing expression.
 *
 * The command has no solutions. Given only 5 persons, it's not possible
 * to have a couple distinct from Adam and Eve without incest. To understand
 * the model, try weakening the constraints by commenting lines out (just
 * put two hyphens at the start of a line) and rerunning the command.
 *
 * author: Daniel Jackson, 11/13/01
 */

abstract sig Person {spouse: lone Person, parents: set Person}
sig Man, Woman extends Person {}
one sig Eve extends Woman {}
one sig Adam extends Man {}

fact Biology {
    -- nobody is his or her own ancestor
    no p: Person | p in p.^parents
    }

fact Bible {
    -- every person except Adam and Eve has a mother and father
    all p: Person - (Adam + Eve) | one mother: Woman, father: Man |
        p.parents = mother + father
    -- Adam and Eve have no parents
    no (Adam + Eve).parents
    -- Adam's spouse is Eve
    Adam.spouse = Eve
    }

fact SocialNorms {
    -- nobody is his or her own spouse
    no p: Person | p.spouse = p
    -- spouse is symmetric
    spouse = ~spouse
    -- a man's spouse is a woman and vice versa
    Man.spouse in Woman && Woman.spouse in Man
    }

fact NoIncest {
    -- can't marry a sibling
    no p: Person | some p.spouse.parents & p.parents
    -- can't marry a parent
    no p: Person | some p.spouse & p.parents
    }

pred Show {
    some p: Person - (Adam + Eve) | some p.spouse
    }
run Show for 6 expect 1




// Model: simple-models/genealogy/grandpa.als


/*
 * An Alloy model of the song "I Am My Own Grandpa"
 * by Dwight B. Latham and Moe Jaffe
 *
 * The challenge is to produce a man who is his own grandfather
 * without resorting to incest or time travel.  Executing the predicate
 * "ownGrandpa" will demonstrate how such a thing can occur.
 *
 * The full song lyrics, which describe an isomorophic solution,
 * are included at the end of this file.
 *
 * model author: Daniel Jackson
 */

abstract sig Person {
    father: lone Man,
    mother: lone Woman
    }

sig Man extends Person { wife: lone Woman }

sig Woman extends Person { husband: lone Man }

fact Biology { no p: Person | p in p.^(mother+father) }

fact Terminology { wife = ~husband }

fact SocialConvention {
    no wife & *(mother+father).mother
    no husband & *(mother+father).father
    }

fun grandpas [p: Person]: set Person {
    let parent = mother + father + father.wife + mother.husband |
        p.parent.parent & Man
    }

pred ownGrandpa [m: Man] { m in grandpas[m]  }

run ownGrandpa for 4 Person expect 1

/* defined variables:
 *
 * spouse = husband+wife
 */

/*
I Am My Own Grandpa
by Dwight B. Latham and Moe Jaffe

Many many years ago, when I was twenty-three,
I was married to a widow as pretty as can be,
This widow had a grown-up daughter who had hair of red,
My father fell in love with her and soon the two were wed.

    I'm my own grandpa, I'm my own grandpa.
    It sounds funny, I know, but it really is so—
    I'm my own grandpa.

This made my dad my son-in-law and changed my very life,
For my daughter was my mother, for she was my father's wife.
To complicate the matter, even though it brought me joy,
I soon became the father of a bouncing baby boy.

My little baby thus became a brother-in-law to dad,
And so became my uncle, though it made me very sad,
For if he was my uncle then that also made him brother
To the widow's grown-up daughter, who of course was my step-mother.

Father's wife then had a son who kept them on the run.
And he became my grandchild for he was my daughter's son.
My wife is now my mother's mother and it makes me blue,
Because although she is my wife, she's my grandmother, too.

Oh, if my wife's my grandmother then I am her grandchild.
And every time I think of it, it nearly drives me wild.
For now I have become the strangest case you ever saw—
As the husband of my grandmother, I am my own grandpa.

    I'm my own grandpa, I'm my own grandpa.
    It sounds funny, I know, but it really is so—
    I'm my own grandpa.
    I'm my own grandpa, I'm my own grandpa.
    It sounds funny, I know, but it really is so—
    I'm my own grandpa.
*/

// Model: simple-models/state-machine/flip-flop.als
//
// A simple model of a flipflop state machine that 
// flips on every clock event.
//
// This is probably the simplest possible time based example
// for Alloy but shows how to make a trace. 
//

open util/ordering[Trace]

enum Event { C }
enum State { On, Off }

fun transitions : State -> Event -> State {
    On  -> C -> Off 
  + Off -> C -> On
}

sig Trace {
  state : State,
  event : lone Event
}

fact {
  first.state = On
  no last.event

  all t : Trace - last, t" : t.next {
    some e : Event {
      t.event = e 
      t".state = transitions[t.state][t.event]
    }
  }
}

pred show( t : set Trace ) { }

run show  for 10

// Model: simple-models/state-machine/reset-flipflop-with-enable.als

open util/ordering[Trace]

enum Event { C, X }
enum State { On, Off }

fun transitions : State -> Event -> State {
			On  -> C -> Off 
		+ On  -> X -> On
		+ Off -> C -> On
		+ Off -> X -> Off 
}

sig Trace {
	state : State,
	event : lone Event
}

fact {
	first.state = On
	no last.event	

	all t" : Trace - first, t : t".prev {
		some e : Event | 
					t.event = e 
			and t".state = transitions[t.state][t.event]
	}
}

pred show( ) { 
	some t : Trace | all s : t.^next | s.state = Off 

}

run show  for 10

// Model: simple-models/lists/lists.als
/*
 * a simple list module
 * which demonstrates how to create predicates and fields that mirror each other
 *   thus allowing recursive constraints (even though recursive predicates are not
 *   currently supported by Alloy)
 * author: Robert Seater
 */

sig Thing {}
fact NoStrayThings {Thing in List.car}

abstract sig List {
    equivTo: set List,
    prefixes: set List
    }
sig NonEmptyList extends List {
    car: one Thing,
    cdr: one List
    }
sig EmptyList extends List {}

pred isFinite [L:List] {some e: EmptyList | e in L.*cdr}
fact finite {all L: List | isFinite[L]}

fact Equivalence {
    all a,b: List | (a in b.equivTo) <=> ((a.car = b.car and b.cdr in a.cdr.equivTo) and (#a.*cdr = #b.*cdr))
    }
assert reflexive {all L: List | L in L.equivTo}
check reflexive for 6 expect 0
assert symmetric {all a,b: List | a in b.equivTo <=> b in a.equivTo}
check symmetric for 6 expect 0
assert empties {all a,b: EmptyList | a in b.equivTo}
check empties for 6 expect 0

fact prefix { //a is a prefix of b
    all e: EmptyList, L:List | e in L.prefixes
    all a,b: NonEmptyList | (a in b.prefixes) <=> (a.car = b.car
                                                and a.cdr in b.cdr.prefixes
                                                and #a.*cdr < #b.*cdr)
}

pred show {
    some a, b: NonEmptyList | a!=b && b in a.prefixes
    }
run show for 4 expect 1


// Model: simple-models/4-bit-adder/4-bit-adder.als
// Example of how to create basic boolean logic circuits. Starting with the
// definition of basic boolean operations we build a half-adder and then
// a 4-bit full adder using 4 registers: 2 summands, 1 sum, 1 carry

// 0 or 1
let bits = { i: Int | 0 <= i && i <= 1 }

// Or
let bitOrTable = { i: bits, j: bits, k: sum[i + j] }

// And
let bitAndTable = { i: bits, j: bits, k: mul[i, j] }

// Not
let bitNotTable = { i: bits, j: minus[1, i] }

// Xor: https://en.wikipedia.org/wiki/Exclusive_or
let bitXorTable = {
  i: bits,
  j: bits,
  k: bitAndTable[bitOrTable[i, j], bitNotTable[bitAndTable[i, j]]]
}

// Half adder: https://en.wikipedia.org/wiki/Adder_(electronics)#Half_adder
pred halfAdder(m: Int, n: Int, s: Int, c: Int) {
  s = bitXorTable[m, n]
  c = bitAndTable[m, n]
}

// https://en.wikipedia.org/wiki/Adder_(electronics)#/media/File:Full-adder_logic_diagram.svg
pred fullAdder(m: Int, n: Int, c: Int, s: Int, carry: Int) {
  let xor = bitXorTable[m, n] {
    s = bitXorTable[xor, c]
    carry = bitOrTable[bitAndTable[m, n], bitAndTable[xor, c]]
  }
}

// BitVector consists of 4 bits
abstract sig BitVector {
  values: (0 + 1 + 2 + 3) -> one bits
}

// We want 4 vectors to perform a computation: 2 summands, sum, and carry
one sig A, B, C, S extends BitVector { }

// 4 bit adder with overflow
pred bitAddition(a: BitVector, b: BitVector, c: BitVector, s: BitVector) {
  fullAdder[a.values[0], b.values[0], 0, s.values[0], c.values[0]]
  fullAdder[a.values[1], b.values[1], c.values[0], s.values[1], c.values[1]]
  fullAdder[a.values[2], b.values[2], c.values[1], s.values[2], c.values[2]]
  fullAdder[a.values[3], b.values[3], c.values[2], s.values[3], c.values[3]]
}

// Run it to verify
run {
  bitAddition[A, B, C, S]
}

// Model: simple-models/books/birthday.als


/*
 * Birthday Book
 *
 * A classic Z example to explain the basic form of an Alloy model. For the original,
 * see J.M. Spivey, The Z Notation, Second Edition, Prentice Hall, 1992.
 *
 * A birthday book has two fields: known, a set of names (of persons whose birthdays are known),
 * and date, a function from known names to dates. The operation AddBirthday adds an association
 * between a name and a date; it uses the relational override operator (++), so any existing
 * mapping from the name to a date is replaced. DelBirthday removes the entry for a given name.
 * FindBirthday obtains the date d for a name n. The argument d is declared to be optional (that is,
 * a singleton or empty set), so if there is no entry for n, d will be empty. Remind gives the set
 * of names whose birthdays fall on a particular day.
 *
 * The assertion AddWorks says that if you add an entry, then look it up, you get back what you
 * just entered. DelIsUndo says that doing DelBirthday after AddBirthday undoes it, as if the add
 * had never happened. The first of these assertions is valid; the second isn't.
 *
 * The function BusyDay shows a case in which Remind produces more than one card.
 *
 * author: Daniel Jackson, 11/14/01
 */

sig Name {}
sig Date {}
sig BirthdayBook {known: set Name, date: known -> one Date}

pred AddBirthday [bb, bb": BirthdayBook, n: Name, d: Date] {
    bb".date = bb.date ++ (n->d)
    }

pred DelBirthday [bb, bb": BirthdayBook, n: Name] {
    bb".date = bb.date - (n->Date)
    }

pred FindBirthday [bb: BirthdayBook, n: Name, d: lone Date] {
    d = bb.date[n]
    }

pred Remind [bb: BirthdayBook, today: Date, cards: set Name] {
    cards = (bb.date).today
    }

pred InitBirthdayBook [bb: BirthdayBook] {
    no bb.known
    }

assert AddWorks {
    all bb, bb": BirthdayBook, n: Name, d: Date, d": lone Date |
        AddBirthday [bb,bb",n,d] && FindBirthday [bb",n,d"] => d = d"
    }

assert DelIsUndo {
    all bb1,bb2,bb3: BirthdayBook, n: Name, d: Date|
        AddBirthday [bb1,bb2,n,d] && DelBirthday [bb2,bb3,n]
            => bb1.date = bb3.date
    }

check AddWorks for 3 but 2 BirthdayBook expect 0
check DelIsUndo for 3 but 2 BirthdayBook expect 1

pred BusyDay [bb: BirthdayBook, d: Date]{
    some cards: set Name | Remind [bb,d,cards] && !lone cards
    }

run BusyDay for 3 but 1 BirthdayBook expect 1

// Model: simple-models/no-solution/trivial.als
//a trivial model whose command has no solution


sig S {}

fact { 1=2 }

run {some S} expect 0

// Model: simple-models/games/life.als


/*
 * John Conway's Game of Life
 *
 * For a detailed description, see:
 *  http://www.math.com/students/wonders/life/life.html
 *
 * authors: Bill Thies, Manu Sridharan
 */

open util/ordering[State] as ord

sig Point {
  right: lone Point,
  below: lone Point
}

fact Acyclic {
  all p: Point | p !in p.^(right + below)
}

one sig Root extends Point {}

fact InnerSquaresCommute {
  all p: Point {
    p.below.right = p.right.below
    some p.below && some p.right => some p.below.right
  }
}

fact TopRow {
  all p: Point - Root | no p.~below => # p.*below = # Root.*below
}

fact Connected {
  Root.*(right + below) = Point
}

pred Square {
  # Root.*right = # Root.*below
}

run Square for 6 Point, 3 State expect 1

pred Rectangle {}

sig State {
  live : set Point
}

fun Neighbors[p : Point] : set Point {
  p.right + p.right.below + p.below
              + p.below.~right + p.~right
              + p.~right.~below + p.~below +
              p.~below.right
}

fun LiveNeighborsInState[p : Point, s : State] : set Point {
  Neighbors[p] & s.live
}

pred Trans[pre, post: State, p : Point] {
   let preLive = LiveNeighborsInState[p,pre] |
    // dead cell w/ 3 live neighbors becomes live
    (p !in pre.live && # preLive = 3) =>
    p in post.live
  else (
    // live cell w/ 2 or 3 live neighbors stays alive
    (p in pre.live && (# preLive = 2 || # preLive = 3)) =>
      p in post.live else p !in post.live
    )
}

fact ValidTrans {
  all pre : State - ord/last |
    let post = ord/next[pre] |
      all p : Point |
        Trans[pre,post,p]
}

pred Show {}

// slow
run Show for exactly 12 Point, 3 State expect 1

// a small but interesting example
pred interesting {
	some State.live
	some Point - State.live
	some right
	some below
}
run interesting for exactly 6 Point, 3 State expect 1

// Model: paper-examples/jackson-cacm-2019/origin-tracking.als
// Example from CACM 2019 paper by Jackson
// Alloy: A Language and Tool for Exploring Software Designs
// An exploration of an origin tracking mechanism to counter CSRF

abstract sig EndPoint { }

sig Server extends EndPoint {
	causes: set HTTPEvent
	}

sig Client extends EndPoint { }

abstract sig HTTPEvent {
	from, to, origin: EndPoint
	}

sig Request extends HTTPEvent {
	response: lone Response
	}

sig Response extends HTTPEvent {
	embeds: set Request
	}

sig Redirect extends Response {
	}

run {some response}

fact Directions {
	Request.from + Response.to in Client
	Request.to + Response.from in Server
	}

fact Causality {
	-- s causes e if
	-- 	e is (a response) from s, or
	-- 	e is (a request) embedded in r and s causes r
	all e: HTTPEvent, s: Server |
		e in s.causes iff e.from = s or some r: Response | e in r.embeds and r in s.causes
	}

fact RequestResponse {
	-- time order of requests
	all r: Request | r not in  r.^(response.embeds)
	-- every response comes from a single request
	all r: Response | one response.r
	
	all r: Response | r.to = response.r.from and r.from = response.r.to
	}
	
fact Origin {
	// for a redirect, origin is same as request, else server
	all r: Response | r.origin = (r in Redirect implies response.r.origin else r.from)
	// embedded requests have the same origin as the response
	all r: Response, e: r.embeds | e.origin = r.origin
	// requests that are not embedded come from the client
	all r: Request | no embeds.r implies r.origin in r.from
	}

pred obeysOrigins (s: Server) {
	// request is only accepted if origin is itself or sender
	all r: Request | r.to =s implies r.origin = r.to or r.origin = r.from
	}

check {
	no good, bad: Server {
		no r: Request | r.to = bad and r.origin in Client				
		good.obeysOrigins
		some r: Request | r.to = good and r in bad.causes
		}
	} for 5
