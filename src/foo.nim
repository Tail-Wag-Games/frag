{.experimental: "codeReordering".}

import std/strformat,
       jolt, sokol/app as sapp, sokol/gfx as sgfx

type
  ObjLayers = object
    nonMoving: jolt.ObjectLayer = 0
    moving: jolt.ObjectLayer = 1
    len: uint32 = 2
  
  BroadPhaseLayers = object
    nonMoving: jolt.BroadPhaseLayer = 0
    moving: jolt.BroadPhaseLayer = 1
    len: uint32 = 2

  IBroadPhaseLayer {.byref.} = object
    vTbl: ptr jolt.BroadPhaseLayerInterfaceVTable
    objToBroadPhase: array[2, jolt.BroadPhaseLayer]
    padding: array[2, uint8]
  
  IBroadPhaseLayerFilter = object
    vTbl: ptr jolt.ObjectVsBroadPhaseLayerFilterVTable

  IObjectLayerFilter = object
    vTbl: ptr jolt.ObjectLayerPairFilterVTable
    
  PhysicsContext = object
    jobSystem: ptr jolt.JobSystem

    # iBroadPhaseLayer: IBroadPhaseLayer
    # iBroadPhaseLayerFilter: IBroadPhaseLayerFilter
    # iObjectLayerFilter: IObjectLayerFilter

    physicsSystem: ptr jolt.PhysicsSystem

const
  objLayers = ObjLayers()
  broadPhaseLayers = BroadPhaseLayers()

proc numBroadPhaseLayers(iSelf: pointer): uint32 {.cdecl.} =
  result = 2

proc broadPhaseLayer(iSelf: pointer; layer: ObjectLayer): jolt.BroadPhaseLayer {.cdecl.} =
  echo layer
  let self = cast[ptr IBroadPhaseLayer](iSelf)
  result = self.objToBroadPhase[layer]
  echo result
  echo "returning"

proc shouldCollideBroadPhaseObjectLayers(iSelf: pointer; layerOne: ObjectLayer; layerTwo: BroadPhaseLayer): bool {.cdecl.} =
  if layerOne == 0:
    result = layerTwo == 1
  elif layerOne == 1:
    result = true
  else:
    assert(false)
    result = false

proc shouldCollideObjectLayers(iSelf: pointer; layerOne: ObjectLayer; layerTwo: ObjectLayer): bool {.cdecl.} =
  if layerOne == 0:
    result = layerTwo == 1
  elif layerOne == 1:
    result = true
  else:
    assert(false)
    result = false 

var
  iBroadPhaseLayerVtbl = jolt.BroadPhaseLayerInterfaceVTable(
    GetNumBroadPhaseLayers: numBroadPhaseLayers,
    GetBroadPhaseLayer: broadPhaseLayer
  )

  iBroadPhaseLayerFilterVtbl = jolt.ObjectVsBroadPhaseLayerFilterVTable(
    ShouldCollide: shouldCollideBroadPhaseObjectLayers
  )

  iObjectLayerFilterVtbl = jolt.ObjectLayerPairFilterVTable(
    ShouldCollide: shouldCollideObjectLayers
  )

  maxBodies = 10240'u32
  numBodyMutexes = 0'u32
  maxBodyPairs = 1024'u32
  maxContactConstraints = 1024'u32

var
  ctx: PhysicsContext

proc maxConcurrency(): int32 {.cdecl.} =
  result = 2

proc physicsJobCallback(start, finish, threadIdx: int32;
    userData: pointer) {.cdecl.} =
  discard

proc createJob(inJobName: cstring; inColor: jolt.Color; inJobFunction: proc () {.cdecl.}; inNumDependencies: uint32): PhysicsJobHandle {.cdecl.} =
  # var j = coreApi.dispatchJob(1, )
  echo "creating job!"

proc freeJob(pj: ptr jolt.PhysicsJob) {.cdecl.} =
  # var j = coreApi.dispatchJob(1, )
  echo "freeing job!"

proc queueJob(pj: ptr jolt.PhysicsJob) {.cdecl.} =
  # var j = coreApi.dispatchJob(1, )
  echo "queueing job!"

proc queueJobs(pjs: ptr UncheckedArray[jolt.PhysicsJob]; numJobs: uint32) {.cdecl.} =
  # var j = coreApi.dispatchJob(1, )
  echo &"queueing {numJobs} jobs!"

proc init() =
  echo "size of IBroadPhaseLayer: ", sizeof(IBroadPhaseLayer)
  echo "size of pointer: ", sizeof(pointer)

  var jobSystemCallbacks = JobSystemCallbacks(
    max_concurrency: maxConcurrency,
    create_job: createJob,
    free_job: freeJob,
    queue_job: queueJob,
    queue_jobs: queueJobs
  )

  jolt.RegisterDefaultAllocator()
  jolt.CreateFactory()
  jolt.RegisterTypes()

  # ctx.jobSystem = jolt.JobSystem_Create(jolt.MAX_PHYSICS_BARRIERS.uint32)
  # jolt.JobSystem_SetCallbacks(ctx.jobSystem, addr(jobSystemCallbacks))
  
  var 
    iBroadPhaseLayer: IBroadPhaseLayer
    iBroadPhaseLayerFilter: IBroadPhaseLayerFilter
    iObjectLayerFilter: IObjectLayerFilter

  iBroadPhaseLayer.vTbl = addr(iBroadPhaseLayerVtbl)
  iBroadPhaseLayer.objToBroadPhase[0] = jolt.BroadPhaseLayer(0)
  iBroadPhaseLayer.objToBroadPhase[1] = jolt.BroadPhaseLayer(1)

  iBroadPhaseLayerFilter.vTbl = addr(iBroadPhaseLayerFilterVtbl)
  iObjectLayerFilter.vTbl = addr(iObjectLayerFilterVtbl)


  echo "creating physics system"
  ctx.physicsSystem = jolt.PhysicsSystem_Create(maxBodies, numBodyMutexes, maxBodyPairs, maxContactConstraints, addr(iBroadPhaseLayer), addr(iBroadPhaseLayerFilter), addr(iObjectLayerFilter))

  let
    iBody = PhysicsSystem_GetBodyInterface(ctx.physicsSystem)
    floorShapeSettings = BoxShapeSettings_Create([100.0'f32, 1.0'f32, 100.0'f32])
    floorShape = ShapeSettings_CreateShape(cast[ptr ShapeSettings](floorShapeSettings))

  var floorSettings: BodyCreationSettings
  BodyCreationSettings_Set(
    addr(floorSettings),
    floorShape,
    [0.0'f32, -1.0'f32, 0.0'f32],
    [0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32],
    MOTION_TYPE_STATIC,
    0
  )

  let floor = BodyInterface_CreateBody(iBody, addr(floorSettings))

when isMainModule:
  init()