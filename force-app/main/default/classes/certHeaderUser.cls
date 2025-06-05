public with sharing class certHeaderUser {

@AuraEnabled
public static user fetchUser(){

// query current user information

//

User oUser = [select id,Name,TimeZoneSidKey,Username, Alias,Country,Email,FirstName,LastName,IsActive

FROM User Where id =: userInfo.getUserId()];

return oUser;

}

}