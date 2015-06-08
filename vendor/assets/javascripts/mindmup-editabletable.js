/*global $, window*/
$.fn.editableTableWidget = function (options) {
  'use strict';
  return $(this).each(function () {
    var buildDefaultOptions = function () {
        var opts = $.extend({}, $.fn.editableTableWidget.defaultOptions);
        return opts;
      },
      activeOptions = $.extend(buildDefaultOptions(), options),
      ARROW_LEFT = 37, ARROW_UP = 38, ARROW_RIGHT = 39, ARROW_DOWN = 40, ENTER = 13, ESC = 27, TAB = 9,
      element = $(this),
      editors = {
        text: activeOptions.editors.text
          .css('position', 'absolute')
          .hide()
          .appendTo(element.parent()),
      },
      editor = null,
      selectBox = null,
      active = null,
      getEditType = function() {
        var edittype = active.data('edit-type');
        if (edittype == null || typeof(edittype) == 'undefined') {
          edittype = 'text';
        }
        return edittype;
      },
      showEditor = function (select) {
        active = element.find('td:focus');
        if (active.length && !active.hasClass("select")) {
          var edittype = getEditType();
          editor = editors[edittype];
          editor.val(editorValue.call(active, edittype))
            .removeClass('error')
            .show()
            .offset(editorOffset.call(active, edittype))
            .css(active.css(activeOptions.cloneProperties))
            .width(editorWidth.call(active, edittype))
            .height(active.height())
            .focus();
          if (select) {
            editor.select();
          }
        }
      },
      cloneSelectBox = function(){
        var sel = editors.select;
        selectBox = $(".hidden select." + $(this).data('edit-options'));
        sel.html(selectBox.clone(true, true).html());
        sel.on('change', selectBoxChange.bind(this));
      },
      selectBoxChange = function(e){
        updateNextSelectBox($(e.target).val());
      },
      editorValue = function (edittype) {
        if(edittype == "select"){
          return $(this).data("edit-selected");
        }
        else{
          return $(this).text();
        }
      },
      editorOffset = function (edittype) {
        if(edittype == "select"){
          return {
            left: $(this).offset().left - 9,
            top: $(this).offset().top + 2
          }
        }
        else{
          return {
            left: $(this).offset().left + 3,
            top: $(this).offset().top + 4
          }
        }
      },
      editorWidth = function (edittype) {
        if(edittype == "select"){
          return $(this).width() - 15;
        }
        else{
          return $(this).width();
        }
      },
      setActiveText = function () {
        var text = editor.val(),
          evt = $.Event('change'),
          originalContent;

        var edittype = getEditType();
        if (active.text() === text || editor.hasClass('error')) {
          return true;
        }
        originalContent = active.html();

        active.text(text).trigger(evt, text);
        if (evt.result === false) {
          active.html(originalContent);
        }
      },
      movement = function (element, keycode) {
        if (keycode === ARROW_RIGHT) {
          return element.next('td');
        } else if (keycode === ARROW_LEFT) {
          return element.prev('td');
        } else if (keycode === ARROW_UP) {
          return element.parent().prev().children().eq(element.index());
        } else if (keycode === ARROW_DOWN) {
          return element.parent().next().children().eq(element.index());
        }
        return [];
      };
    $.each(editors, function(key, value) {
      value.blur(function () {
        setActiveText();
        editor.hide();
      }).keydown(function (e) {
        if (e.which === ENTER) {
          setActiveText();
          editor.hide();
          active.focus();
          e.preventDefault();
          e.stopPropagation();
        } else if (e.which === ESC) {
          e.preventDefault();
          e.stopPropagation();
          editor.hide();
          active.focus();
        } else if (e.which === TAB) {
          active.focus();
        } else if (this.selectionEnd - this.selectionStart === this.value.length) {
          var possibleMove = movement(active, e.which);
          if (possibleMove.length > 0) {
            possibleMove.focus();
            e.preventDefault();
            e.stopPropagation();
          }
        }
      })
      .on('input paste', function () {
        var evt = $.Event('validate');
        active.trigger(evt, editor.val());
        if (evt.result === false) {
          editor.addClass('error');
        } else {
          editor.removeClass('error');
        }
      })
    });
    element.on('click keypress dblclick', showEditor)
    .css('cursor', 'pointer')
    .keydown(function (e) {
      var prevent = true,
        possibleMove = movement($(e.target), e.which);
      if (possibleMove.length > 0) {
        possibleMove.focus();
      } else if (e.which === ENTER) {
        showEditor(false);
      } else if (e.which === 17 || e.which === 91 || e.which === 93) {
        showEditor(true);
        prevent = false;
      } else {
        prevent = false;
      }
      if (prevent) {
        e.stopPropagation();
        e.preventDefault();
      }
    });

    element.find('td').prop('tabindex', 1);

    $(window).on('resize', function () {
      if (editor == null) {
        return;
      }
      if (editor.is(':visible')) {
        editor.offset(active.offset())
          .width(active.width())
          .height(active.height());
      }
    });
  });

};
$.fn.editableTableWidget.defaultOptions = {
  cloneProperties: ['text-align', 'font', 'font-size', 'font-family', 'font-weight',
            'border', 'border-top', 'border-bottom', 'border-left', 'border-right'],
  editors: {
    text: $('<input type="text">')
  },
  editor: null,
  active: null,
};
