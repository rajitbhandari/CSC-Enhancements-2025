import { LightningElement, track, api } from 'lwc';
import getOrganizedArticlesStructure from '@salesforce/apex/CustomArticleViewController.getOrganizedArticlesStructure';

export default class CustomArticleViewLwc extends LightningElement {
    @api recordId; // Added to support recordId passed from meta.xml
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
                console.log('Extracted topicId from URL:', recordId);
            } else {
                console.error('No recordId provided to CustomArticleViewLwc and could not extract from URL');
                return;
            }
        }
        getOrganizedArticlesStructure({ TopicId: recordId })
            .then(result => {
                if (result && result.length) {
                    // Add articleUrl to all articles in the structure
                    this.articlesIdentified = this.addArticleUrlsToStructure(result);
                    if (result[0].PriorityArticlesForTheTopic && result[0].PriorityArticlesForTheTopic.length) {
                        this.showKeyArticle = true;
                    }
                }
            })
            .catch(error => {
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

    openModalForTopic(topicId, topicName) {
        let found = null;
        for (let parent of this.articlesIdentified) {
            if (parent.TopicId === topicId) {
                found = parent;
                break;
            }
            if (parent.childTopicsAssociated) {
                for (let child of parent.childTopicsAssociated) {
                    if (child.TopicId === topicId) {
                        found = child;
                        break;
                    }
                }
            }
            if (found) break;
        }
        let articles = (found && found.ArticlesForTheTopic) ? found.ArticlesForTheTopic : [];
        this.modalTopicName = topicName;
        this.modalTopicId = topicId;
        this.modalArticles = articles;
        this.modalArticlesFull = articles;
        this.showModal = true;
    }

    handleCloseModal() {
        this.showModal = false;
    }

    handleSortChange(event) {
        const sortBy = event.target.value;
        let allArticles = this.modalArticlesFull || [];
        let filteredArticles = this.modalArticles || [];
        let isSearchActive = filteredArticles.length !== allArticles.length;
        let toSort = isSearchActive ? [...filteredArticles] : [...allArticles];
        if (sortBy === 'title') {
            toSort.sort((a, b) => {
                let aTitle = (a && a.knowledgeTitle) ? a.knowledgeTitle.toLowerCase() : '';
                let bTitle = (b && b.knowledgeTitle) ? b.knowledgeTitle.toLowerCase() : '';
                if (aTitle < bTitle) return -1;
                if (aTitle > bTitle) return 1;
                return 0;
            });
        } else if (sortBy === 'date') {
            toSort.sort((a, b) => {
                let aDate = a.dateAdded ? new Date(a.dateAdded) : (a.LastPublishedDate ? new Date(a.LastPublishedDate) : (a.CreatedDate ? new Date(a.CreatedDate) : new Date(0)));
                let bDate = b.dateAdded ? new Date(b.dateAdded) : (b.LastPublishedDate ? new Date(b.LastPublishedDate) : (b.CreatedDate ? new Date(b.CreatedDate) : new Date(0)));
                return bDate - aDate;
            });
        }
        this.modalArticles = toSort;
    }

    handleSearchInput(event) {
        const searchTerm = event.target.value ? event.target.value.toLowerCase() : '';
        const modalArticlesFull = this.modalArticlesFull || [];
        if (!searchTerm) {
            this.modalArticles = modalArticlesFull;
            return;
        }
        const filtered = modalArticlesFull.filter(article => {
            let title = '';
            if (article) {
                if (article.knowledgeTitle) {
                    title = article.knowledgeTitle.toLowerCase();
                } else if (article.Title) {
                    title = article.Title.toLowerCase();
                }
            }
            return title.includes(searchTerm);
        });
        this.modalArticles = filtered;
    }

}