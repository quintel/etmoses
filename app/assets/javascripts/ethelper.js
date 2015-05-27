/*
 * Collection of helper methods
 */
var ETHelper = {
  groupBy: function(elements, key) {
    var grouped = {},
        length  = elements.length,
        i, element;

    for (i = 0; i < length; i++) {
      element = elements[i];

      if (! grouped.hasOwnProperty(element[key])) {
        grouped[element[key]] = [];
      }

      grouped[element[key]].push(element);
    }

    return grouped;
  },

  eachNode: function(nodes, iterator) {
    var length = nodes.length, i;

    for (i = 0; i < length; i++) {
      iterator.call(this, nodes[i]);

      if (nodes[i]['children'] && nodes[i]['children'].length) {
        ETHelper.eachNode(nodes[i]['children'], iterator);
      }

      if (nodes[i]['_children'] && nodes[i]['_children'].length) {
        ETHelper.eachNode(nodes[i]['_children'], iterator);
      }
    }
  }
};
