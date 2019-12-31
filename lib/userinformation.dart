class UserDetails {
  final String providerDetails;
  final String userName;
  final String userEmail;
  final String photoUrl;
  final List<ProviderDetails> providerData;

  UserDetails(this.providerDetails, this.userName, this.userEmail,
      this.providerData, this.photoUrl);

  getJson() {
    return {
      'userName': '${userName}',
      'userEmail': '${userEmail}',
      'photoUrl': '${photoUrl}',
    };
    
  }
}

class ProviderDetails {
  final String providerDetails;
  ProviderDetails(this.providerDetails);
}

class UserDisplayDetails {
  String dpUrl;
  String userEmail;
  String userName;
  UserDisplayDetails(this.dpUrl, this.userEmail,this.userName);
<<<<<<< HEAD:lib/UserInformation.dart
  UserDisplayDetails.fromJSON(Map udd) {
    this.dpUrl = udd['UserDetails']['photoUrl'];
    this.userEmail = udd['UserDetails']['userEmail'];
    this.userName = udd['UserDetails']['userName'];
  }
}
=======
}
>>>>>>> ac1ee8c280a3f6a2b1cc956b6812e87cc1ee7d63:lib/userinformation.dart
