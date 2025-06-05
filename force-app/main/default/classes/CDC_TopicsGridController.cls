global class CDC_TopicsGridController {
    
    @AuraEnabled
    Public static List<Topics> getTopics(){
        
        Id NetworkId;
        List<Topics> listOfTopics = new List<Topics>();
        List<CDC_TopicImageMatrix__mdt> listOfTopicImageMatrix = new List<CDC_TopicImageMatrix__mdt>();
        map<String,String> topicNameTopicImage = new map<String,String>();
        if(Test.isRunningTest())
        {
            List<Network> networks = [SELECT Id FROM Network LIMIT 1];
            Network network = (networks.size() == 1) ? networks.get(0) : null;
            NetworkId = network.Id;
        }else{
            NetworkId = Network.getNetworkId();
        }
        
        listOfTopicImageMatrix  = [select ImageName__c, Topic_Name__c from CDC_TopicImageMatrix__mdt ];
        
        for(CDC_TopicImageMatrix__mdt images : listOfTopicImageMatrix  )
        {
            topicNameTopicImage.put(images.Topic_Name__c,images.ImageName__c);
        }
        
        ConnectApi.ManagedTopicCollection mtCollection = ConnectAPI.ManagedTopics.getManagedTopics(NetworkId, ConnectApi.ManagedTopicType.Navigational);
        List<ConnectApi.Topic> topicList = new List<ConnectApi.Topic>();
        
        String topicNameString;
        
        for(ConnectApi.ManagedTopic mtopic : mtCollection.managedTopics)
        {
            topicList.add(mtopic.topic);
            Topics to = new Topics();           
            topicNameString = mtopic.topic.name;
            topicNameString = topicNameString.replaceAll('[^a-zA-Z0-9\\s+]', '');
            to.TopicName = mtopic.topic.name;           
            to.TopicURL = '/s/topic/'+mtopic.topic.Id + '/' + topicNameString;                                          
            to.TopicImage = '/s/sfsites/c/resource/' + topicNameTopicImage.get(mtopic.topic.name);
            listOfTopics.add(to);
        }        
       
        return listOfTopics;
        
        
    }
    
    public class Topics {
        @AuraEnabled Public String TopicName;
        @AuraEnabled Public String TopicURL;
        @AuraEnabled Public String TopicImage;
        public Topics(){
            this.TopicName = TopicName;
            this.TopicURL = TopicURL;
            this.TopicImage = TopicImage;
        }
    }
    
}