const
  AssetPoolSize* = 256
  MaxPath* = 256
  MaxPlugins* = 64

when defined(macosx):
  const NaturalAlignment* = 16
else:
  const NaturalAlignment* = 8