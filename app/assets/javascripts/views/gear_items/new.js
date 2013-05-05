Gearstack.NewGearItemView = Ember.View.extend({
    tagName: 'form',
    templateName: 'gear_items/edit',

    init: function() {
        this._super();
        this.set("gear_item", Gearstack.GearItem.create());
    },

    didInsertElement: function() {
        this._super();
        this.$('input:first').focus();
    },

    cancelForm: function() {
        this.get("parentView").hideNew();
    },

    submit: function(event) {
        var self = this;
        var gear_item = this.get("gear_item");
        
        gear_item.status = "checkedin";

        event.preventDefault();

        gear_item.saveResource()
            .fail( function(e) {
                Gearstack.displayError(e);
            })
            .done( function() {
                Gearstack.gear_itemsController.pushObject(gear_item);
                self.get("parentView").hideNew();
            });
    }
});
