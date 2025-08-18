import { LightningElement, track, api } from 'lwc';
import getOrganizedArticlesStructure from '@salesforce/apex/CustomArticleViewController.getOrganizedArticlesStructure';

export default class CscCustomBanner extends LightningElement {
    @api backgroundColor;
    @api textColor;
    @api fontSize;
    @api height;
    @api content;
    @api recordId;

    @track articlesIdentified = [];
    @track showKeyArticle = false;
    @track showModal = false;
    @track modalTopicName = '';
    @track modalArticles = [];
    @track modalArticlesFull = [];
    @track modalTopicId = '';

    connectedCallback() {
        console.log('CustomArticleViewLwc recordId:', this.recordId);
        let recordId = this.recordId;
        if (!recordId) {
            const url = window.location.pathname;
            const match = url.match(/\/s\/topic\/([a-zA-Z0-9]{15,18})/);
            if (match && match[1]) {
                recordId = match[1];
                // eslint-disable-next-line no-console
                console.log('Extracted topicId from URL:', recordId);
            } else {
                // eslint-disable-next-line no-console
                console.error('No recordId provided to CustomArticleViewLwc and could not extract from URL');
                return;
            }
        }
        getOrganizedArticlesStructure({ TopicId: recordId })
            .then(result => {
                if (result && result.length) {
                    console.log('result recordId:', result);
                    // Add articleUrl to all articles in the structure
                    this.articlesIdentified = this.addArticleUrlsToStructure(result);
                    if (result[0].PriorityArticlesForTheTopic && result[0].PriorityArticlesForTheTopic.length) {
                        this.showKeyArticle = true;
                    }
                }
            })
            .catch(error => {
                // handle error
                // eslint-disable-next-line no-console
                console.error(error);
            });
    }

    // Helper to add articleUrl to all articles in the structure
    addArticleUrlsToStructure(structure) {
        return structure.map(topic => {
            let newTopic = { ...topic };
            if (newTopic.PriorityArticlesForTheTopic) {
                newTopic.PriorityArticlesForTheTopic = newTopic.PriorityArticlesForTheTopic.map(a => this.addArticleUrl(a));
            }
            if (newTopic.ArticlesForTheTopic) {
                newTopic.ArticlesForTheTopic = newTopic.ArticlesForTheTopic.map(a => this.addArticleUrl(a));
            }
            if (newTopic.childTopicsAssociated) {
                newTopic.childTopicsAssociated = newTopic.childTopicsAssociated.map(child => {
                    let newChild = { ...child };
                    if (newChild.ArticlesForTheTopic) {
                        newChild.ArticlesForTheTopic = newChild.ArticlesForTheTopic.map(a => this.addArticleUrl(a));
                    }
                    return newChild;
                });
            }
            return newTopic;
        });
    }

    // Helper to add articleUrl to a single article
    addArticleUrl(article) {
        let url = '#';
        if (article && article.Id) {
            url = `/lightning/r/Knowledge__kav/${article.Id}/view`;
        }
        return { ...article, articleUrl: url };
    }

    handleTopicClick(event) {
        const topicId = event.currentTarget.dataset.topicId;
        const topicName = event.currentTarget.dataset.topicName;
        this.openModalForTopic(topicId, topicName);
    }

    handleChildTopicClick(event) {
        const topicId = event.currentTarget.dataset.topicId;
        const topicName = event.currentTarget.dataset.topicName;
        this.openModalForTopic(topicId, topicName);
    }


    get computedStyle() {
        const backgroundColor = this.backgroundColor || '#f0f0f0';
        const color = this.textColor || '#181818';
        const fontSize = this.fontSize || '16px';
        const height = this.height ? `height: ${this.height};` : '';
        return `background-color: ${backgroundColor}; color: ${color}; font-size: ${fontSize}; padding: 1rem; text-align: center; border-radius: 8px; ${height}`;
    }


    // Getter to extract topicName from articlesIdentified
    get topicName() {
        if (this.articlesIdentified && this.articlesIdentified.length > 0) {
            return this.articlesIdentified[0].TopicName || '';
        }
        return '';
    }

    // Getter to extract topicDescription from articlesIdentified
    get topicDescription() {
        if (this.articlesIdentified && this.articlesIdentified.length > 0) {
            return this.articlesIdentified[0].TopicDescription || '';
        }
        return '';
    }


}