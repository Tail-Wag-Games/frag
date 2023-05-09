import macros, strutils


{.passC: "/I C:\\Users\\Zach\\dev\\frag\\thirdparty\\flecs".}
{.compile: "C:\\Users\\Zach\\dev\\frag\\thirdparty\\flecs\\flecs.c".}

const
  idCacheSize = 32
  termDescCacheSize = 16

type
  Time* = object
    sec*: uint32
    nanosec*: uint32

  Vec* = object
    elements*: pointer
    count*: int32
    size*: int32

  InOutKind* = distinct int32
  OperKind* = distinct int32

  Id* = uint64
  IdRecord* = object

  Entity* = Id

  Ids* = object
    ids*: ptr UncheckedArray[Id]
    count*: int32

  Table* = object
  Query* = object
  Rule* = object
  TableRecord* = object
  QueryTableNode* = object

  Poly* = pointer

  PolyDtor* = proc(poly: ptr Poly) {.cdecl.}

  IterInitAction* = proc(world: ptr World; iterable: ptr Poly; it: ptr Iter;
      filter: ptr Term) {.cdecl.}
  IterNextAction* = proc(it: ptr Iter): bool {.cdecl.}
  FiniAction* = proc(it: ptr Iter) {.cdecl.}
  CtxFree* = proc(p: pointer) {.cdecl.}
  OrderByAction* = proc(e1: Entity; p1: pointer; e2: Entity;
      p2: pointer): int32 {.cdecl.}
  SortTableAction* = proc(world: ptr World; tbl: ptr Table;
      entities: ptr UncheckedArray[Entity]; p: pointer; size, lo, hi: int32;
      orderBy: OrderByAction) {.cdecl.}
  GroupByAction* = proc(world: ptr World; tbl: ptr Table; groupId: uint64; ctx: pointer): uint64 {.cdecl.}
  GroupCreateAction* = proc(world: ptr World; groupId: uint64; groupByCtx: pointer): pointer {.cdecl.}
  GroupDeleteAction* = proc(world: ptr World; groupId: uint64; groupCtx, groupByCtx: pointer) {.cdecl.}

  Iterable* = object
    init*: IterInitAction

  TermId* = object
    id*: Entity
    name*: cstring
    trav*: Entity
    flags*: uint32

  Term* = object
    id*: Id
    src*: TermId
    first*: TermId
    second*: TermId
    inOut*: InOutKind
    oper*: OperKind
    idFlags*: Id
    name*: cstring
    fieldIdx*: int32
    idr*: ptr IdRecord
    flags*: uint16
    move*: bool

  Mixins* = object

  Header* = object
    magic*: int32
    kind*: int32
    mixins*: ptr Mixins

  Filter* = object
    hdr*: Header
    terms*: ptr UncheckedArray[Term]
    termCount*: int32
    fieldCount*: int32

    owned*: bool
    termsOwned*: bool

    flags*: uint32
    variableNames*: array[1, cstring]
    sizes*: ptr UncheckedArray[int32]

    entity*: Entity
    iterable*: Iterable
    dtor*: PolyDtor
    world*: ptr World

  Record* = object
    idr*: ptr IdRecord
    table*: ptr Table
    row*: uint32

  TableRange* = object
    table*: ptr Table
    offset*: int32
    count*: int32

  Var* = object
    tblRange*: TableRange
    entity*: Entity

  Ref* = object
    entity*: Entity
    id*: Entity
    tr*: ptr TableRecord
    record*: ptr Record

  TableCacheHdr = object

  TableCacheIter = object
    cur, next: ptr TableCacheHdr
    nextList: ptr TableCacheHdr

  TermIter = object
    term: Term
    selfIdx: ptr IdRecord
    setIdx: ptr IdRecord

    cur: ptr IdRecord
    it: TableCacheIter
    idx: int32
    observedTableCount: int32

    table: ptr Table
    curMatch: int32
    matchCount: int32
    lastColumn: int32

    emptyTables: bool

    id: Id
    column: int32
    subject: Entity
    size: int32
    p: pointer

  FilterIter = object
    filter: Filter
    termIter: TermIter
    matchesLeft: int32
    pivotTerm: int32

  QueryIter = object
    query: ptr Query
    node, prev, last: ptr QueryTableNode
    sparseSmallest: int32
    sparseFirst: int32
    bitsetFirst: int32
    skipCount: int32

  SnapshotIter = object
    filter: Filter
    tables: Vec
    idx: int32

  RuleOpProfile* = object
    count*: array[2, int32]

  RuleVar* = object
  RuleOp* = object
  RuleOpCtx* = object

  RuleIter* = object
    rule*: ptr Rule
    vars*: ptr UncheckedArray[Var]
    ruleVars*: ptr UncheckedArray[RuleVar]
    ruleOps*: ptr UncheckedArray[RuleOp]
    opCtx*: ptr RuleOpCtx
    written*: uint64

  PageIter* = object
    offset*: int32
    limit*: int32
    remaining*: int32

  WorkerIter* = object
    idx*: int32
    count*: int32

  IterSpecificData {.union.} = object
    term: TermIter
    filter: FilterIter
    query: QueryIter
    rule: RuleIter
    snapshot: SnapshotIter
    page: PageIter
    worker: WorkerIter

  IterData = object
    iter: IterSpecificData

  Iter* = object
    world*: ptr World
    realWorld*: ptr World

    entities*: ptr UncheckedArray[Entity]
    ptrs*: ptr UncheckedArray[pointer]
    sizes*: ptr UncheckedArray[int32]
    table*: ptr Table
    otherTable*: ptr Table
    ids*: ptr UncheckedArray[Id]
    variables*: ptr UncheckedArray[Var]
    columns*: ptr UncheckedArray[int32]
    sources*: ptr UncheckedArray[Entity]
    matchIndices*: ptr UncheckedArray[int32]
    references*: ptr UncheckedArray[Ref]
    constrainedVars*: ptr UncheckedArray[uint64]
    groupId*: uint64
    fieldCount*: int32

    system*: Entity
    event*: Entity
    eventId*: Id

    terms*: ptr UncheckedArray[Term]
    tableCount*: int32
    termIndex*: int32

    variableCount*: int32
    variableNames*: ptr UncheckedArray[cstring]

    param*: pointer
    ctx*: pointer
    bindingCtx*: pointer

    deltaTime*: float32
    deltaSystemTime*: float32

    frameOffset*: int32
    offset*: int32
    count*: int32
    instanceCount*: int32

    flags*: uint32

    interruptedBy*: Entity
    priv: IterData

    next*: IterNextAction
    callback*: IterAction
    fini*: FiniAction
    chainIt*: ptr Iter

  Xtor* = proc(p: pointer; count: int32; typeInfo: ptr TypeInfo) {.cdecl.}
  Copy* = proc(dst, src: pointer; count: int32;
      typeInfo: ptr TypeInfo) {.cdecl.}
  Move* = proc(dst, src: pointer; count: int32;
      typeInfo: ptr TypeInfo) {.cdecl.}
  RunAction* = proc(it: ptr Iter) {.cdecl.}
  IterAction* = proc(it: ptr Iter) {.cdecl.}

  TypeHooks* = object
    ctor*: Xtor
    dtor*: Xtor
    copy*: Copy
    move*: Move
    copyCtor*: Copy
    moveCtor*: Move
    ctorMoveDtor*: Move
    moveDtor*: Move
    onAdd*: IterAction
    onSet*: IterAction
    onRemove*: IterAction

    ctx*: pointer
    bindingCtx*: pointer
    freeCtx*: CtxFree
    freeBindingCtx*: CtxFree

  TypeInfo* = object
    size*: int32
    alignment*: int32
    hooks*: TypeHooks
    component*: Entity
    name*: cstring

  ComponentDesc* = object
    canary: int32
    entity*: Entity
    typeInfo*: TypeInfo

  EntityDesc* = object
    canary: int32
    id*: Entity
    name*: cstring
    sep*: cstring
    rootSep*: cstring
    symbol*: cstring
    useLowId*: bool
    add*: array[idCacheSize, Id]
    addExpr*: cstring

  FilterDesc* = object
    canary: int32
    terms*: array[termDescCacheSize, Term]
    termsBuffer*: ptr UncheckedArray[Term]
    termsBufferCount*: int32
    storage*: ptr Filter
    instanced*: bool
    flags*: uint32
    filterExpr*: cstring
    entity*: Entity

  QueryDesc* = object
    canary: int32
    filter*: FilterDesc
    orderByComponent*: Entity
    orderBy*: OrderByAction
    sortTable*: SortTableAction
    groupById*: Id
    groupBy*: GroupByAction
    onGroupCreate*: GroupCreateAction
    onGroupDelete*: GroupDeleteAction
    groupByCtx*: pointer
    groupByCtxFree*: CtxFree
    parent*: Query

  SystemDesc* = object
    canary: int32
    entity*: Entity
    query*: QueryDesc
    run*: RunAction
    callback*: IterAction
    ctx*: pointer
    bindingCtx*: pointer
    freeCtx*: CtxFree
    freeBindingCtx*: CtxFree
    interval*: float32
    rate*: int32
    tickSource*: Entity
    multiThreaded*: bool
    noReadonly*: bool
  
  OsThread* = uint
  OsCond* = uint
  OsMutex* = uint
  OsDl* = uint
  OsSock* = uint
  OsThreadId* = uint64

  OsProc* = proc() {.cdecl.}
  OsApiInit* = proc() {.cdecl.}
  OsApiDestroy* = proc() {.cdecl.}
  OsApiMalloc* = proc(sizie: int32): pointer {.cdecl.}
  OsApiCalloc* = proc(size: int32): pointer {.cdecl.}
  OsApiFree* = proc(p: pointer) {.cdecl.}
  OsApiRealloc* = proc(p: pointer; size: int32): pointer {.cdecl.}
  OsApiStrdup* = proc(str: cstring): cstring {.cdecl.}
  OsThreadCallback* = proc(p: pointer): pointer {.cdecl.}
  OsApiThreadNew* = proc(cb: OsThreadCallback; param: pointer): OsThread {.cdecl.}
  OsApiThreaedJoin* = proc(t: OsThread): pointer {.cdecl.}
  OsApiThreadSelf* = proc(): OsThreadId {.cdecl.}
  OsApiAInc* = proc(val: ptr int32): int32 {.cdecl.}
  OsApiLAInc* = proc(val: ptr int64): int64 {.cdecl.}
  OsApiMutexNew* = proc(): OsMutex {.cdecl.}
  OsApiMutexLock* = proc(m: OsMutex) {.cdecl.}
  OsApiMutexUnlock* = proc(m: OsMutex) {.cdecl.}
  OsApiMutexFree* = proc(m: OsMutex) {.cdecl.}
  OsApiCondNew* = proc(): OsCond {.cdecl.}
  OsApiCondFree* = proc(c: OsCond) {.cdecl.}
  OsApiCondSignal* = proc(c: OsCond) {.cdecl.}
  OsApiCondBroadcast* = proc(c: OsCond) {.cdecl.}
  OsApiCondWait* = proc(c: OsCond; m: OsMutex) {.cdecl.}
  OsApiSleep* = proc(sec: int32; nanosec: int32) {.cdecl.}
  OsApiEnableHighTimerResolution* = proc(enable: bool) {.cdecl.}
  OsApiGetTime* = proc(timeOut: ptr Time) {.cdecl.}
  OsApiNow* = proc(): uint64
  OsApiLog* = proc(level: int32; file: cstring; line: int32; msg: cstring) {.cdecl.}
  OsApiAbort* = proc() {.cdecl.}
  OsApiDlOpen* = proc(libName: cstring): OsDl {.cdecl.}
  OsApiDlProc* = proc(lib: OsDl; procname: cstring): OsProc {.cdecl.}
  OsApiDlClose* = proc(lib: OsDl) {.cdecl.}
  OsApiModuleToPath* = proc(moduleId: cstring): cstring {.cdecl.}
  
  OsApi* = object
    init*: OsApiInit
    destroy*: OsApiDestroy

    malloc*: OsApiMalloc
    realloc*: OsApiRealloc
    calloc*: OsApiCalloc
    free*: OsApiFree

    strdup*: OsApiStrdup

    newThread*: OsApiThreadNew
    joinThread*: OsApiThreaedJoin
    selfThread*: OsApiThreadSelf

    aInc*: OsApiAInc
    aDec*: OsApiAInc
    laInc*: OsApiLAInc
    laDec*: OsApiLAInc

    newMutex*: OsApiMutexNew
    freeMutex*: OsApiMutexFree
    lockMutex*: OsApiMutexLock
    unlockMutex*: OsApiMutexUnlock

    newCond*: OsApiCondNew
    freeCond*: OsApiCondFree
    signalCond*: OsApiCondSignal
    broadcastCond*: OsApiCondBroadcast
    waitCond*: OsApiCondWait

    sleep*: OsApiSleep
    now*: OsApiNow
    getTime*: OsApiGetTime

    log*: OsApiLog

    abort*: OsApiAbort

    dlOpen*: OsApiDlOpen
    dlProc*: OsApiDlProc
    dlClose*: OsApiDlClose

    moduleToDl*: OsApiModuleToPath
    moduleToEtc*: OsApiModuleToPath

    logLevel*: int32
    logIndent*: int32
    logLastError*: int32
    logLastTimestamp*: int64
    flags*: uint32

  World* = object

proc `=destroy`*(a: var OsApi) =
  discard

var
  osApi* {.importc:"ecs_os_api".}: OsApi

proc initWorld*(): ptr World {.importc: "ecs_init", cdecl.}
proc initEntity*(world: ptr World; desc: ptr EntityDesc): Entity {.importc: "ecs_entity_init", cdecl.}
proc initComponent*(world: ptr World; desc: ptr ComponentDesc): Entity {.importc: "ecs_component_init", cdecl.}
proc initSystem*(world: ptr World; desc: ptr SystemDesc): Entity {.importc: "ecs_system_init", cdecl.}
proc setId*(world: ptr World; entity: Entity; id: Id; size: uint; p: pointer): Entity {.importc: "ecs_set_id", cdecl, discardable.}
proc getId*(world: ptr World; entity: Entity; id: Id): pointer {.importc: "ecs_get_id", cdecl.}
proc addId*(world: ptr World; entity: Entity; id: Id) {.importc: "ecs_add_id", cdecl.}
proc fieldWSize*(it: ptr Iter; size: uint; idx: int32): pointer {.importc: "ecs_field_w_size", cdecl.}
proc tableStr*(world: ptr World; table: ptr Table): cstring {.importc: "ecs_table_str", cdecl.}
proc progress*(world: ptr World; deltaTime: float32): bool {.importc: "ecs_progress", cdecl, discardable.}
proc destroyWorld*(world: ptr World): int32 {.importc: "ecs_fini", cdecl, discardable.}

const
  fecsHiComponentId* = 256

  ecsPair = Id(1'u64 shl 63)

  ecsDependsOn* = fecsHiComponentId + 29

  ecsOnUpdate* = fecsHiComponentId + 69

template entityComb(lo, hi: untyped): untyped =
  uint64(hi) shl 32 + uint32(lo)

template pair(pre, obj: untyped): untyped =
  ecsPair or entityComb(obj, pre)

macro entity(world, id: untyped, args: varargs[typed, `$`]): untyped =
  let
    entityName = $`id`
    entityId = ident("fecs" & entityName)
  
  var addExpr = ""
  for i, arg in args:
    addExpr = if i > 0: join([addExpr, $arg], ", ") else: $arg

  result = quote do:
    var
      `entityId`: Entity
      `id`: Entity
      desc: EntityDesc
    
    desc.id = `id`
    desc.name = `entityName`
    desc.addExpr = cstring(`addExpr`)
    `id` = initEntity(`world`, addr(desc))
    `entityId` = `id`
    assert(`id` != 0)

macro component(world, id: untyped): untyped =
  let
    componentName = $`id`
    componentId = ident("fecs" & componentName)
  result = quote do:
    var
      `componentId`: Entity
      desc: ComponentDesc
      eDesc: EntityDesc

    eDesc.id = `componentId`
    eDesc.useLowId = true
    eDesc.name = `componentName`
    eDesc.symbol = `componentName`
    desc.entity = initEntity(`world`, addr(eDesc))
    desc.typeInfo.size = int32(sizeof(`id`))
    desc.typeInfo.alignment = int32(alignof(`id`))
    `componentId` = initComponent(`world`, addr(desc))
    assert(`componentId` != 0)

macro system(world, id, phase: untyped; args: varargs[typed]): untyped =
  let
    systemName = $`id`
    systemId = ident("fecs" & systemName)
  
  var filterExpr = ""
  for i, arg in args:
    filterExpr = if i > 0: join([filterExpr, $arg], ", ") else: $arg

  result = quote do:
    var
      `systemId`: Entity
      desc: SystemDesc
      eDesc: EntityDesc

    eDesc.id = `systemId`
    eDesc.name = `systemName`
    eDesc.add[0] = if bool(`phase`): pair(ecsDependsOn, `phase`) else: 0
    eDesc.add[1] = `phase`
    desc.entity = initEntity(`world`, addr(eDesc))
    desc.query.filter.filterExpr = `filterExpr`
    desc.callback = `id`
    `systemId` = initSystem(`world`, addr(desc))

template tag(world, id: untyped): untyped =
  entity(world, id, 0)

template newEntity(world, n: untyped): untyped =
  var desc = EntityDesc(
    name: $n
  )
  initEntity(world, addr(desc))

macro set(world, entity, component, val: untyped): untyped =
  let
    componentName = $`component`
    componentId = ident("fecs" & componentName)
  
  result = quote do:
    var vVal = `val`
    setId(`world`, `entity`, `componentId`, uint(sizeof(`component`)), cast[pointer](addr(vVal)))

template addPair(world, subject, first, second: untyped): untyped =
  addId(world, subject, pair(first, second))

macro get(world, entity, T: untyped): untyped =
  let
    id = ident("fecs" & $`T`)
  result = quote do:
    cast[ptr `T`](getId(`world`, `entity`, `id`))

macro field(it, T, idx: untyped): untyped =
  result = quote do:
    cast[ptr UncheckedArray[`T`]](fieldWSize(`it`, uint(sizeof(`T`)), `idx`))

template osFree(p: untyped) =
  osApi.free(p)

when isMainModule:
  import strformat

  type
    Position = object
      x, y: float64

    Velocity = object
      x, y: float64

  proc mv(it: ptr Iter) {.cdecl.} =
    let
      p = field(it, Position, 1)
      v = field(it, Velocity, 2)
      typeStr = tableStr(it.world, it.table)
    
    echo &"Move entities with [{typeStr}]"
    osFree(typeStr)

    for i in 0 ..< it.count:
      p[i].x += v[i].x
      p[i].y += v[i].y

  let w = initWorld()
  component(w, Position)
  component(w, Velocity)

  system(w, mv, ecsOnUpdate, Position, Velocity)

  tag(w, Eats)
  tag(w, Apples)
  tag(w, Pears)

  let bob = newEntity(w, "Bob")
  set(w, bob, Position, Position(x: 0, y: 0))
  set(w, bob, Velocity, Velocity(x: 1, y: 2))
  addPair(w, bob, Eats, Apples)

  progress(w, 0)
  progress(w, 0)

  let p = get(w, bob, Position)
  echo &"Bob's position is: {{{p.x}, {p.y}}}"

  destroyWorld(w)

  # Output
  #  Move entities with [Position, Velocity, (Identifier,Name), (Eats,Apples)]
  #  Move entities with [Position, Velocity, (Identifier,Name), (Eats,Apples)]
  #  Bob's position is {2.0, 4.0}