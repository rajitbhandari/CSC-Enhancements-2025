/**
 * Created by vpolavarapu on 9/19/2019.
 */

({
    cleanupModalHandlers: function(component, event, helper) {
        window.removeEventListener('showArticleModal', component._showArticleModalHandler);
        window.removeEventListener('closeArticleModal', component._closeArticleModalHandler);
    },
    doInit: function (component, event, helper) {
        var action = component.get("c.getOrganizedArticlesStructure");
        action.setParams({
            TopicId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var newItems=[];
            if(state === 'SUCCESS'){
                let returnValue = response.getReturnValue();
                if(returnValue.length!=0)
                {
                    component.set('v.ArticlesIdentified', returnValue);
                    if(returnValue[0].PriorityArticlesForTheTopic != '' && returnValue[0].PriorityArticlesForTheTopic != null)
                    {
                        newItems.push(returnValue[0].PriorityArticlesForTheTopic);
                    }
                    if(newItems.length >0)
                    {
                        component.set('v.ShowKeyArticle',true);
                    }
                    var parent =  returnValue[0];
                    if(parent.childTopicsAssociated.length==0)
                    {
                        if(component.find("accordion")) {
                            component.find("accordion").set('v.activeSectionName', parent.TopicId);
                        }
                    }
                }
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else {
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);

        // Add event listeners for modal logic using $A.getCallback to ensure Aura context
        var showHandler = $A.getCallback(function(e) {
            var topicId = e.detail.topicId;
            var topicName = e.detail.topicName;
            var articles = [];
            var articlesIdentified = component.get('v.ArticlesIdentified') || [];
            // Find the topic or subtopic by id
            var found = null;
            for (var i = 0; i < articlesIdentified.length; i++) {
                var parent = articlesIdentified[i];
                if (parent.TopicId === topicId) {
                    found = parent;
                    break;
                }
                if (parent.childTopicsAssociated) {
                    for (var j = 0; j < parent.childTopicsAssociated.length; j++) {
                        var child = parent.childTopicsAssociated[j];
                        if (child.TopicId === topicId) {
                            found = child;
                            break;
                        }
                    }
                }
                if (found) break;
            }
            if (found && found.ArticlesForTheTopic) {
                articles = found.ArticlesForTheTopic;
            }
            component.set('v.modalTopicName', topicName);
            component.set('v.modalTopicId', topicId); // Store the topicId for debugging and reload
            component.set('v.modalArticles', articles);
            component.set('v.modalArticlesFull', articles); // Store full list for search
            component.set('v.showModal', true);
        });
        var closeHandler = $A.getCallback(function() {
            component.set('v.showModal', false);
        });
        window.addEventListener('showArticleModal', showHandler);
        window.addEventListener('closeArticleModal', closeHandler);
        component._showArticleModalHandler = showHandler;
        component._closeArticleModalHandler = closeHandler;
    },
    handleTopicClick: function(component, event, helper) {
        var target = event.currentTarget;
        var topicId = target.getAttribute('data-topic-id');
        var topicName = target.getAttribute('data-topic-name');
        window.dispatchEvent(new CustomEvent('showArticleModal', { detail: { topicId: topicId, topicName: topicName } }));
    },
    handleChildTopicClick: function(component, event, helper) {
        var target = event.currentTarget;
        var topicId = target.getAttribute('data-topic-id');
        var topicName = target.getAttribute('data-topic-name');
        window.dispatchEvent(new CustomEvent('showArticleModal', { detail: { topicId: topicId, topicName: topicName } }));
    },
    handleCloseModal: function(component, event, helper) {
        component.set('v.showModal', false);
    },
    handleSortChange: function(component, event, helper) {
        var sortBy = event.target.value;
        var allArticles = component.get('v.modalArticlesFull') || [];
        var filteredArticles = component.get('v.modalArticles') || [];
        var isSearchActive = filteredArticles.length !== allArticles.length;
        var toSort = isSearchActive ? filteredArticles.slice() : allArticles.slice();
        if (sortBy === 'title') {
            toSort.sort(function(a, b) {
                var aTitle = (a && a.knowledgeTitle) ? a.knowledgeTitle.toLowerCase() : '';
                var bTitle = (b && b.knowledgeTitle) ? b.knowledgeTitle.toLowerCase() : '';
                if (aTitle < bTitle) return -1;
                if (aTitle > bTitle) return 1;
                return 0;
            });
        } else if (sortBy === 'date') {
            toSort.sort(function(a, b) {
                var aDate = a.dateAdded ? new Date(a.dateAdded) : (a.LastPublishedDate ? new Date(a.LastPublishedDate) : (a.CreatedDate ? new Date(a.CreatedDate) : new Date(0)));
                var bDate = b.dateAdded ? new Date(b.dateAdded) : (b.LastPublishedDate ? new Date(b.LastPublishedDate) : (b.CreatedDate ? new Date(b.CreatedDate) : new Date(0)));
                return bDate - aDate;
            });
        }
        component.set('v.modalArticles', toSort);
    },
    handleSearchInput: function(component, event, helper) {
        var searchTerm = event.target.value ? event.target.value.toLowerCase() : '';
        var modalArticles = component.get('v.modalArticles') || [];
        if (!searchTerm) {
            // If search is cleared, show all
            component.set('v.modalArticles', modalArticles);
            return;
        }
        var filtered = modalArticles.filter(function(article) {
            var title = '';
            if (article) {
                if (article.knowledgeTitle) {
                    title = article.knowledgeTitle.toLowerCase();
                } else if (article.Title) {
                    title = article.Title.toLowerCase();
                }
            }
            return title.includes(searchTerm);
        });
        component.set('v.modalArticles', filtered);
    },
    handleReloadModal: function(component, event, helper) {
        // Reset the search input if needed
        var searchInput = document.getElementById('searchInput');
        if (searchInput) searchInput.value = '';
        // Relaunch the popup modal by dispatching the showArticleModal event with current topic
        var topicId = component.get('v.recordId');
        var topicName = component.get('v.modalTopicName');
        window.dispatchEvent(new CustomEvent('showArticleModal', { detail: { topicId: topicId, topicName: topicName } }));
    },

});