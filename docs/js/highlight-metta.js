/**
 * MeTTa syntax highlighting for Prism.js
 * Used with Docsify for PAIP-MeTTa documentation
 */

(function() {
  if (typeof Prism === 'undefined') {
    return;
  }

  Prism.languages.metta = {
    // Comments start with ;
    'comment': {
      pattern: /;.*/,
      greedy: true
    },

    // Strings
    'string': {
      pattern: /"(?:[^"\\]|\\.)*"/,
      greedy: true
    },

    // Variables start with $
    'variable': {
      pattern: /\$[\w-]+/,
      alias: 'metta-variable'
    },

    // Execution operator !
    'execute': {
      pattern: /!/,
      alias: 'metta-execute'
    },

    // Type declaration :
    'type-decl': {
      pattern: /(?<=\()\s*:/,
      alias: 'metta-type-decl'
    },

    // Numbers
    'number': {
      pattern: /-?\b\d+(?:\.\d+)?\b/,
      alias: 'metta-number'
    },

    // Built-in functions and keywords
    'builtin': {
      pattern: /\b(?:match|superpose|collapse|let|let\*|if|case|assertEqual|assertEqualToResult|get-type|unify|eval|chain|cons-atom|decons-atom|add-atom|remove-atom|get-atoms|new-space|pragma!)\b/,
      alias: 'metta-builtin'
    },

    // Boolean values
    'boolean': {
      pattern: /\b(?:True|False)\b/,
      alias: 'metta-keyword'
    },

    // Type keywords
    'type-keyword': {
      pattern: /\b(?:Type|Atom|Symbol|Expression|Variable|Grounded|Number|String|Bool)\b/,
      alias: 'metta-type-decl'
    },

    // Common type constructors
    'constructor': {
      pattern: /\b(?:Nil|Cons|Nothing|Something|Left|Right|Z|S)\b/,
      alias: 'metta-keyword'
    },

    // Arrow type operator
    'arrow': {
      pattern: /->/,
      alias: 'metta-type-decl'
    },

    // Equality definition
    'equality': {
      pattern: /(?<=\()\s*=/,
      alias: 'metta-equality'
    },

    // Self reference
    'self': {
      pattern: /&self\b/,
      alias: 'metta-builtin'
    },

    // Parentheses
    'punctuation': /[()]/,

    // Symbols (identifiers)
    'symbol': {
      pattern: /[\w-]+/
    }
  };

  // Register metta as an alias
  Prism.languages.MeTTa = Prism.languages.metta;

  // Hook into Docsify's markdown rendering
  if (window.$docsify) {
    window.$docsify.plugins = window.$docsify.plugins || [];
    window.$docsify.plugins.push(function(hook) {
      hook.doneEach(function() {
        // Re-highlight after page load
        if (Prism.highlightAll) {
          Prism.highlightAll();
        }
      });
    });
  }
})();
