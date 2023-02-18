import std/[random, tables],
       tnt

type
  QuadtreeNode* = ref object
    bounds: AABBf
    mapTile: Vec2f
    children*: seq[QuadtreeNode]

  Quadtree* = ref object
    root: QuadtreeNode

proc newQuadtree*(root: QuadtreeNode): Quadtree =
  result = new(Quadtree)
  result.root = root

proc newQuadtreeNode*(bounds: AABBf): QuadtreeNode =
  result = new(QuadtreeNode)
  result.bounds = bounds

proc `mapTile=`*(node: QuadtreeNode; mapTile: Vec2f) =
  node.mapTile = mapTile

proc addChildren*(node: QuadTreeNode; children: varargs[QuadtreeNode]) =
  add(node.children, children)

proc intersects*(node: QuadtreeNode; ray: Ray; hit: var Vec3f; hitNode: var QuadtreeNode): bool =
  block outer:
    hit = vec3(float32.high)

    if len(node.children) == 0:
      var d: float32
      if not intersects(node.bounds, ray, d):
        hitNode = nil
        result = false
        break outer

      hit = (node.bounds.min + node.bounds.max ) / 2
      hitNode = node
      result = true
      break outer

    var childIntersections: OrderedTable[float32, QuadtreeNode]
    for bvhNode in node.children:
      var cd: float32
      if intersects(bvhNode.bounds, ray, cd):
        while contains(childIntersections, cd):
          cd += rand(-0.001'f32..0.001'f32)

        childIntersections[cd] = bvhNode
    
    sort(childIntersections, system.cmp)

    if len(childIntersections) == 0:
      hitNode = nil
      result = false
      break outer

    result = false

    var 
      bestHit= ray.origin + ray.direction * 1000
      bestHitNode: QuadtreeNode
    
    for d, bvhNode in childIntersections:
      var
        curHit: Vec3f
        curHitNode: QuadtreeNode

      let wasHit = intersects(bvhNode, ray, curHit, curHitNode)
      if not wasHit:
        continue

      let dot = dot(normalizeTo(curHit - ray.origin), ray.direction) 
      if not (dot > 0.9'f32):
        continue

      if not (lengthSquared(ray.origin - curHit) < lengthSquared(ray.origin - bestHit)):
        continue

      bestHit = curHit
      bestHitNode = curHitNode
      result = true
    
    hit = bestHit
    hitNode = bestHitNode

proc intersects*(qt: Quadtree; r: Ray; hit: var Vec3f; hitNode: var QuadtreeNode): bool =
  result = intersects(qt.root, r, hit, hitNode)