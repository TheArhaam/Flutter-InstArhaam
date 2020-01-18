class UserDetails {
  String providerDetails;
  String userName;
  String userEmail;
  String photoUrl;
  int posts;
  int followers;
  int following;
  List<ProviderDetails> providerData;

  UserDetails(this.providerDetails, this.userName, this.userEmail,
      this.providerData, this.photoUrl) {
    posts = followers = following = 0;
  }

  UserDetails.fromJSON(Map details) {
    this.userName = details['userName'];
    this.userEmail = details['userEmail'];
    this.photoUrl = details['photoUrl'];
    this.posts = int.parse(details['posts']);
    this.followers = int.parse(details['followers']);
    this.following = int.parse(details['following']);
  }

  getJson() {
    return {
      'userName': '${userName}',
      'userEmail': '${userEmail}',
      'photoUrl': '${photoUrl}',
      'posts': '${posts}',
      'followers': '${followers}',
      'following': '${following}',
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
  UserDisplayDetails(this.dpUrl, this.userEmail, this.userName);
  UserDisplayDetails.fromJSON(Map udd) {
    this.dpUrl = udd['UserDetails']['photoUrl'];
    this.userEmail = udd['UserDetails']['userEmail'];
    this.userName = udd['UserDetails']['userName'];
  }
}
