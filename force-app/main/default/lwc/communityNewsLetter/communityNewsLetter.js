import { LightningElement, wire} from 'lwc';
import getCommunityKnowledgeArticles from '@salesforce/apex/CommunityKnowledgeArticlesController.getCommunityKnowledgeArticles';
import getCommunityKnowledgeArticlesUpdated from '@salesforce/apex/CommunityKnowledgeArticlesController.getCommunityKnowledgeArticlesUpdated';

export default class CommunityNewsLetter extends LightningElement {
    @wire(getCommunityKnowledgeArticles)
    knowledgeArticles
    
    @wire(getCommunityKnowledgeArticlesUpdated)
    knowledgeArticlesUpdated
}