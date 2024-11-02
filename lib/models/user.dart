class User {
  String? id;
  final String fullName;
  String email;
  final String dateOfBirth;
  final String timeOfBirth;
  final String locationOfBirth;
  final String bloodGroup;
  final String sex;
  final String height;
  final String ethnicity;
  final String eyeColor;
  final String mothersMaidenName;
  final String childhoodFriend;
  final String childhoodPet;
  final String securityQuestion;

  User({
    this.id,
    required this.fullName,
    required this.email,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.locationOfBirth,
    required this.bloodGroup,
    required this.sex,
    required this.height,
    required this.ethnicity,
    required this.eyeColor,
    required this.mothersMaidenName,
    required this.childhoodFriend,
    required this.childhoodPet,
    required this.securityQuestion,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'dateOfBirth': dateOfBirth,
    'timeOfBirth': timeOfBirth,
    'locationOfBirth': locationOfBirth,
    'bloodGroup': bloodGroup,
    'sex': sex,
    'height': height,
    'ethnicity': ethnicity,
    'eyeColor': eyeColor,
    'mothersMaidenName': mothersMaidenName,
    'childhoodFriend': childhoodFriend,
    'childhoodPet': childhoodPet,
    'securityQuestion': securityQuestion,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    fullName: json['fullName'],
    email: json['email'],
    dateOfBirth: json['dateOfBirth'],
    timeOfBirth: json['timeOfBirth'],
    locationOfBirth: json['locationOfBirth'],
    bloodGroup: json['bloodGroup'],
    sex: json['sex'],
    height: json['height'],
    ethnicity: json['ethnicity'],
    eyeColor: json['eyeColor'],
    mothersMaidenName: json['mothersMaidenName'],
    childhoodFriend: json['childhoodFriend'],
    childhoodPet: json['childhoodPet'],
    securityQuestion: json['securityQuestion'],
  );
}
