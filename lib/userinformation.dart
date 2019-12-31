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
  UserDisplayDetails.fromJSON(Map udd) {
    this.dpUrl = udd['UserDetails']['photoUrl'];
    this.userEmail = udd['UserDetails']['userEmail'];
    this.userName = udd['UserDetails']['userName'];
  }
}