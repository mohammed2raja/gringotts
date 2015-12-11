(function() {
  define(function(require) {
    var advice, pageString, paginationStats;
    advice = require('flight/advice');
    paginationStats = function() {
      var end, maxPage, nextPage, page, perPage, prevPage, showPagination, start, total;
      page = this.params.page;
      perPage = this.params.per_page;
      total = this.count || 0;
      start = (page - 1) * perPage + 1;
      end = Math.min(page * perPage, total);
      if (total) {
        maxPage = Math.ceil(total / perPage);
        if (page > maxPage) {
          prevPage = this.scopedUrl({
            page: maxPage
          });
        } else if (page !== 1) {
          prevPage = this.scopedUrl({
            page: page - 1
          });
        }
        if (page < maxPage) {
          nextPage = this.scopedUrl({
            page: page + 1
          });
        }
      }
      showPagination = prevPage || nextPage;
      return {
        nextPage: nextPage,
        prevPage: prevPage,
        showPagination: showPagination,
        start: start,
        end: end,
        total: total
      };
    };
    pageString = function(stats) {
      return "" + stats.start + "-" + stats.end + " of " + stats.total;
    };
    return function() {
      this.before('initialize', function() {
        return this.on('remove', function() {
          return this.count = Math.max(0, this.count - 1);
        });
      });
      this.paginationStats = paginationStats;
      this.pageString = pageString;
      return this;
    };
  });

}).call(this);
