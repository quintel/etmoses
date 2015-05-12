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
  }
};
