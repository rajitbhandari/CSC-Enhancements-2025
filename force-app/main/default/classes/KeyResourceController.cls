public with sharing class KeyResourceController {
    
    @AuraEnabled
    public static List<TopArticle> getKeyResourceConfig(){
      
        List<TopArticle> taResponse= new List<TopArticle>();
        
        List<Key_Resources_Config__mdt>  configcmdt =[SELECT KA_URL__c, Title__c,Sort_Order__c
                                FROM Key_Resources_Config__mdt
                                ORDER BY Sort_Order__c ASC NULLS LAST];
        
        for(Key_Resources_Config__mdt config: configcmdt){
            TopArticle ta = new TopArticle();
            ta.ka_Title= config.Title__c;
            ta.ka_URL= config.KA_URL__c;
            ta.ka_sortOrder= String.valueOf(config.Sort_Order__c);
            taResponse.add(ta); 
        }
        
        return taResponse;
    }
    
    public class TopArticle{
       
        @AuraEnabled public String ka_URL;
        @AuraEnabled public String ka_Title; 
        @AuraEnabled public String ka_sortOrder; 
        
        
        public TopArticle(){
            this.ka_URL= ka_URL;
            this.ka_Title = ka_Title;
            this.ka_sortOrder = ka_sortOrder;
        }
        
    }
}