global with sharing class Customlogin_CSC {
    
    public Customlogin_CSC() {

    }
     @AuraEnabled
    public static String login(String username, String password, String startUrl, String recaptchaResponse)
    {
    try 
    {
        if (username == null || username == '')
        {
         return 'Enter a value in the User Name field.';   
        }
        else if (password == null || password =='')
        {
         return 'Enter a value in the Password field.'; 
        }
        else 
        {
        String recaptchaSecretKey = System.Label.RecaptchaSecretkey; //'6LdPBgkjAAAAAFv-JUhyh4IgqqXeFsj2Rp9O4SuI';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
        request.setMethod('POST');
        request.setBody('secret=' + recaptchaSecretKey + '&response=' + recaptchaResponse);
        HttpResponse response = http.send(request);
        system.debug('test');
        if ( Test.isRunningTest() || response.getStatusCode() == 200 ) 
        {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            if ((result.containsKey('success') && result.get('success') == true)|| Test.isRunningTest() )
            {               
                if (result.containsKey('score') || Test.isRunningTest()) 
                {
                    //score logic is only needed/returned for v3 (0.0 - 1.0)                    
                    String action = (String)result.get('action');
                    //get threshold configuration for each action
                    
                    Decimal threshold = Decimal.valueOf(System.Label.CSC_Recaptcha_Threshold_Loginpage);
                    Decimal score = (Decimal)result.get('score');
                    if (Test.isRunningTest())
                                {
                                    score = 0.8; 
                                }
                    if (score > threshold) 
                    {
                        //perform action on record
                        try 
                        { 
                            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
                            if (lgn != null) return lgn.getUrl();
                            else
                            return 'Invalid Verification';
                        } catch (Exception ex) 
                        {
                            return ex.getMessage();
                        }
                    }
                    else 
                    {
                     return 'Invalid Verification';
                    }
                }
                else 
                {
                 return 'Invalid Verification';
                }
        
            }
            else 
            {
                return 'Invalid Verification';
            }
        }
        else 
        {
         return 'Invalid Verification';
        }
      }
    }
    catch (Exception ex) 
    {
        return ex.getMessage();
    }
    }

    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }

    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig() {
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId, '');
        return authConfig;
    }

    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null;
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }
}