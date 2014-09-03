describe('A mousetrap trigger module', function() {
  "use strict";

  var trigger,
      link;

  describe('when clicking a trigger', function() {

    beforeEach(function() {
      link = $('<a href="#" data-keys="z">Trigger Z key thing</a>');
      trigger = new GOVUKAdmin.Modules.MousetrapTrigger();
    });

    it('triggers the specified mousetrap event' , function() {
      spyOn(Mousetrap, 'trigger');
      trigger.start(link);
      link.trigger('click');

      expect(Mousetrap.trigger).toHaveBeenCalledWith('z');
    });

  });

});
