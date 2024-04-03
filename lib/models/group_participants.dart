class GroupParticipants {
  String participantName;
  double amountExpended;

  GroupParticipants({
    required this.participantName,
    required this.amountExpended,
  });

  factory GroupParticipants.fromMap(Map<String, dynamic> json) {
    return GroupParticipants(
      participantName: json['participantName'],
      amountExpended: json['amountExpended'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "participantName": participantName,
      "amountExpended": amountExpended,
    };
  }
}
