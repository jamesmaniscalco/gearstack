Gearstack.AllGearItemsView = Ember.View.extend({
    templateName: 'gear_items/all',
    gear_itemsBinding: 'Gearstack.gear_itemsController',

    refreshListing: function() {
        Gearstack.gear_itemsController.findAll();
    },
    
    showNew: function() {
        this.set('isNewVisible', true);
    },

    hideNew: function() {
        this.set('isNewVisible', false);
    }
});
