{.experimental: "codeReordering".}

import std/strformat,
       jolt, sokol/app as sapp, sokol/gfx as sgfx,
       api, physics, tnt

const
  nonMovingLayer = 0'u8
  movingLayer = 1'u8
  numlayeers = 2'i32

  nonMovingBroadPhaseLayer = 0'u8
  movingBroadPhaseLayer = 1'u8
  numBroadPhaseLayers = 2'i32

proc getNumBroadPhaseLayersCb(self: ptr BroadPhaseLayerInterface): uint32 {.cdecl.} =
  result = 2

proc getBroadPhaseLayerCb(self: ptr BroadPhaseLayerInterface; layer: ObjectLayer): BroadPhaseLayer {.cdecl.} =
  result = BroadPhaseLayer(0)

proc getBroadPhaseLayerNameCb(iface: ptr BroadPhaseLayerInterface; layer: BroadPhaseLayer): cstring {.cdecl.} =
  result = "foo"

proc shouldCollideCb(filter: ptr ObjectVsBroadPhaseLayerFilter; layerOne: ObjectLayer; layerTwo: BroadPhaseLayer): Bool32 {.cdecl.} =
  case layerOne
  of nonMovingLayer:
    result = Bool32(layerTwo == movingLayer)
  of movingLayer:
    result = Bool32(true)
  else:
    assert(false)
    result = Bool32(false)

proc shouldObjectPairCollideCb(filter: ptr ObjectLayerPairFilter; objectOne, objectTwo: ObjectLayer): Bool32 {.cdecl.} =
  case objectOne
  of nonMovingLayer:
    result = Bool32(objectTwo == movingLayer)
  of movingLayer:
    result = Bool32(true)
  else:
    assert(false)
    result = Bool32(false)


var 
  bpliProcs = BroadPhaseLayerInterfaceProcs(
    getNumBroadPhaseLayers: getNumBroadPhaseLayersCb,
    getBroadPhaseLayer: getBroadPhaseLayerCb,
    getBroadPhaseLayerName: getBroadPhaseLayerNameCb
  )
  ovbplfProcs = ObjectVsBroadPhaseLayerFilterProcs(
    shouldCollide: shouldCollideCb
  )
  olpfProcs = ObjectLayerPairFilterProcs(
    shouldCollide: shouldObjectPairCollideCb
  )
  bodyInterface: ptr BodyInterface
  physicsSystem: ptr PhysicsSystem
  tmpAlloc: ptr TempAllocator
  jobSystem: ptr JobSystemThreadPool
  sphereId: BodyId


# type
#   ObjLayers = object
#     nonMoving: jolt.ObjectLayer = 0
#     moving: jolt.ObjectLayer = 1
#     len: uint32 = 2
  
#   BroadPhaseLayers = object
#     nonMoving: jolt.BroadPhaseLayer = 0
#     moving: jolt.BroadPhaseLayer = 1
#     len: uint32 = 2

#   IBroadPhaseLayer = object
#     vTbl: ptr jolt.BroadPhaseLayerInterfaceVTable
#     objToBroadPhase: array[2, jolt.BroadPhaseLayer]
  
#   IBroadPhaseLayerFilter = object
#     vTbl: ptr jolt.ObjectVsBroadPhaseLayerFilterVTable

#   IObjectLayerFilter = object
#     vTbl: ptr jolt.ObjectLayerPairFilterVTable
    
#   PhysicsContext = object
#     jobSystem: ptr jolt.JobSystem

#     # iBroadPhaseLayer: IBroadPhaseLayer
#     # iBroadPhaseLayerFilter: IBroadPhaseLayerFilter
#     # iObjectLayerFilter: IObjectLayerFilter

#     physicsSystem: ptr jolt.PhysicsSystem

# const
#   objLayers = ObjLayers()
#   broadPhaseLayers = BroadPhaseLayers()

# proc numBroadPhaseLayers(iSelf: pointer): uint32 {.cdecl.} =
#   result = 2

# proc broadPhaseLayer(iSelf: pointer; layer: ObjectLayer): jolt.BroadPhaseLayer {.cdecl.} =
#   echo layer
#   let self = cast[ptr IBroadPhaseLayer](iSelf)
#   result = self.objToBroadPhase[layer]
#   echo result
#   echo "returning"

# proc shouldCollideBroadPhaseObjectLayers(iSelf: pointer; layerOne: ObjectLayer; layerTwo: BroadPhaseLayer): bool {.cdecl.} =
#   if layerOne == 0:
#     result = layerTwo == 1
#   elif layerOne == 1:
#     result = true
#   else:
#     assert(false)
#     result = false

# proc shouldCollideObjectLayers(iSelf: pointer; layerOne: ObjectLayer; layerTwo: ObjectLayer): bool {.cdecl.} =
#   if layerOne == 0:
#     result = layerTwo == 1
#   elif layerOne == 1:
#     result = true
#   else:
#     assert(false)
#     result = false 

# var
#   iBroadPhaseLayerVtbl = jolt.BroadPhaseLayerInterfaceVTable(
#     GetNumBroadPhaseLayers: numBroadPhaseLayers,
#     GetBroadPhaseLayer: broadPhaseLayer
#   )

#   iBroadPhaseLayerFilterVtbl = jolt.ObjectVsBroadPhaseLayerFilterVTable(
#     ShouldCollide: shouldCollideBroadPhaseObjectLayers
#   )

#   iObjectLayerFilterVtbl = jolt.ObjectLayerPairFilterVTable(
#     ShouldCollide: shouldCollideObjectLayers
#   )

#   maxBodies = 10240'u32
#   numBodyMutexes = 0'u32
#   maxBodyPairs = 1024'u32
#   maxContactConstraints = 1024'u32

var
  # ctx {.fragState.}: PhysicsContext

  pluginApi {.fragState.}: ptr PluginApi
  coreApi {.fragState.}: ptr CoreApi

proc maxConcurrency(): int32 {.cdecl.} =
  result = coreApi.numJobThreads()

# proc physicsJobCallback(start, finish, threadIdx: int32;
#     userData: pointer) {.cdecl.} =
#   discard

# proc createJob(inJobName: cstring; inColor: jolt.Color; inJobFunction: proc () {.cdecl.}; inNumDependencies: uint32): PhysicsJobHandle {.cdecl.} =
#   # var j = coreApi.dispatchJob(1, )
#   echo "creating job!"

# proc freeJob(pj: ptr jolt.PhysicsJob) {.cdecl.} =
#   # var j = coreApi.dispatchJob(1, )
#   echo "freeing job!"

# proc queueJob(pj: ptr jolt.PhysicsJob) {.cdecl.} =
#   # var j = coreApi.dispatchJob(1, )
#   echo "queueing job!"

# proc queueJobs(pjs: ptr UncheckedArray[jolt.PhysicsJob]; numJobs: uint32) {.cdecl.} =
#   # var j = coreApi.dispatchJob(1, )
#   echo &"queueing {numJobs} jobs!"

proc init() =
  discard jolt.init()

  var
    floorHalfExtent = jolt.Vec3(x: 100.0'f32, y: 1.0'f32, z: 100.0'f32)
    floorPosition = jolt.Vec3(x: 0.0'f32, y: -1.0'f32, z: 0.0'f32)
    spherePosition = jolt.Vec3(x: 0.0'f32, y: 2.00'f32, z: 0.0'f32)
    linearVelocity = jolt.Vec3(x: 0.0, y: -5.0'f32, z: 0.0'f32)

  tmpAlloc = jolt.createTempAllocator(10 * 1024 * 1024)
  jobSystem = jolt.createJobSystemThreadPool(2048, 8, 0)

  let
    bpliImpl = jolt.createBroadPhaseLayerInterface()
    ovbphlfImpl = jolt.createObjectVsBroadPhaseLayerFilter()
    olpfImpl = jolt.createObjectLayerPairFilter()
        
  physicsSystem = jolt.createPhysicsSystem()
  jolt.setBroadPhaseLayerInterfaceProcs(bpliProcs)
  jolt.setObjectVsBroadPhaseLayerFilterProcs(ovbplfProcs)
  jolt.setObjectLayerPairFilterProcs(olpfProcs)
  jolt.initPhysicsSystem(physicsSystem, 1024, 0, 1024, 1024, bpliImpl, ovbphlfImpl, olpfImpl)
  bodyInterface = jolt.getBodyInterface(physicsSystem)

  let
    floorShapeSettings = jolt.createBoxShapeSettings(addr(floorHalfExtent))
    floorSettings = jolt.createBodyCreationSettings(cast[ptr ShapeSettings](floorShapeSettings), addr(floorPosition), unsafeAddr(identityQuat), mtStatic, nonMovingLayer)
    sphereSettings = jolt.createBodyCreationSettings(cast[ptr Shape](jolt.createSphereShape(0.5'f32)), addr(spherePosition), unsafeAddr(identityQuat), mtDynamic, movingLayer)
    floor = jolt.createBody(bodyInterface, floorSettings)
  
  jolt.addBody(bodyInterface, jolt.id(floor), amDontActivate)
  
  sphereId = jolt.createAndAddBody(bodyInterface, sphereSettings, amActivate)

  jolt.setLinearVelocity(bodyInterface, sphereId, addr(linearVelocity))


  # echo "size of IBroadPhaseLayer: ", sizeof(IBroadPhaseLayer)
  # echo "size of pointer: ", sizeof(pointer)

  # var jobSystemCallbacks = JobSystemCallbacks(
  #   max_concurrency: maxConcurrency,
  #   create_job: createJob,
  #   free_job: freeJob,
  #   queue_job: queueJob,
  #   queue_jobs: queueJobs
  # )

  # jolt.RegisterDefaultAllocator()
  # jolt.CreateFactory()
  # jolt.RegisterTypes()

  # # ctx.jobSystem = jolt.JobSystem_Create(jolt.MAX_PHYSICS_BARRIERS.uint32)
  # # jolt.JobSystem_SetCallbacks(ctx.jobSystem, addr(jobSystemCallbacks))
  
  # var 
  #   iBroadPhaseLayer: IBroadPhaseLayer
  #   iBroadPhaseLayerFilter: IBroadPhaseLayerFilter
  #   iObjectLayerFilter: IObjectLayerFilter

  # iBroadPhaseLayer.vTbl = addr(iBroadPhaseLayerVtbl)
  # iBroadPhaseLayer.objToBroadPhase[0] = jolt.BroadPhaseLayer(0)
  # iBroadPhaseLayer.objToBroadPhase[1] = jolt.BroadPhaseLayer(1)

  # iBroadPhaseLayerFilter.vTbl = addr(iBroadPhaseLayerFilterVtbl)
  # iObjectLayerFilter.vTbl = addr(iObjectLayerFilterVtbl)

  # ctx.physicsSystem = jolt.PhysicsSystem_Create(maxBodies, numBodyMutexes, maxBodyPairs, maxContactConstraints, addr(iBroadPhaseLayer), addr(iBroadPhaseLayerFilter), addr(iObjectLayerFilter))

  # let
  #   iBody = PhysicsSystem_GetBodyInterface(ctx.physicsSystem)
  #   floorShapeSettings = BoxShapeSettings_Create([100.0'f32, 1.0'f32, 100.0'f32])
  #   floorShape = ShapeSettings_CreateShape(cast[ptr ShapeSettings](floorShapeSettings))

  # var floorSettings: BodyCreationSettings
  # BodyCreationSettings_Set(
  #   addr(floorSettings),
  #   floorShape,
  #   [0.0'f32, -1.0'f32, 0.0'f32],
  #   [0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32],
  #   MOTION_TYPE_STATIC,
  #   0
  # )

  # let floor = BodyInterface_CreateBody(iBody, addr(floorSettings))


proc frame() =
  var
    velocity: jolt.Vec3
    position: jolt.RVec3
  
  jolt.getCenterOfMassPosition(bodyInterface, sphereId, addr(position))
  jolt.getLinearVelocity(bodyInterface, sphereId, addr(velocity))

  # echo "position: ", position
  # echo "velocity: ", velocity

  jolt.update(physicsSystem, 1.0'f32 / 60.0'f32, 1, 1, tmpAlloc, jobSystem)

proc fragPluginEventHandler(e: ptr sapp.Event) {.cdecl, exportc, dynlib.} =
  case e.`type`:
  of eventTypeSuspended:
    discard
  of eventTypeRestored:
    discard
  of eventTypeMouseDown:
    discard
  of eventTypeMouseUp:
    discard
  of eventTypeMouseLeave:
    discard
  of eventTypeMouseMove:
    discard
  else:
    discard

proc fragPlugin(plugin: ptr Plugin; operation: PluginOperation): int32 {.exportc,
    cdecl, dynlib.} =
  case operation:
  of poStep:
    frame()
  of poInit:
    pluginApi = plugin.api

    coreApi = cast[ptr CoreApi](pluginApi.getApi(atCore))

    init()

    pluginApi.injectApi("physics", 0, addr(physicsApi))
  else:
    discard

proc fragPluginInfo(info: ptr PluginInfo) {.cdecl, exportc, dynlib.} =
  info.name[0..31] = toOpenArray("physics", 0, 31)
  info.desc[0..255] = toOpenArray("physics plugin", 0, 255)

physicsApi = PhysicsApi(
  
)
