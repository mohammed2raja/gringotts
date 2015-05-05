(function() {
  define(function(require, exports) {
    var getTemplateData;
    getTemplateData = function() {
      this.stats.num_items = this.collection.pageString(this.stats);
      return this.stats;
    };
    return exports = function() {
      this.tagName = 'span';
      this.className = "collection-pagination " + (this.className || '');
      this.before('delegateListeners', function() {
        this.delegateListener('syncStateChange', 'collection', function() {
          this.stats = this.collection.paginationStats();
          return this.render();
        });
        return this.delegateListener('remove', 'collection', function() {
          this.stats.end = Math.max(0, this.stats.end - 1);
          this.stats.total = this.collection.count;
          return this.render();
        });
      });
      this.before('initialize', function() {
        return this.stats = this.collection.paginationStats();
      });
      this.getTemplateData = getTemplateData;
      return this;
    };
  });

}).call(this);
