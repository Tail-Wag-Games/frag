import std/[options, random, sequtils, times],
       tnt

proc isValid(candidate, sampleRegionSize: Vec2; cellSize, radius: float32; points: seq[Vec2]; grid: seq[seq[int32]]): bool =
  block outer:
    if candidate.x >= 0 and candidate.x < sampleRegionSize.x and candidate.y >= 0 and candidate.y < sampleRegionSize.y:
      let
        cellX = int(candidate.x / cellSize)
        cellY = int(candidate.y / cellSize)
        searchStartX = max(0, cellX - 2)
        searchEndX = min(cellX + 2, len(grid[0]) - 1)
        searchStartY = max(0, cellY - 2)
        searchEndY = min(cellY + 2, len(grid[1]) - 1)
      
      for x in searchStartX .. searchEndX:
        for y in searchStartY .. searchEndY:
          let pointIdx = grid[x][y] - 1
          if pointIdx != -1:
            let sqrDst = lengthSquaredVec2(subtractVec2(candidate, points[pointIdx]))
            if sqrDst < radius * radius:
              result = false
              break outer
      
      result = true
      break outer

    result = false

proc sample*(radius, width, height: float32;
    numSamplesBeforeRejection: int32 = 30; optRand: Option[Rand] = none[Rand]()): seq[Vec2] =
  var r = if isSome(optRand):
      get(optRand)
    else:
      let now = getTime()
      initRand(now.toUnix * 1_000_000_000 + now.nanosecond)

  let
    sampleRegionSize = vec2(width, height)
    cellSize = radius / sqrt(2.0)
  
  var
    spawnPoints = @[divideVec2f(sampleRegionSize, 2.0'f32)]
    grid = newSeqWith(int(ceil(sampleRegionSize.x / cellSize)), newSeq[int32](
        int(ceil(sampleRegionSize.y / cellSize))))
  while len(spawnPoints) > 0:
    let
      spawnIdx = rand(r, 0 .. len(spawnPoints) - 1)
      spawnCenter = spawnPoints[spawnIdx]
    
    var candidateAccepted = false
    for i in 0 ..< numSamplesBeforeRejection:
      let
        angle = rand(r, 0.0..1.0) * PI * 2
        dir = vec2(sin(angle), cos(angle))
        scale = rand[float64](r, 0.0..1.0) * radius + radius
        candidate = addVec2(spawnCenter, multiplyVec2f(dir, scale))
      
      if isValid(candidate, sampleRegionSize, cellSize, radius, result, grid):
        add(result, candidate)
        add(spawnPoints, candidate)
        grid[int(candidate.x / cellSize)][int(candidate.y / cellSize)] = int32(len(result))
        candidateAccepted = true
        break
    
    if not candidateAccepted:
      del(spawnPoints, spawnIdx)



  
