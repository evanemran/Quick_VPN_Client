class PacketDataPoint {
  final double time; // in seconds
  final double packetsIn;
  final double packetsOut;

  PacketDataPoint({
    required this.time,
    required this.packetsIn,
    required this.packetsOut,
  });
}
