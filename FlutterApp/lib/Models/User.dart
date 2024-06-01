import 'dart:convert';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String role;
  final Location location;
  final String about;
  final String picPath;
  final int impressions;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.role,
    required this.location,
    required this.about,
    required this.picPath,
    required this.impressions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      location: Location.fromJson(json['location']),
      about: json['about'],
      picPath: json['picPath'],
      impressions: json['impressions'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'role': role,
      'location': location.toJson(),
      'about': about,
      'picPath': picPath,
      'impressions': impressions,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Location {
  final String state;
  final String city;
  final String pincode;

  Location({
    required this.state,
    required this.city,
    required this.pincode,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      state: json['state'],
      city: json['city'],
      pincode: json['pincode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'city': city,
      'pincode': pincode,
    };
  }
}
