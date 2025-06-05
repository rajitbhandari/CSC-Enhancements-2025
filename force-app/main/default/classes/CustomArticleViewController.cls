/**
* Created by vpolavarapu on 9/19/2019.
*/

public without sharing class CustomArticleViewController {
    
    @AuraEnabled
    Public static customArticleDto[] getOrganizedArticlesStructure(String TopicId){
        Id NetworkId;
        if(Test.isRunningTest())
        {
            List<Network> networks = [SELECT Id FROM Network LIMIT 1];
            Network network = (networks.size() == 1) ? networks.get(0) : null;
            NetworkId = network.Id;
        }else{
            NetworkId = Network.getNetworkId();
        }
        ConnectAPI.ManagedTopicCollection topics = ConnectAPI.ManagedTopics.getManagedTopics(NetworkId,
                                                                                             ConnectApi.ManagedTopicType.Navigational,
                                                                                             new List<String>{TopicId},
                                                                                             4);
        customArticleDto[] idenitifiedTopics= getTopicStructure(topics.managedTopics);
        Map<String,ArticleDTO[]> topicToArticleNameMap = new Map<String,ArticleDTO[]>();
        return idenitifiedTopics;
    }
    private static customArticleDto[] getTopicStructure(ConnectApi.ManagedTopic[] topics) {
        customArticleDto[] topicsDataList = new customArticleDto[0];
        for (ConnectApi.ManagedTopic topic : topics) {
            customArticleDto topicDataStructure = new customArticleDto(topic);
            topicDataStructure.ArticlesForTheTopic =getArticles(topic.Topic.Id);
           // topicDataStructure.PriorityArticlesForTheTopic =getPriorityArticles(topic.Topic.Id,topic.Topic.Name);   
            if(!topic.children.isEmpty())
            {
                topicDataStructure.childTopicsAssociated = getTopicStructure(topic.children);
            }
            topicsDataList.add(topicDataStructure);
        }
        return topicsDataList;
    }
    @AuraEnabled
    public static ArticleDTO[] getArticles(Id TopicId){
        ArticleDTO[] articles = new ArticleDTO[0];
        Map<String,Set<Id>> mapKnowledgeObjectToListIdsMapping = new Map<String,Set<Id>>();
        for(TopicAssignment  TopicAssignment : [select EntityId from TopicAssignment where TopicId=:TopicId and EntityType!='FeedItem'])
        {
            String sobjectName = String.valueOf(TopicAssignment.EntityId.getSobjectType());
            set<Id> tempValues = mapKnowledgeObjectToListIdsMapping.get(sobjectName);
            if(tempValues==null)
            {
                mapKnowledgeObjectToListIdsMapping.put(sobjectName,tempValues=new Set<Id>());
            }
            tempValues.add(TopicAssignment.EntityId);
        }
        List<Sobject> allArticlesForTopic = new List<Sobject>();
        if(!mapKnowledgeObjectToListIdsMapping.isEmpty())
        {
            for(String sobjectName :mapKnowledgeObjectToListIdsMapping.keySet())
            {
                Set<Id> entitiesToquery = mapKnowledgeObjectToListIdsMapping.get(sobjectName);
                if(!entitiesToquery.isEmpty())
                {
                    system.debug(sobjectName);
                    List<sObject> sobjList = Database.query('select Priority__c,UrlName,CreatedDate,Id,Title,ArticleTotalViewCount,PublishStatus from '+sobjectName+' Where Id =:entitiesToquery AND PublishStatus=\'' + String.escapeSingleQuotes('Online')+'\'' );
                    if(sobjList.size()>0)
                    {
                        allArticlesForTopic.addall(sobjList);
                        system.debug(allArticlesForTopic.size());
                    }
                }
            }

            
            
        }
        if(!allArticlesForTopic.isEmpty())
        {
            for(sObject obj : allArticlesForTopic)
            {
                articles.add(new ArticleDTO(obj));
            }
        }
        return articles;
    }
    @AuraEnabled
    public static ArticleDTO[] getPriorityArticles(Id TopicId,String TopicName){
        ArticleDTO[] articles = new ArticleDTO[0];
        Map<String,Set<Id>> mapKnowledgeObjectToListIdsMapping = new Map<String,Set<Id>>();
        for(TopicAssignment  TopicAssignment : [select EntityId from TopicAssignment where TopicId=:TopicId and EntityType!='FeedItem'])
        {
            String sobjectName = String.valueOf(TopicAssignment.EntityId.getSobjectType());
            set<Id> tempValues = mapKnowledgeObjectToListIdsMapping.get(sobjectName);
            if(tempValues==null)
            {
                mapKnowledgeObjectToListIdsMapping.put(sobjectName,tempValues=new Set<Id>());
            }
            tempValues.add(TopicAssignment.EntityId);
        }
        List<Sobject> allArticlesForTopic = new List<Sobject>();
        List<Sobject> tempallArticlesForTopic = new List<Sobject>();
        if(!mapKnowledgeObjectToListIdsMapping.isEmpty())
        {
            for(String sobjectName :mapKnowledgeObjectToListIdsMapping.keySet())
            {
                Set<Id> entitiesToquery = mapKnowledgeObjectToListIdsMapping.get(sobjectName);
                if(!entitiesToquery.isEmpty())
                {
                    system.debug(sobjectName);
                    List<sObject> sobjList = Database.query('select Priority__c,UrlName,CreatedDate,Id,Title,ArticleTotalViewCount,PublishStatus from '+sobjectName+' Where Id =:entitiesToquery AND PublishStatus=\'' + String.escapeSingleQuotes('Online')+'\' AND Priority__c != null and Linked_Topics__c includes (:TopicName) and Linked_Topics__c != null  order by Priority__c' );
                    if(sobjList.size()>0)
                    {
                        tempallArticlesForTopic.addall(sobjList);
                        system.debug(allArticlesForTopic.size());
                    }
                }
            }
            
            Integer n = tempallArticlesForTopic.size();            
            for (Integer i = 0; i < n; i++) {
                for (Integer j = 1; j < (n-i); j++) {   
                    if (integer.valueof(tempallArticlesForTopic[j-1].get('Priority__c')) > integer.valueof(tempallArticlesForTopic[j].get('Priority__c'))) {   
                        sobject temp = tempallArticlesForTopic[j-1];
                        system.debug('temp' + temp);
                        tempallArticlesForTopic[j-1] = tempallArticlesForTopic[j];
                        tempallArticlesForTopic[j] = temp;
                        system.debug(tempallArticlesForTopic);
                    }            
                }
             system.debug(tempallArticlesForTopic);

            }   
            
            for(sObject obj : tempallArticlesForTopic)
            {
                system.debug(obj);
                if(allArticlesForTopic.size() <5){
                    allArticlesForTopic.add(obj);
                    system.debug(allArticlesForTopic.size());}
            }
        }
        if(!allArticlesForTopic.isEmpty())
        {
            for(sObject obj : allArticlesForTopic)
            {
                articles.add(new ArticleDTO(obj));
            }
        }
        return articles;
    }
    public class customArticleDto {
        @AuraEnabled Public ArticleDTO[] ArticlesForTheTopic = new ArticleDTO[0];
        @AuraEnabled Public ArticleDTO[] PriorityArticlesForTheTopic = new ArticleDTO[0];
        @AuraEnabled Public customArticleDto[] childTopicsAssociated = new customArticleDto[0];
        @AuraEnabled Public String TopicName;
        @AuraEnabled Public String TopicId;
        public customArticleDto(ConnectApi.ManagedTopic Topic ){
            this.TopicName = Topic.Topic.Name;
            this.TopicId = Topic.Topic.Id;
        }
    }
    
    public class ArticleDTO{
        @AuraEnabled Public String knowledgeTitle;
        @AuraEnabled Public String knowledgeUrlName;
        @AuraEnabled Public String knowledgeId;
        @AuraEnabled Public String NumberOfViews;
        @AuraEnabled Public String dateAdded;
        @AuraEnabled Public String urlToRecirect;
        @AuraEnabled Public String newArticle;

        
        public ArticleDTO(SObject record)
        {
            this.knowledgeTitle = String.valueOf(record.get('Title'));
            this.knowledgeId = String.valueOf(record.get('Id'));
            this.NumberOfViews = String.valueOf(record.get('ArticleTotalViewCount'));
            this.dateAdded = Datetime.valueOf(record.get('CreatedDate')).format('MMM dd, yyyy');
            this.knowledgeUrlName = String.valueOf(record.get('UrlName'));
            this.urlToRecirect = this.knowledgeUrlName!=null ?Site.getBaseUrl()+'/s/article/'+this.knowledgeUrlName:null;
            
            Boolean isNewArticle = false;
            if(Date.valueOf(record.get('CreatedDate')) > Date.today() - 90){
                this.newArticle = 'New!';
            }
            else
            {
                this.newArticle = '';
            }
        }
    }
}