import { LightningElement,api } from 'lwc';

export default class CommunityKnowledgeArticles extends LightningElement {
    @api knowledgeArticle;

    get knowledgeArticleURL(){
        return 'article/'+this.knowledgeArticle.Id;
    }
}