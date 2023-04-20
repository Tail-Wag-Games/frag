discard """
enet is "Copyright (c) 2002-2012 Lee Salzman"
http://enet.bespin.org/ for more information.

This wrapper was written by one called Fowl, at
or around 2012. This work is released under the
MIT license:

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""
{.passC: "/IC:\\Users\\Zach\\dev\\frag\\thirdparty\\enet\\include".}

{.compile: "C:\\Users\\Zach\\dev\\frag\\thirdparty\\enet\\callbacks.c".}
{.compile: "C:\\Users\\Zach\\dev\\frag\\thirdparty\\enet\\compress.c".}
{.compile: "C:\\Users\\Zach\\dev\\frag\\thirdparty\\enet\\host.c".}
{.compile: "C:\\Users\\Zach\\dev\\frag\\thirdparty\\enet\\list.c".}
{.compile: "C:\\Users\\Zach\\dev\\frag\\thirdparty\\enet\\packet.c".}
{.compile: "C:\\Users\\Zach\\dev\\frag\\thirdparty\\enet\\peer.c".}
{.compile: "C:\\Users\\Zach\\dev\\frag\\thirdparty\\enet\\protocol.c".}

when defined(Linux):
  const Lib = "libenet.so(|.7)" #.1(|.0.3)"
elif defined(Windows):
  {.compile: "C:\\Users\\Zach\\dev\\frag\\thirdparty\\enet\\win32.c".}
  {.passL: "ws2_32.lib".}
  {.passL: "winmm.lib".}
else:
  {.error: "Your platform has not been accounted for.".}

{.deadCodeElim: on.}
const
  ENET_VERSION_MAJOR* = 1
  ENET_VERSION_MINOR* = 3
  ENET_VERSION_PATCH* = 3
template ENET_VERSION_CREATE(major, minor, patch: untyped): untyped =
  (((major) shl 16) or ((minor) shl 8) or (patch))

const
  ENET_VERSION* = ENET_VERSION_CREATE(ENET_VERSION_MAJOR, ENET_VERSION_MINOR,
                                      ENET_VERSION_PATCH)
type
  Version* = cuint
  SocketType*{.size: sizeof(cint).} = enum
    ENET_SOCKET_TYPE_STREAM = 1, ENET_SOCKET_TYPE_DATAGRAM = 2
  SocketWait*{.size: sizeof(cint).} = enum
    ENET_SOCKET_WAIT_NONE = 0, ENET_SOCKET_WAIT_SEND = (1 shl 0),
    ENET_SOCKET_WAIT_RECEIVE = (1 shl 1)
  SocketOption*{.size: sizeof(cint).} = enum
    ENET_SOCKOPT_NONBLOCK = 1, ENET_SOCKOPT_BROADCAST = 2,
    ENET_SOCKOPT_RCVBUF = 3, ENET_SOCKOPT_SNDBUF = 4,
    ENET_SOCKOPT_REUSEADDR = 5
const
  ENET_HOST_ANY* = 0
  ENET_HOST_BROADCAST* = 0xFFFFFFFF
  ENET_PORT_ANY* = 0

  ENET_PROTOCOL_MINIMUM_MTU* = 576
  ENET_PROTOCOL_MAXIMUM_MTU* = 4096
  ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS * = 32
  ENET_PROTOCOL_MINIMUM_WINDOW_SIZE* = 4096
  ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE* = 32768
  ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT* = 1
  ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT* = 255
  ENET_PROTOCOL_MAXIMUM_PEER_ID* = 0x00000FFF
type
  Address*{.pure, final.} = object
    host*: cuint
    port*: cushort

  PacketFlag*{.size: sizeof(cint).} = enum
    FlagReliable = (1 shl 0),
    FlagUnsequenced = (1 shl 1),
    NoAllocate = (1 shl 2),
    UnreliableFragment = (1 shl 3)

  ENetListNode*{.pure, final.} = object
    next*: ptr ENetListNode
    previous*: ptr ENetListNode

  ENetList*{.pure, final.} = object
    sentinel*: ENetListNode

  ENetPacket*{.pure, final.} = object
  PacketFreeCallback* = proc (a2: ptr ENetPacket){.cdecl.}

  Packet*{.pure, final.} = object
    referenceCount*: csize
    flags*: cint
    data*: cstring #ptr cuchar
    dataLength*: csize
    freeCallback*: PacketFreeCallback

  Acknowledgement*{.pure, final.} = object
    acknowledgementList*: EnetListNode
    sentTime*: cuint
    command*: EnetProtocol

  OutgoingCommand*{.pure, final.} = object
    outgoingCommandList*: EnetListNode
    reliableSequenceNumber*: cushort
    unreliableSequenceNumber*: cushort
    sentTime*: cuint
    roundTripTimeout*: cuint
    roundTripTimeoutLimit*: cuint
    fragmentOffset*: cuint
    fragmentLength*: cushort
    sendAttempts*: cushort
    command*: EnetProtocol
    packet*: Packet

  IncomingCommand*{.pure, final.} = object
    incomingCommandList*: EnetListNode
    reliableSequenceNumber*: cushort
    unreliableSequenceNumber*: cushort
    command*: EnetProtocol
    fragmentCount*: cuint
    fragmentsRemaining*: cuint
    fragments*: ptr cuint
    packet*: ptr Packet

  PeerState*{.size: sizeof(cint).} = enum
    ENET_PEER_STATE_DISCONNECTED = 0, ENET_PEER_STATE_CONNECTING = 1,
    ENET_PEER_STATE_ACKNOWLEDGING_CONNECT = 2,
    ENET_PEER_STATE_CONNECTION_PENDING = 3,
    ENET_PEER_STATE_CONNECTION_SUCCEEDED = 4, ENET_PEER_STATE_CONNECTED = 5,
    ENET_PEER_STATE_DISCONNECT_LATER = 6, ENET_PEER_STATE_DISCONNECTING = 7,
    ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT = 8, ENET_PEER_STATE_ZOMBIE = 9

  ENetProtocolCommand*{.size: sizeof(cint).} = enum
    ENET_PROTOCOL_COMMAND_NONE = 0, ENET_PROTOCOL_COMMAND_ACKNOWLEDGE = 1,
    ENET_PROTOCOL_COMMAND_CONNECT = 2,
    ENET_PROTOCOL_COMMAND_VERIFY_CONNECT = 3,
    ENET_PROTOCOL_COMMAND_DISCONNECT = 4, ENET_PROTOCOL_COMMAND_PING = 5,
    ENET_PROTOCOL_COMMAND_SEND_RELIABLE = 6,
    ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE = 7,
    ENET_PROTOCOL_COMMAND_SEND_FRAGMENT = 8,
    ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED = 9,
    ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT = 10,
    ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE = 11,
    ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT = 12,
    ENET_PROTOCOL_COMMAND_COUNT = 13, ENET_PROTOCOL_COMMAND_MASK = 0x0000000F
  ENetProtocolFlag*{.size: sizeof(cint).} = enum
    ENET_PROTOCOL_HEADER_SESSION_SHIFT = 12,
    ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED = (1 shl 6),
    ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE = (1 shl 7),
    ENET_PROTOCOL_HEADER_SESSION_MASK = (3 shl 12),
    ENET_PROTOCOL_HEADER_FLAG_COMPRESSED = (1 shl 14),
    ENET_PROTOCOL_HEADER_FLAG_SENT_TIME = (1 shl 15),
    ENET_PROTOCOL_HEADER_FLAG_MASK = ENET_PROTOCOL_HEADER_FLAG_COMPRESSED.cint or
        ENET_PROTOCOL_HEADER_FLAG_SENT_TIME.cint

  ENetProtocolHeader*{.pure, final.} = object
    peerID*: cushort
    sentTime*: cushort

  ENetProtocolCommandHeader*{.pure, final.} = object
    command*: cuchar
    channelID*: cuchar
    reliableSequenceNumber*: cushort

  ENetProtocolAcknowledge*{.pure, final.} = object
    header*: ENetProtocolCommandHeader
    receivedReliableSequenceNumber*: cushort
    receivedSentTime*: cushort

  ENetProtocolConnect*{.pure, final.} = object
    header*: ENetProtocolCommandHeader
    outgoingPeerID*: cushort
    incomingSessionID*: cuchar
    outgoingSessionID*: cuchar
    mtu*: cuint
    windowSize*: cuint
    channelCount*: cuint
    incomingBandwidth*: cuint
    outgoingBandwidth*: cuint
    packetThrottleInterval*: cuint
    packetThrottleAcceleration*: cuint
    packetThrottleDeceleration*: cuint
    connectID*: cuint
    data*: cuint

  ENetProtocolVerifyConnect*{.pure, final.} = object
    header*: ENetProtocolCommandHeader
    outgoingPeerID*: cushort
    incomingSessionID*: cuchar
    outgoingSessionID*: cuchar
    mtu*: cuint
    windowSize*: cuint
    channelCount*: cuint
    incomingBandwidth*: cuint
    outgoingBandwidth*: cuint
    packetThrottleInterval*: cuint
    packetThrottleAcceleration*: cuint
    packetThrottleDeceleration*: cuint
    connectID*: cuint

  ENetProtocolBandwidthLimit*{.pure, final.} = object
    header*: ENetProtocolCommandHeader
    incomingBandwidth*: cuint
    outgoingBandwidth*: cuint

  ENetProtocolThrottleConfigure*{.pure, final.} = object
    header*: ENetProtocolCommandHeader
    packetThrottleInterval*: cuint
    packetThrottleAcceleration*: cuint
    packetThrottleDeceleration*: cuint

  ENetProtocolDisconnect*{.pure, final.} = object
    header*: ENetProtocolCommandHeader
    data*: cuint

  ENetProtocolPing*{.pure, final.} = object
    header*: ENetProtocolCommandHeader

  ENetProtocolSendReliable*{.pure, final.} = object
    header*: ENetProtocolCommandHeader
    dataLength*: cushort

  ENetProtocolSendUnreliable*{.pure, final.} = object
    header*: ENetProtocolCommandHeader
    unreliableSequenceNumber*: cushort
    dataLength*: cushort

  ENetProtocolSendUnsequenced*{.pure, final.} = object
    header*: ENetProtocolCommandHeader
    unsequencedGroup*: cushort
    dataLength*: cushort

  ENetProtocolSendFragment*{.pure, final.} = object
    header*: ENetProtocolCommandHeader
    startSequenceNumber*: cushort
    dataLength*: cushort
    fragmentCount*: cuint
    fragmentNumber*: cuint
    totalLength*: cuint
    fragmentOffset*: cuint

  ## this is incomplete; need helper templates or something
  ## ENetProtocol
  ENetProtocol*{.pure, final.} = object
    header*: ENetProtocolCommandHeader
const
  ENET_BUFFER_MAXIMUM* = (1 + 2 * ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS)
  ENET_HOST_RECEIVE_BUFFER_SIZE = 256 * 1024
  ENET_HOST_SEND_BUFFER_SIZE = 256 * 1024
  ENET_HOST_BANDWIDTH_THROTTLE_INTERVAL = 1000
  ENET_HOST_DEFAULT_MTU = 1400

  ENET_PEER_DEFAULT_ROUND_TRIP_TIME = 500
  ENET_PEER_DEFAULT_PACKET_THROTTLE = 32
  ENET_PEER_PACKET_THROTTLE_SCALE = 32
  ENET_PEER_PACKET_THROTTLE_COUNTER = 7
  ENET_PEER_PACKET_THROTTLE_ACCELERATION = 2
  ENET_PEER_PACKET_THROTTLE_DECELERATION = 2
  ENET_PEER_PACKET_THROTTLE_INTERVAL = 5000
  ENET_PEER_PACKET_LOSS_SCALE = (1 shl 16)
  ENET_PEER_PACKET_LOSS_INTERVAL = 10000
  ENET_PEER_WINDOW_SIZE_SCALE = 64 * 1024
  ENET_PEER_TIMEOUT_LIMIT = 32
  ENET_PEER_TIMEOUT_MINIMUM = 5000
  ENET_PEER_TIMEOUT_MAXIMUM = 30000
  ENET_PEER_PING_INTERVAL = 500
  ENET_PEER_UNSEQUENCED_WINDOWS = 64
  ENET_PEER_UNSEQUENCED_WINDOW_SIZE = 1024
  ENET_PEER_FREE_UNSEQUENCED_WINDOWS = 32
  ENET_PEER_RELIABLE_WINDOWS = 16
  ENET_PEER_RELIABLE_WINDOW_SIZE = 0x1000
  ENET_PEER_FREE_RELIABLE_WINDOWS = 8

when defined(Linux):
  import posix
  const
    ENET_SOCKET_NULL*: cint = -1
  type
    ENetSocket* = cint
    ENetBuffer*{.pure, final.} = object
      data*: pointer
      dataLength*: csize
    ENetSocketSet* = Tfd_set
  ## see if these are different on win32, if not then get rid of these
  template ENET_HOST_TO_NET_16*(value: expr): expr =
    (htons(value))
  template ENET_HOST_TO_NET_32*(value: expr): expr =
    (htonl(value))
  template ENET_NET_TO_HOST_16*(value: expr): expr =
    (ntohs(value))
  template ENET_NET_TO_HOST_32*(value: expr): expr =
    (ntohl(value))

  template ENET_SOCKETSET_EMPTY*(sockset: expr): expr =
    FD_ZERO(addr((sockset)))
  template ENET_SOCKETSET_ADD*(sockset, socket: expr): expr =
    FD_SET(socket, addr((sockset)))
  template ENET_SOCKETSET_REMOVE*(sockset, socket: expr): expr =
    FD_CLEAR(socket, addr((sockset)))
  template ENET_SOCKETSET_CHECK*(sockset, socket: expr): expr =
    FD_ISSET(socket, addr((sockset)))

elif defined(Windows):
  ## put the content of win32.h in here
  import winlean
  let ENET_SOCKET_NULL*: cint = -1'i32
  type
    ENetSocket* = winlean.SocketHandle
    EnetBuffer* = object
      dataLength*: csize #these fields are flipped for win32, i'm sure theres a good reason for it
      data*: pointer
    ENetSocketSet* = Tfd_set

  template ENET_HOST_TO_NET_16*(value: untyped): untyped =
    (htons(value))
  template ENET_HOST_TO_NET_32*(value: untyped): untyped =
    (htonl(value))
  template ENET_NET_TO_HOST_16*(value: untyped): untyped =
    (ntohs(value))
  template ENET_NET_TO_HOST_32*(value: untyped): untyped =
    (ntohl(value))

  template ENET_SOCKETSET_EMPTY*(sockset: untyped): untyped =
    FD_ZERO(addr((sockset)))
  template ENET_SOCKETSET_ADD*(sockset, socket: untyped): untyped =
    FD_SET(socket, addr((sockset)))
  # FD_CLR not found in winlean?
  template ENET_SOCKETSET_REMOVE*(sockset, socket: untyped): untyped =
    FD_CLR(socket, addr((sockset)))
  template ENET_SOCKETSET_CHECK*(sockset, socket: untyped): untyped =
    FD_ISSET(socket, addr((sockset)))


type
  Channel*{.pure, final.} = object
    outgoingReliableSequenceNumber*: cushort
    outgoingUnreliableSequenceNumber*: cushort
    usedReliableWindows*: cushort
    reliableWindows*: array[0..ENET_PEER_RELIABLE_WINDOWS - 1, cushort]
    incomingReliableSequenceNumber*: cushort
    incomingUnreliableSequenceNumber*: cushort
    incomingReliableCommands*: ENetList
    incomingUnreliableCommands*: ENetList

  Peer*{.pure, final.} = object
    dispatchList*: EnetListNode
    host*: ptr Host
    outgoingPeerID*: cushort
    incomingPeerID*: cushort
    connectID*: cuint
    outgoingSessionID*: cuchar
    incomingSessionID*: cuchar
    address*: Address
    data*: pointer
    state*: PeerState
    channels*: ptr Channel
    channelCount*: csize
    incomingBandwidth*: cuint
    outgoingBandwidth*: cuint
    incomingBandwidthThrottleEpoch*: cuint
    outgoingBandwidthThrottleEpoch*: cuint
    incomingDataTotal*: cuint
    outgoingDataTotal*: cuint
    lastSendTime*: cuint
    lastReceiveTime*: cuint
    nextTimeout*: cuint
    earliestTimeout*: cuint
    packetLossEpoch*: cuint
    packetsSent*: cuint
    packetsLost*: cuint
    packetLoss*: cuint
    packetLossVariance*: cuint
    packetThrottle*: cuint
    packetThrottleLimit*: cuint
    packetThrottleCounter*: cuint
    packetThrottleEpoch*: cuint
    packetThrottleAcceleration*: cuint
    packetThrottleDeceleration*: cuint
    packetThrottleInterval*: cuint
    lastRoundTripTime*: cuint
    lowestRoundTripTime*: cuint
    lastRoundTripTimeVariance*: cuint
    highestRoundTripTimeVariance*: cuint
    roundTripTime*: cuint
    roundTripTimeVariance*: cuint
    mtu*: cuint
    windowSize*: cuint
    reliableDataInTransit*: cuint
    outgoingReliableSequenceNumber*: cushort
    acknowledgements*: ENetList
    sentReliableCommands*: ENetList
    sentUnreliableCommands*: ENetList
    outgoingReliableCommands*: ENetList
    outgoingUnreliableCommands*: ENetList
    dispatchedCommands*: ENetList
    needsDispatch*: cint
    incomingUnsequencedGroup*: cushort
    outgoingUnsequencedGroup*: cushort
    unsequencedWindow*: array[0..ENET_PEER_UNSEQUENCED_WINDOW_SIZE div 32 - 1,
                              cuint]
    eventData*: cuint

  Compressor*{.pure, final.} = object
    context*: pointer
    compress*: proc (context: pointer; inBuffers: ptr EnetBuffer;
                     inBufferCount: csize; inLimit: csize;
                     outData: ptr cuchar; outLimit: csize): csize{.cdecl.}
    decompress*: proc (context: pointer; inData: ptr cuchar; inLimit: csize;
                       outData: ptr cuchar; outLimit: csize): csize{.cdecl.}
    destroy*: proc (context: pointer){.cdecl.}

  ChecksumCallback* = proc (buffers: ptr EnetBuffer;
      bufferCount: csize): cuint{.
      cdecl.}

  Host*{.pure, final.} = object
    socket*: EnetSocket
    address*: Address
    incomingBandwidth*: cuint
    outgoingBandwidth*: cuint
    bandwidthThrottleEpoch*: cuint
    mtu*: cuint
    randomSeed*: cuint
    recalculateBandwidthLimits*: cint
    peers*: ptr Peer
    peerCount*: csize
    channelLimit*: csize
    serviceTime*: cuint
    dispatchQueue*: EnetList
    continueSending*: cint
    packetSize*: csize
    headerFlags*: cushort
    commands*: array[0..ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS - 1,
                     EnetProtocol]
    commandCount*: csize
    buffers*: array[0..ENET_BUFFER_MAXIMUM - 1, EnetBuffer]
    bufferCount*: csize
    checksum*: ChecksumCallback
    compressor*: Compressor
    packetData*: array[0..ENET_PROTOCOL_MAXIMUM_MTU - 1,
                       array[0..2 - 1, cuchar]]
    receivedAddress*: Address
    receivedData*: ptr cuchar
    receivedDataLength*: csize
    totalSentData*: cuint
    totalSentPackets*: cuint
    totalReceivedData*: cuint
    totalReceivedPackets*: cuint

  EventType*{.size: sizeof(cint).} = enum
    EvtNone = 0, EvtConnect = 1,
    EvtDisconnect = 2, EvtReceive = 3

  Event*{.pure, final.} = object
    kind*: EventType
    peer*: ptr Peer
    channelID*: int8
    data*: int32
    packet*: ptr Packet

  ENetCallbacks*{.pure, final.} = object
    malloc*: proc (size: csize): pointer{.cdecl.}
    free*: proc (memory: pointer){.cdecl.}
    no_memory*: proc (){.cdecl.}

{.pragma: ic, importc: "enet_$1".}
{.push cdecl.}
proc enet_malloc*(a2: csize): pointer{.
  importc: "enet_malloc".}
proc enet_free*(a2: pointer){.
  importc: "enet_free".}

proc initialize*: cint {.ic.}
proc initialize*(version: Version; inits: ptr EnetCallbacks): cint {.
  importc: "enet_initialize_with_callbacks".}
proc deinitialize* {.ic.}
proc time_get*: cuint {.ic.}
proc time_set*(time: cuint) {.ic.}

proc enetInit*(): cint{.deprecated,
  importc: "enet_initialize".}
proc enetInit*(version: Version; inits: ptr ENetCallbacks): cint{.deprecated,
  importc: "enet_initialize_with_callbacks".}
proc enetDeinit*(){.deprecated,
  importc: "enet_deinitialize".}
proc enet_time_get*(): cuint{.deprecated,
  importc: "enet_time_get".}
proc enet_time_set*(a2: cuint){.deprecated,
  importc: "enet_time_set".}

#enet docs are pretty lacking, i'm not sure what the names of these arguments should be
proc createSocket*(kind: SocketType): EnetSocket{.
  importc: "enet_socket_create".}


proc bindTo*(socket: EnetSocket; address: var Address): cint{.
  importc: "enet_socket_bind".}
proc bindTo*(socket: EnetSocket; address: ptr Address): cint{.
  importc: "enet_socket_bind".}
proc listen*(socket: EnetSocket; a3: cint): cint{.
  importc: "enet_socket_listen".}
proc accept*(socket: EnetSocket; address: var Address): EnetSocket{.
  importc: "enet_socket_accept".}
proc accept*(socket: EnetSocket; address: ptr Address): EnetSocket{.
  importc: "enet_socket_accept".}
proc connect*(socket: EnetSocket; address: var Address): cint{.
  importc: "enet_socket_connect".}
proc connect*(socket: EnetSocket; address: ptr Address): cint{.
  importc: "enet_socket_connect".}
proc send*(socket: EnetSocket; address: var Address; buffer: ptr EnetBuffer;
    size: csize): cint{.
  importc: "enet_socket_send".}
proc send*(socket: EnetSocket; address: ptr Address; buffer: ptr EnetBuffer;
    size: csize): cint{.
  importc: "enet_socket_send".}
proc receive*(socket: EnetSocket; address: var Address;
               buffer: ptr EnetBuffer; size: csize): cint{.
  importc: "enet_socket_receive".}
proc receive*(socket: EnetSocket; address: ptr Address;
               buffer: ptr EnetBuffer; size: csize): cint{.
  importc: "enet_socket_receive".}
proc wait*(socket: EnetSocket; a3: ptr cuint; a4: cuint): cint{.
  importc: "enet_socket_wait".}
proc setOption*(socket: EnetSocket; a3: SocketOption; a4: cint): cint{.
  importc: "enet_socket_set_option".}
proc destroy*(socket: EnetSocket){.
  importc: "enet_socket_destroy".}
proc select*(socket: EnetSocket; a3: ptr ENetSocketSet;
              a4: ptr ENetSocketSet; a5: cuint): cint{.
  importc: "enet_socketset_select".}

proc setHost*(address: ptr Address; hostName: cstring): cint{.
  importc: "enet_address_set_host", discardable.}
proc setHost*(address: var Address; hostName: cstring): cint{.
  importc: "enet_address_set_host", discardable.}
proc getHostIP*(address: var Address; hostName: cstring;
    nameLength: csize): cint{.
  importc: "enet_address_get_host_ip".}
proc getHost*(address: var Address; hostName: cstring;
    nameLength: csize): cint{.
  importc: "enet_address_get_host".}

## Call the above two funcs but trim the result string
proc getHostIP*(address: var Address; hostName: var string;
    nameLength: csize): cint{.inline.} =
  hostName.setLen nameLength
  result = getHostIP(address, cstring(hostName), nameLength)
  if result == 0:
    hostName.setLen(len(cstring(hostName)))
proc getHost*(address: var Address; hostName: var string;
    nameLength: csize): cint{.inline.} =
  hostName.setLen nameLength
  result = getHost(address, cstring(hostName), nameLength)
  if result == 0:
    hostName.setLen(len(cstring(hostName)))

converter toCINT*(some: PacketFlag): cint = some.cint

proc createPacket*(data: pointer; len: csize; flag: cint): ptr Packet{.
  importc: "enet_packet_create".}
proc createPacket*(data: string; flag: cint): ptr Packet {.
  inline.} = createPacket(data.cstring, data.len + 1, flag)

from macros import nestList, newCall, ident
macro shallowPacket*(data: pointer; len: int; flags: set[PacketFlag]): untyped =
  let flags_n = nestList(ident("or"), flags)
  result = newCall("enet.createPacket", data, len, flags_n)


proc destroy*(packet: ptr Packet){.
  importc: "enet_packet_destroy".}
proc resize*(packet: ptr Packet; dataLength: csize): cint{.
  importc: "enet_packet_resize".}

proc crc32*(buffers: ptr EnetBuffer; bufferCount: csize): cuint{.
  importc: "enet_crc32".}

proc createHost*(address: ptr Address; maxConnections, maxChannels: csize;
    downSpeed, upSpeed: cuint): ptr Host{.
  importc: "enet_host_create".}
proc createHost*(address: var Address; maxConnections, maxChannels: csize;
    downSpeed, upSpeed: cuint): ptr Host{.
  importc: "enet_host_create".}
proc destroy*(host: ptr Host){.
  importc: "enet_host_destroy".}
proc connect*(host: ptr Host; address: ptr Address; channelCount: csize;
    data: cuint): ptr Peer{.
  importc: "enet_host_connect".}
proc connect*(host: ptr Host; address: var Address; channelCount: csize;
    data: cuint): ptr Peer{.
  importc: "enet_host_connect".}

proc checkEvents*(host: ptr Host; event: var Event): cint{.
  importc: "enet_host_check_events".}
proc checkEvents*(host: ptr Host; event: ptr Event): cint{.
  importc: "enet_host_check_events".}
proc hostService*(host: ptr Host; event: var Event; timeout: cuint): cint{.
  importc: "enet_host_service".}
proc hostService*(host: ptr Host; event: ptr Event; timeout: cuint): cint{.
  importc: "enet_host_service".}
proc flush*(host: ptr Host){.
  importc: "enet_host_flush".}
proc broadcast*(host: ptr Host; channelID: cuchar; packet: ptr Packet){.
  importc: "enet_host_broadcast".}
proc compress*(host: ptr Host; compressor: ptr Compressor){.
  importc: "enet_host_compress".}
proc compressWithRangeCoder*(host: ptr Host): cint{.
  importc: "enet_host_compress_with_range_coder".}
proc channelLimit*(host: ptr Host; channelLimit: csize){.
  importc: "enet_host_channel_limit".}
proc bandwidthLimit*(host: ptr Host; incoming, outgoing: cuint){.
  importc: "enet_host_bandwidth_limit".}
proc bandwidthThrottle*(host: ptr Host){.
  importc: "enet_host_bandwidth_throttle".}


proc send*(peer: ptr Peer; channel: cuchar; packet: ptr Packet): cint{.
  importc: "enet_peer_send".}
proc receive*(peer: ptr Peer; channelID: ptr cuchar): ptr Packet{.
  importc: "enet_peer_receive".}
proc ping*(peer: ptr Peer){.
  importc: "enet_peer_ping".}
proc reset*(peer: ptr Peer){.
  importc: "enet_peer_reset".}
proc disconnect*(peer: ptr Peer; a3: cuint){.
  importc: "enet_peer_disconnect".}
proc disconnectNow*(peer: ptr Peer; a3: cuint){.
  importc: "enet_peer_disconnect_now".}
proc disconnectLater*(peer: ptr Peer; a3: cuint){.
  importc: "enet_peer_disconnect_later".}
proc throttleConfigure*(peer: ptr Peer; interval, acceleration,
    deceleration: cuint){.
  importc: "enet_peer_throttle_configure".}
proc throttle*(peer: ptr Peer; rtt: cuint): cint{.
  importc: "enet_peer_throttle".}
proc resetQueues*(peer: ptr Peer){.
  importc: "enet_peer_reset_queues".}
proc setupOutgoingCommand*(peer: ptr Peer; outgoingCommand: ptr OutgoingCommand){.
  importc: "enet_peer_setup_outgoing_command".}

proc queueOutgoingCommand*(peer: ptr Peer; command: ptr EnetProtocol;
          packet: ptr Packet; offset: cuint; length: cushort): ptr OutgoingCommand{.
  importc: "enet_peer_queue_outgoing_command".}
proc queueIncomingCommand*(peer: ptr Peer; command: ptr EnetProtocol;
                    packet: ptr Packet; fragmentCount: cuint): ptr IncomingCommand{.
  importc: "enet_peer_queue_incoming_command".}
proc queueAcknowledgement*(peer: ptr Peer; command: ptr EnetProtocol;
                            sentTime: cushort): ptr Acknowledgement{.
  importc: "enet_peer_queue_acknowledgement".}
proc dispatchIncomingUnreliableCommands*(peer: ptr Peer; channel: ptr Channel){.
  importc: "enet_peer_dispatch_incoming_unreliable_commands".}
proc dispatchIncomingReliableCommands*(peer: ptr Peer; channel: ptr Channel){.
  importc: "enet_peer_dispatch_incoming_reliable_commands".}

proc createRangeCoder*(): pointer{.
  importc: "enet_range_coder_create".}
proc rangeCoderDestroy*(context: pointer){.
  importc: "enet_range_coder_destroy".}
proc rangeCoderCompress*(context: pointer; inBuffers: ptr EnetBuffer; inLimit,
               bufferCount: csize; outData: cstring; outLimit: csize): csize{.
  importc: "enet_range_coder_compress".}
proc rangeCoderDecompress*(context: pointer; inData: cstring; inLimit: csize;
                            outData: cstring; outLimit: csize): csize{.
  importc: "enet_range_coder_decompress".}
proc protocolCommandSize*(commandNumber: cuchar): csize{.
  importc: "enet_protocol_command_size".}

{.pop.}

from hashes import `!$`, `!&`, Hash, hash
proc hash*(x: Address): Hash {.nimcall, noSideEffect.} =
  result = !$(hash(x.host.int32) !& hash(x.port.int16))
