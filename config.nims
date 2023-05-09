import std/strutils

task compileJolt, "compile jolt physics source":
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty\\JoltC /I.\\thirdparty /Fo.\\thirdparty\\JoltC\\JoltPhysicsC.o .\\thirdparty\\JoltC\\joltc.cpp"
  # exec "cl /std:c++17 /Zi /EHsc /D _ALLOW_KEYWORD_MACROS /c /I.\\thirdparty\\JoltC /I.\\thirdparty /Fo.\\thirdparty\\JoltC\\JoltPhysicsC_Extensions.o .\\thirdparty\\JoltC\\JoltPhysicsC_Extensions.cpp"
  # exec "cl /std:c11 /Zi /D _ALLOW_KEYWORD_MACROS /c /I.\\thirdparty\\JoltC /I.\\thirdparty /Fo.\\thirdparty\\JoltC\\JoltPhysicsC_Tests.o .\\thirdparty\\JoltC\\JoltPhysicsC_Tests.c"

  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\AABBTree\\AABBTreeBuilder.o .\\thirdparty\\Jolt\\AABBTree\\AABBTreeBuilder.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Core\\Color.o .\\thirdparty\\Jolt\\Core\\Color.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Core\\Factory.o .\\thirdparty\\Jolt\\Core\\Factory.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Core\\IssueReporting.o .\\thirdparty\\Jolt\\Core\\IssueReporting.cpp"
  # exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Core\\JobSystemFibers.o .\\thirdparty\\Jolt\\Core\\JobSystemFibers.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Core\\JobSystemThreadPool.o .\\thirdparty\\Jolt\\Core\\JobSystemThreadPool.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Core\\JobSystemWithBarrier.o .\\thirdparty\\Jolt\\Core\\JobSystemWithBarrier.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Core\\LinearCurve.o .\\thirdparty\\Jolt\\Core\\LinearCurve.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Core\\Memory.o .\\thirdparty\\Jolt\\Core\\Memory.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Core\\Profiler.o .\\thirdparty\\Jolt\\Core\\Profiler.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Core\\RTTI.o .\\thirdparty\\Jolt\\Core\\RTTI.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Core\\Semaphore.o .\\thirdparty\\Jolt\\Core\\Semaphore.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Core\\StringTools.o .\\thirdparty\\Jolt\\Core\\StringTools.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Core\\TickCounter.o .\\thirdparty\\Jolt\\Core\\TickCounter.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Geometry\\ConvexHullBuilder.o .\\thirdparty\\Jolt\\Geometry\\ConvexHullBuilder.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Geometry\\ConvexHullBuilder2D.o .\\thirdparty\\Jolt\\Geometry\\ConvexHullBuilder2D.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Geometry\\Indexify.o .\\thirdparty\\Jolt\\Geometry\\Indexify.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Geometry\\OrientedBox.o .\\thirdparty\\Jolt\\Geometry\\OrientedBox.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Math\\UVec4.o .\\thirdparty\\Jolt\\Math\\UVec4.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Math\\Vec3.o .\\thirdparty\\Jolt\\Math\\Vec3.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\ObjectStream\\ObjectStream.o .\\thirdparty\\Jolt\\ObjectStream\\ObjectStream.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamBinaryIn.o .\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamBinaryIn.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamBinaryOut.o .\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamBinaryOut.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamIn.o .\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamIn.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamOut.o .\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamOut.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamTextIn.o .\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamTextIn.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamTextOut.o .\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamTextOut.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\ObjectStream\\SerializableObject.o .\\thirdparty\\Jolt\\ObjectStream\\SerializableObject.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\ObjectStream\\TypeDeclarations.o .\\thirdparty\\Jolt\\ObjectStream\\TypeDeclarations.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Body\\Body.o .\\thirdparty\\Jolt\\Physics\\Body\\Body.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Body\\BodyAccess.o .\\thirdparty\\Jolt\\Physics\\Body\\BodyAccess.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Body\\BodyCreationSettings.o .\\thirdparty\\Jolt\\Physics\\Body\\BodyCreationSettings.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Body\\BodyInterface.o .\\thirdparty\\Jolt\\Physics\\Body\\BodyInterface.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Body\\BodyManager.o .\\thirdparty\\Jolt\\Physics\\Body\\BodyManager.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Body\\MassProperties.o .\\thirdparty\\Jolt\\Physics\\Body\\MassProperties.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Body\\MotionProperties.o .\\thirdparty\\Jolt\\Physics\\Body\\MotionProperties.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Character\\Character.o .\\thirdparty\\Jolt\\Physics\\Character\\Character.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Character\\CharacterBase.o .\\thirdparty\\Jolt\\Physics\\Character\\CharacterBase.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Character\\CharacterVirtual.o .\\thirdparty\\Jolt\\Physics\\Character\\CharacterVirtual.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\BroadPhase\\BroadPhase.o .\\thirdparty\\Jolt\\Physics\\Collision\\BroadPhase\\BroadPhase.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\BroadPhase\\BroadPhaseBruteForce.o .\\thirdparty\\Jolt\\Physics\\Collision\\BroadPhase\\BroadPhaseBruteForce.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\BroadPhase\\BroadPhaseQuadTree.o .\\thirdparty\\Jolt\\Physics\\Collision\\BroadPhase\\BroadPhaseQuadTree.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\BroadPhase\\QuadTree.o .\\thirdparty\\Jolt\\Physics\\Collision\\BroadPhase\\QuadTree.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\CastConvexVsTriangles.o .\\thirdparty\\Jolt\\Physics\\Collision\\CastConvexVsTriangles.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\CastSphereVsTriangles.o .\\thirdparty\\Jolt\\Physics\\Collision\\CastSphereVsTriangles.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\CollideConvexVsTriangles.o .\\thirdparty\\Jolt\\Physics\\Collision\\CollideConvexVsTriangles.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\CollideSphereVsTriangles.o .\\thirdparty\\Jolt\\Physics\\Collision\\CollideSphereVsTriangles.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\CollisionDispatch.o .\\thirdparty\\Jolt\\Physics\\Collision\\CollisionDispatch.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\CollisionGroup.o .\\thirdparty\\Jolt\\Physics\\Collision\\CollisionGroup.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\GroupFilter.o .\\thirdparty\\Jolt\\Physics\\Collision\\GroupFilter.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\GroupFilterTable.o .\\thirdparty\\Jolt\\Physics\\Collision\\GroupFilterTable.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\ManifoldBetweenTwoFaces.o .\\thirdparty\\Jolt\\Physics\\Collision\\ManifoldBetweenTwoFaces.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\NarrowPhaseQuery.o .\\thirdparty\\Jolt\\Physics\\Collision\\NarrowPhaseQuery.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\NarrowPhaseStats.o .\\thirdparty\\Jolt\\Physics\\Collision\\NarrowPhaseStats.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\PhysicsMaterial.o .\\thirdparty\\Jolt\\Physics\\Collision\\PhysicsMaterial.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\PhysicsMaterialSimple.o .\\thirdparty\\Jolt\\Physics\\Collision\\PhysicsMaterialSimple.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\BoxShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\BoxShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\CapsuleShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\CapsuleShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\CompoundShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\CompoundShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\ConvexHullShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\ConvexHullShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\ConvexShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\ConvexShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\CylinderShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\CylinderShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\DecoratedShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\DecoratedShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\HeightFieldShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\HeightFieldShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\MeshShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\MeshShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\MutableCompoundShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\MutableCompoundShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\OffsetCenterOfMassShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\OffsetCenterOfMassShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\RotatedTranslatedShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\RotatedTranslatedShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\ScaledShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\ScaledShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\Shape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\Shape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\SphereShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\SphereShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\StaticCompoundShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\StaticCompoundShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\TaperedCapsuleShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\TaperedCapsuleShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\TriangleShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\TriangleShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Collision\\TransformedShape.o .\\thirdparty\\Jolt\\Physics\\Collision\\TransformedShape.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\ConeConstraint.o .\\thirdparty\\Jolt\\Physics\\Constraints\\ConeConstraint.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\Constraint.o .\\thirdparty\\Jolt\\Physics\\Constraints\\Constraint.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\ConstraintManager.o .\\thirdparty\\Jolt\\Physics\\Constraints\\ConstraintManager.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\ContactConstraintManager.o .\\thirdparty\\Jolt\\Physics\\Constraints\\ContactConstraintManager.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\DistanceConstraint.o .\\thirdparty\\Jolt\\Physics\\Constraints\\DistanceConstraint.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\FixedConstraint.o .\\thirdparty\\Jolt\\Physics\\Constraints\\FixedConstraint.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\GearConstraint.o .\\thirdparty\\Jolt\\Physics\\Constraints\\GearConstraint.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\HingeConstraint.o .\\thirdparty\\Jolt\\Physics\\Constraints\\HingeConstraint.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\MotorSettings.o .\\thirdparty\\Jolt\\Physics\\Constraints\\MotorSettings.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\PathConstraint.o .\\thirdparty\\Jolt\\Physics\\Constraints\\PathConstraint.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\PathConstraintPath.o .\\thirdparty\\Jolt\\Physics\\Constraints\\PathConstraintPath.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\PathConstraintPathHermite.o .\\thirdparty\\Jolt\\Physics\\Constraints\\PathConstraintPathHermite.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\PointConstraint.o .\\thirdparty\\Jolt\\Physics\\Constraints\\PointConstraint.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\RackAndPinionConstraint.o .\\thirdparty\\Jolt\\Physics\\Constraints\\RackAndPinionConstraint.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\SixDOFConstraint.o .\\thirdparty\\Jolt\\Physics\\Constraints\\SixDOFConstraint.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\SliderConstraint.o .\\thirdparty\\Jolt\\Physics\\Constraints\\SliderConstraint.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\SwingTwistConstraint.o .\\thirdparty\\Jolt\\Physics\\Constraints\\SwingTwistConstraint.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\TwoBodyConstraint.o .\\thirdparty\\Jolt\\Physics\\Constraints\\TwoBodyConstraint.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Constraints\\PulleyConstraint.o .\\thirdparty\\Jolt\\Physics\\Constraints\\PulleyConstraint.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\DeterminismLog.o .\\thirdparty\\Jolt\\Physics\\DeterminismLog.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\IslandBuilder.o .\\thirdparty\\Jolt\\Physics\\IslandBuilder.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\LargeIslandSplitter.o .\\thirdparty\\Jolt\\Physics\\LargeIslandSplitter.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\PhysicsLock.o .\\thirdparty\\Jolt\\Physics\\PhysicsLock.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\PhysicsScene.o .\\thirdparty\\Jolt\\Physics\\PhysicsScene.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\PhysicsSystem.o .\\thirdparty\\Jolt\\Physics\\PhysicsSystem.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\PhysicsUpdateContext.o .\\thirdparty\\Jolt\\Physics\\PhysicsUpdateContext.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Ragdoll\\Ragdoll.o .\\thirdparty\\Jolt\\Physics\\Ragdoll\\Ragdoll.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\StateRecorderImpl.o .\\thirdparty\\Jolt\\Physics\\StateRecorderImpl.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Vehicle\\TrackedVehicleController.o .\\thirdparty\\Jolt\\Physics\\Vehicle\\TrackedVehicleController.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleAntiRollBar.o .\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleAntiRollBar.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleCollisionTester.o .\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleCollisionTester.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleConstraint.o .\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleConstraint.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleController.o .\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleController.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleDifferential.o .\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleDifferential.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleEngine.o .\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleEngine.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleTrack.o .\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleTrack.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleTransmission.o .\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleTransmission.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Vehicle\\Wheel.o .\\thirdparty\\Jolt\\Physics\\Vehicle\\Wheel.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Physics\\Vehicle\\WheeledVehicleController.o .\\thirdparty\\Jolt\\Physics\\Vehicle\\WheeledVehicleController.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\RegisterTypes.o .\\thirdparty\\Jolt\\RegisterTypes.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Renderer\\DebugRenderer.o .\\thirdparty\\Jolt\\Renderer\\DebugRenderer.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Renderer\\DebugRendererPlayback.o .\\thirdparty\\Jolt\\Renderer\\DebugRendererPlayback.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Renderer\\DebugRendererRecorder.o .\\thirdparty\\Jolt\\Renderer\\DebugRendererRecorder.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Skeleton\\SkeletalAnimation.o .\\thirdparty\\Jolt\\Skeleton\\SkeletalAnimation.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Skeleton\\Skeleton.o .\\thirdparty\\Jolt\\Skeleton\\Skeleton.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Skeleton\\SkeletonMapper.o .\\thirdparty\\Jolt\\Skeleton\\SkeletonMapper.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\Skeleton\\SkeletonPose.o .\\thirdparty\\Jolt\\Skeleton\\SkeletonPose.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\TriangleGrouper\\TriangleGrouperClosestCentroid.o .\\thirdparty\\Jolt\\TriangleGrouper\\TriangleGrouperClosestCentroid.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\TriangleGrouper\\TriangleGrouperMorton.o .\\thirdparty\\Jolt\\TriangleGrouper\\TriangleGrouperMorton.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitter.o .\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitter.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitterBinning.o .\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitterBinning.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitterFixedLeafSize.o .\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitterFixedLeafSize.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitterLongestAxis.o .\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitterLongestAxis.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitterMean.o .\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitterMean.cpp"
  exec "cl /std:c++17 /Zi /EHsc /c /I.\\thirdparty /Fo.\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitterMorton.o .\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitterMorton.cpp"

task linkJolt, "link jolt physics library":
  exec """
  lib /out:.\\thirdparty\\jolt.lib
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\JoltC\\JoltPhysicsC.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\AABBTree\\AABBTreeBuilder.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Core\\Color.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Core\\Factory.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Core\\IssueReporting.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Core\\JobSystemThreadPool.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Core\\JobSystemWithBarrier.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Core\\LinearCurve.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Core\\Memory.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Core\\Profiler.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Core\\RTTI.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Core\\Semaphore.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Core\\StringTools.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Core\\TickCounter.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Geometry\\ConvexHullBuilder.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Geometry\\ConvexHullBuilder2D.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Geometry\\Indexify.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Geometry\\OrientedBox.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Math\\UVec4.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Math\\Vec3.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\ObjectStream\\ObjectStream.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamBinaryIn.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamBinaryOut.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamIn.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamOut.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamTextIn.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\ObjectStream\\ObjectStreamTextOut.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\ObjectStream\\SerializableObject.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\ObjectStream\\TypeDeclarations.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Body\\Body.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Body\\BodyAccess.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Body\\BodyCreationSettings.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Body\\BodyInterface.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Body\\BodyManager.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Body\\MassProperties.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Body\\MotionProperties.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Character\\Character.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Character\\CharacterBase.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Character\\CharacterVirtual.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\BroadPhase\\BroadPhase.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\BroadPhase\\BroadPhaseBruteForce.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\BroadPhase\\BroadPhaseQuadTree.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\BroadPhase\\QuadTree.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\CastConvexVsTriangles.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\CastSphereVsTriangles.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\CollideConvexVsTriangles.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\CollideSphereVsTriangles.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\CollisionDispatch.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\CollisionGroup.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\GroupFilter.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\GroupFilterTable.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\ManifoldBetweenTwoFaces.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\NarrowPhaseQuery.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\NarrowPhaseStats.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\PhysicsMaterial.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\PhysicsMaterialSimple.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\BoxShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\CapsuleShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\CompoundShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\ConvexHullShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\ConvexShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\CylinderShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\DecoratedShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\HeightFieldShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\MeshShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\MutableCompoundShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\OffsetCenterOfMassShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\RotatedTranslatedShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\ScaledShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\Shape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\SphereShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\StaticCompoundShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\TaperedCapsuleShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\Shape\\TriangleShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Collision\\TransformedShape.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\ConeConstraint.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\Constraint.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\ConstraintManager.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\ContactConstraintManager.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\DistanceConstraint.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\FixedConstraint.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\GearConstraint.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\HingeConstraint.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\MotorSettings.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\PathConstraint.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\PathConstraintPath.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\PathConstraintPathHermite.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\PointConstraint.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\RackAndPinionConstraint.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\SixDOFConstraint.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\SliderConstraint.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\SwingTwistConstraint.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\TwoBodyConstraint.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Constraints\\PulleyConstraint.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\DeterminismLog.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\IslandBuilder.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\LargeIslandSplitter.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\PhysicsLock.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\PhysicsScene.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\PhysicsSystem.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\PhysicsUpdateContext.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Ragdoll\\Ragdoll.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\StateRecorderImpl.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Vehicle\\TrackedVehicleController.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleAntiRollBar.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleCollisionTester.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleConstraint.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleController.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleDifferential.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleEngine.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleTrack.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Vehicle\\VehicleTransmission.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Vehicle\\Wheel.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Physics\\Vehicle\\WheeledVehicleController.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\RegisterTypes.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Renderer\\DebugRenderer.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Renderer\\DebugRendererPlayback.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Renderer\\DebugRendererRecorder.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Skeleton\\SkeletalAnimation.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Skeleton\\Skeleton.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Skeleton\\SkeletonMapper.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\Skeleton\\SkeletonPose.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\TriangleGrouper\\TriangleGrouperClosestCentroid.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\TriangleGrouper\\TriangleGrouperMorton.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitter.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitterBinning.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitterFixedLeafSize.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitterLongestAxis.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitterMean.o
  C:\\Users\\Zach\\dev\\frag\\thirdparty\\Jolt\\TriangleSplitter\\TriangleSplitterMorton.o
  """.unindent().replace("\n", " ")

task build, "build frag executable":
  exec "cl /c /I.\\thirdparty\\cr /Fo.\\thirdparty\\cr.o .\\thirdparty\\cr.cpp"
  exec "lib /out:.\\thirdparty\\cr.lib C:\\Users\\Zach\\dev\\frag\\thirdparty\\cr.o"

  exec "nim compileJolt"
  exec "nim linkJolt"
  
  when defined(macosx):
    exec "cc -O0 -ffunction-sections -fdata-sections -m64 -fPIC  -DBOOST_CONTEXT_EXPORT= -I./src/fragpkg/asm -o ./src/fragpkg/asm/make_combined_all_macho_gas.S.o -c ./src/fragpkg/asm/make_combined_all_macho_gas.S"
    exec "cc -O0 -ffunction-sections -fdata-sections -m64 -fPIC  -DBOOST_CONTEXT_EXPORT= -I./src/fragpkg/asm -o ./src/fragpkg/asm/jump_combined_all_macho_gas.S.o -c ./src/fragpkg/asm/jump_combined_all_macho_gas.S"
    exec "cc -O0 -ffunction-sections -fdata-sections -m64 -fPIC  -DBOOST_CONTEXT_EXPORT= -I./src/fragpkg/asm -o ./src/fragpkg/asm/ontop_combined_all_macho_gas.S.o -c ./src/fragpkg/asm/ontop_combined_all_macho_gas.S"
  elif defined(windows):
    exec "\"C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\MSVC\\14.30.30705\\bin\\Hostx64\\x64\\ml64.exe\" /nologo /c /Fo./src/asm/make_x86_64_ms_pe_masm.obj /I./src/asm /DBOOST_CONTEXT_EXPORT= ./src/asm/make_x86_64_ms_pe_masm.asm"
    exec "\"C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\MSVC\\14.30.30705\\bin\\Hostx64\\x64\\ml64.exe\" /nologo /c /Fo./src/asm/jump_x86_64_ms_pe_masm.obj /I./src/asm /DBOOST_CONTEXT_EXPORT= ./src/asm/jump_x86_64_ms_pe_masm.asm"
    exec "\"C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\MSVC\\14.30.30705\\bin\\Hostx64\\x64\\ml64.exe\" /nologo /c /Fo./src/asm/ontop_x86_64_ms_pe_masm.obj /I./src/asm /DBOOST_CONTEXT_EXPORT= ./src/asm/ontop_x86_64_ms_pe_masm.asm"
  else:
    echo "platform not supported"

task debugBuild, "build frag executable with debug symbols":
  exec "cl /c /Zi /I.\\thirdparty\\cr /Fd.\\thirdparty\\cr.pdb /Fo.\\thirdparty\\crd.o .\\thirdparty\\cr.cpp"
  exec "lib /out:.\\thirdparty\\crd.lib C:\\Users\\Zach\\dev\\frag\\thirdparty\\crd.o"

  # exec "nim compileDebugJolt"
  # exec "nim linkDebugJolt"

  when defined(macosx):
    exec "cc -O0 -ffunction-sections -fdata-sections -g -m64 -fPIC  -DBOOST_CONTEXT_EXPORT= -I./src/fragpkg/asm -o ./src/fragpkg/asm/make_combined_all_macho_gas.S.o -c ./src/fragpkg/asm/make_combined_all_macho_gas.S"
    exec "cc -O0 -ffunction-sections -fdata-sections -g -m64 -fPIC  -DBOOST_CONTEXT_EXPORT= -I./src/fragpkg/asm -o ./src/fragpkg/asm/jump_combined_all_macho_gas.S.o -c ./src/fragpkg/asm/jump_combined_all_macho_gas.S"
    exec "cc -O0 -ffunction-sections -fdata-sections -g -m64 -fPIC  -DBOOST_CONTEXT_EXPORT= -I./src/fragpkg/asm -o ./src/fragpkg/asm/ontop_combined_all_macho_gas.S.o -c ./src/fragpkg/asm/ontop_combined_all_macho_gas.S"
  elif defined(windows):
    exec "\"C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\MSVC\\14.30.30705\\bin\\Hostx64\\x64\\ml64.exe\" /nologo /c /Fo./src/asm/make_x86_64_ms_pe_masm.obj /Zd /Zi /DEBUG /I./src/asm /DBOOST_CONTEXT_EXPORT= ./src/asm/make_x86_64_ms_pe_masm.asm"
    exec "\"C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\MSVC\\14.30.30705\\bin\\Hostx64\\x64\\ml64.exe\" /nologo /c /Fo./src/asm/jump_x86_64_ms_pe_masm.obj /Zd /Zi /DEBUG /I./src/asm /DBOOST_CONTEXT_EXPORT= ./src/asm/jump_x86_64_ms_pe_masm.asm"
    exec "\"C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Tools\\MSVC\\14.30.30705\\bin\\Hostx64\\x64\\ml64.exe\" /nologo /c /Fo./src/asm/ontop_x86_64_ms_pe_masm.obj /Zd /Zi /DEBUG /I./src/asm /DBOOST_CONTEXT_EXPORT= ./src/asm/ontop_x86_64_ms_pe_masm.asm"
  else:
    echo "platform not supported"

task compileShaders, "compile shaders":
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --cvar=basic -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\basic.nim --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\basic.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\basic.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --cvar=box -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\box.nim --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\box.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\box.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --cvar=wire -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\wire.nim --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\wire.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\wire.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -g -r -l hlsl --cvar=terrain -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain.nim --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\heightmap_terrain.sgs --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\heightmap_terrain.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\heightmap_terrain.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_init.sgs --compute=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_init.comp"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update.sgs --compute=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update.comp"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update_draw.sgs --compute=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update_draw.comp"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update_merge.sgs --compute=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update_merge.comp"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update_split.sgs --compute=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\leb_update_split.comp"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\cbt_sum_reduction.sgs --compute=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\cbt_sum_reduction.comp"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\cbt_sum_reduction_prepass.sgs --compute=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\cbt_sum_reduction_prepass.comp"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.hlsl --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --sgs -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.sgs --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --cvar=terrainRender -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.nim --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\terrain_render.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --cvar=offscreen -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\offscreen.nim --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\viewer.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\viewer.frag"
  exec "C:\\Users\\Zach\\dev\\frag\\thirdparty\\glslcc\\.build\\src\\Debug\\glslcc.exe -r -l hlsl --cvar=nuklear -o C:\\Users\\Zach\\dev\\frag\\src\\shaders\\nuklear.nim --vert=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\nuklear.vert --frag=C:\\Users\\Zach\\dev\\frag\\src\\shaders\\nuklear.frag"

task buildImguiPlugin, "build imgui plugin":
  exec "nim c --debugger:native --threads:on --app:lib --out:imgui.dll .\\src\\imgui_plugin.nim"

task buildPhysicsPlugin, "build physics plugin":
  exec "nim c --debugger:native --threads:on --app:lib --out:physics.dll .\\src\\physics_plugin.nim"

task build3dPlugin, "build 3d plugin":
  exec "nim c --debugger:native --threads:on --app:lib --out:three_d.dll .\\src\\three_d_plugin.nim"

task buildTerrainPlugin, "build terrain plugin":
  exec "nim c --debugger:native --threads:on --app:lib --out:terrain.dll .\\src\\terrain_plugin.nim"

task buildPlugins, "build plugins":
  exec "nim build3dPlugin"
  # exec "nim buildTerrainPlugin"
  exec "nim buildImguiPlugin"
  exec "nim buildPhysicsPlugin"