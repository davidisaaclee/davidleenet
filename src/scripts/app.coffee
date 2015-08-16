{markdown} = require 'markdown'
yaml = require 'js-yaml'
_ = require 'lodash'

Polymer
  is: 'dl-app'

  properties:
    _showingClasses:
      type: Boolean
      observer: '_showingClassesChanged'

  ready: () ->

    @loadWorkEntries 'content/work.yaml'
      .always () =>
        # jumpToHash = () =>
        #   sel = '#' + (window.location.hash.substring 1)
        #   # jumpTo = Polymer.dom(@root).querySelector sel
        #   # if jumpTo?
        #     # @_scrollToElement jumpTo

        #   @_scrollToElement sel
        # @async jumpToHash, 1000

  # attached: () ->
  #   jumpToHash = () =>
  #     sel = '#' + (window.location.hash.substring 1)
  #     # jumpTo = Polymer.dom(@root).querySelector sel
  #     # if jumpTo?
  #       # @_scrollToElement jumpTo

  #     @_scrollToElement sel
  #   @async jumpToHash

  loadWorkEntries: (url) ->
    $.ajax url
      .done (data) =>
        @workEntries =
          yaml.safeLoad data
            .filter (entry) -> entry.description?
        @highlightedWork =
          @workEntries
            .filter (entry) -> _.contains entry.tags, 'highlights'

        return do $.when
      .fail (jqXHR, status, err) ->
        console.log 'ERROR:', err
        return do $.when

  _navigateThumbnail: (evt) ->
    @_scrollToElement ('#' + (@_kebabify evt.model.project.title))

  _makeSectionScrollFunction: (name) -> () ->
    @_scrollToElement ('#' + (@_kebabify name))

  _scrollToElement: (element, margin = 0) ->
    offset = $(element).offset().top - margin
    $ 'html, body'
      .stop()
      .animate scrollTop: offset,
        '500',
        'swing',
        () -> # on end

  _scrollToTop: (evt) ->
    do evt?.stopPropagation
    do evt?.preventDefault
    @_scrollToElement 'html, body'

  # Data-binding helpers

  _largeScreen: true,

  _logAnd: (a, b) -> a and b

  _unzipObject: (obj, keyProperty = 'key', valueProperty = 'value') ->
    reduction = (acc, key) ->
      intermediate = {}
      intermediate[keyProperty] = key
      intermediate[valueProperty] = obj[key]
      acc.push intermediate
      return acc
    (Object.keys obj).reduce reduction, []

  _concat: (a, b) ->
    _.toArray arguments
      .reduce (m, n) -> m + n

  _kebabify: (str) -> _.kebabCase str

  _mdToHTML: (mdText) -> markdown.toHTML mdText

  _showingClassesChanged: () ->
    if @_showingClasses
    then Polymer.dom(@$['disclosure-symbol']).classList.add 'rotated'
    else Polymer.dom(@$['disclosure-symbol']).classList.remove 'rotated'