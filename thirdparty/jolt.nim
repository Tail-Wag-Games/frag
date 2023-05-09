{.passC: "/IC:\\Users\\Zach\\dev\\frag\\thirdparty\\JoltC".}
{.passC: "/std:c11".}
{.link: "jolt.lib".}

type
  Bool32* = uint32
  BodyId* = uint32
  SubShapeId* = uint32
  ObjectLayer* = uint16
  BroadPhaseLayer* = uint8

  MotionType* = distinct uint32
  ActivationMode* = distinct uint32
  ValidateResult* = distinct uint32
  ConstraintSpace* = distinct uint32

  Vec3* = object
    x*, y*, z*: float32

  RVec3* = object
    x*, y*, z*: float32

  Quat* = object
    x*, y*, z*, w*: float32

  TempAllocator* = object
  JobSystemThreadPool* = object
  JobSystemFibers* = object
  BroadPhaseLayerInterface* = object
  ObjectVsBroadPhaseLayerFilter* = object
  ObjectLayerPairFilter* = object
  PhysicsSystem* = object
  ShapeSettings* = object
  BoxShapeSettings* = object
  SphereShapeSettings* = object
  TriangleShapeSettings* = object
  CapsuleShapeSettings* = object
  CylinderShapeSettings* = object
  ConvexHullShapeSettings* = object
  MeshShapeSettings* = object

  Shape* = object
  ConvexShape* = object
  BoxShape* = object
  SphereShape* = object
  StaticCompoundShape* = object

  BodyCreationSettings* = object
  BodyInterface* = object
  Body* = object

const
  amActivate* = ActivationMode(0)
  amDontActivate* = ActivationMode(1)

  mtStatic* = MotionType(0)
  mtKinematic* = MotionType(1)
  mtDynamic* = MotionType(2)

  defaultConvexRadius = 0.05'f32
  identityQuat* = Quat(x: 0.0'f32, y: 0.0'f32, z: 0.0'f32, w: 1.0'f32)

proc init*(): Bool32 {.importc: "JPH_Init", cdecl.}
proc shutdown*() {.importc: "JPH_Shutdown", cdecl.}

proc mallocCreateTempAllocator*(): ptr TempAllocator {.importc: "JPH_TempAllocatorMalloc_Create", cdecl.}
proc createTempAllocator*(size: uint32): ptr TempAllocator {.importc: "JPH_TempAllocatorMalloc_Create", cdecl.}
proc destroyTempAllocator*(allocator: ptr TempAllocator) {.importc: "JPH_TempAllocator_Destroy", cdecl.}

proc createJobSystemThreadPool*(maxJobs, maxBarriers: uint32;
    numThreads: int32): ptr JobSystemThreadPool {.importc: "JPH_JobSystemThreadPool_Create", cdecl.}
proc destroyJobSystemThreadPool*(system: ptr JobSystemThreadPool) {.importc: "JPH_JobSystemThreadPool_Destroy", cdecl.}

type
  BroadPhaseLayerInterfaceProcs* = object
    getNumBroadPhaseLayers*: proc(iface: ptr BroadPhaseLayerInterface): uint32 {.cdecl.}
    getBroadPhaseLayer*: proc(iface: ptr BroadPhaseLayerInterface;
        layer: ObjectLayer): BroadPhaseLayer {.cdecl.}
    getBroadPhaseLayerName*: proc(iface: ptr BroadPhaseLayerInterface;
        layer: BroadPhaseLayer): cstring {.cdecl.}

proc createBroadPhaseLayerInterface*(): ptr BroadPhaseLayerInterface {.importc: "JPH_BroadPhaseLayerInterface_Create", cdecl.}
proc destroyBroadPhaseLayerInterface*(iface: ptr BroadPhaseLayerInterface) {.importc: "JPH_BroadPhaseLayerInterface_Destroy", cdecl.}
proc setBroadPhaseLayerInterfaceProcs*(procs: BroadPhaseLayerInterfaceProcs) {.importc: "JPH_BroadPhaseLayerInterface_SetProcs", cdecl.}

type
  ObjectVsBroadPhaseLayerFilterProcs* = object
    shouldCollide*: proc(filter: ptr ObjectVsBroadPhaseLayerFilter;
        layerOne: ObjectLayer; layerTwo: BroadPhaseLayer): Bool32 {.cdecl.}

proc createObjectVsBroadPhaseLayerFilter*(): ptr ObjectVsBroadPhaseLayerFilter {.importc: "JPH_ObjectVsBroadPhaseLayerFilter_Create", cdecl.}
proc destroyObjectVsBroadPhaseLayerFilter*(
  iface: ptr ObjectVsBroadPhaseLayerFilter) {.importc: "JPH_ObjectVsBroadPhaseLayerFilter_Destroy", cdecl.}
proc setObjectVsBroadPhaseLayerFilterProcs*(
  procs: ObjectVsBroadPhaseLayerFilterProcs) {.importc: "JPH_ObjectVsBroadPhaseLayerFilter_SetProcs", cdecl.}

type
  ObjectLayerPairFilterProcs* = object
    shouldCollide*: proc(filter: ptr ObjectLayerPairFilter;
        objectOne, objectTwo: ObjectLayer): Bool32 {.cdecl.}

proc createObjectLayerPairFilter*(): ptr ObjectLayerPairFilter {.importc: "JPH_ObjectLayerPairFilter_Create", cdecl.}
proc destroyObjectLayerPairFilter*(
  iface: ptr ObjectLayerPairFilter) {.importc: "JPH_ObjectLayerPairFilter_Destroy", cdecl.}
proc setObjectLayerPairFilterProcs*(
  procs: ObjectLayerPairFilterProcs) {.importc: "JPH_ObjectLayerPairFilter_SetProcs", cdecl.}

proc createPhysicsSystem*(): ptr PhysicsSystem {.importc: "JPH_PhysicsSystem_Create", cdecl.}
proc destroyPhysicsSystem*(system: ptr PhysicsSystem) {.importc: "JPH_PhysicsSystem_Destroy", cdecl.}
proc initPhysicsSystem*(system: ptr PhysicsSystem; maxBodies, numBodyMutexes,
    maxBodyPairs, maxContactConstraints: uint32;
        layer: ptr BroadPhaseLayerInterface;
    objectVsBroadPhaseLayerFilter: ptr ObjectVsBroadPhaseLayerFilter;
    objectLayerPairFilter: ptr ObjectLayerPairFilter) {.importc: "JPH_PhysicsSystem_Init", cdecl.}

proc update*(system: ptr PhysicsSystem; deltaTime: float32;
    collisionSteps: int32; integrationSubSteps: int32;
    tempAllocator: ptr TempAllocator;
    jobSystem: ptr JobSystemThreadPool) {.importc: "JPH_PhysicsSystem_Update", cdecl.}

proc getBodyInterface*(system: ptr PhysicsSystem): ptr BodyInterface {.importc: "JPH_PhysicsSystem_GetBodyInterface", cdecl.}

proc createBoxShapeSettings*(halfExtent: ptr Vec3;
    convexRadius: float32 = defaultConvexRadius): ptr BoxShapeSettings {.importc: "JPH_BoxShapeSettings_Create", cdecl.}

proc createSphereShape*(radius: float32): ptr SphereShape {.importc: "JPH_SphereShape_Create", cdecl.}

proc createBodyCreationSettings*(shapeSettings: ptr ShapeSettings;
    position: ptr Vec3; rotation: ptr Quat; motionType: MotionType;
    objectLayer: ObjectLayer): ptr BodyCreationSettings {.importc: "JPH_BodyCreationSettings_Create2", cdecl.}
proc createBodyCreationSettings*(shape: ptr Shape; position: ptr Vec3;
    rotation: ptr Quat; motionTyype: MotionType;
    objectLayer: ObjectLayer): ptr BodyCreationSettings {.importc: "JPH_BodyCreationSettings_Create3", cdecl.}

proc createAndAddBody*(iface: ptr BodyInterface;
    settings: ptr BodyCreationSettings;
    activationMode: ActivationMode): BodyId {.importc: "JPH_BodyInterface_CreateAndAddBody", cdecl.}
proc createBody*(iface: ptr BodyInterface;
    settings: ptr BodyCreationSettings): ptr Body {.importc: "JPH_BodyInterface_CreateBody", cdecl.}

proc addBody*(iface: ptr BodyInterface; bodyId: BodyId;
    activationMode: ActivationMode) {.importc: "JPH_BodyInterface_AddBody", cdecl.}

proc setLinearVelocity*(iface: ptr BodyInterface; bodyId: BodyId;
    velocity: ptr Vec3) {.importc: "JPH_BodyInterface_SetLinearVelocity", cdecl.}
proc getLinearVelocity*(iface: ptr BodyInterface; bodyId: BodyId;
    velocity: ptr Vec3) {.importc: "JPH_BodyInterface_GetLinearVelocity", cdecl.}
proc getCenterOfMassPosition*(iface: ptr BodyInterface; bodyId: BodyId;
    position: ptr RVec3) {.importc: "JPH_BodyInterface_GetCenterOfMassPosition", cdecl.}


proc id*(body: ptr Body): BodyId {.importc: "JPH_Body_GetID", cdecl.}
